unit PrintSetting;

interface
uses
  BPLADLL, PrintExtension, Windows, Classes, StrUtils, SysUtils;


  //PortType:端口类型
  //DevName:设备名称
  //ExInfo:预留扩展信息
  function PrintExecute(APortType, ADevType: Integer;ALabelFilep: PChar;AExInfo: PExInfo): Integer; stdcall;
  {------------------------------SNBC BTP-L520----------------------------------}
  //获取设备名
  function GetDeviceName(AExInfo: PExInfo): Boolean;
  //打开端口
  function OpenPrintPort(APortType: Integer; AExInfo: PExInfo): Boolean;
  //查询状态
  function CheckPrintStatus(): Integer;
  //设置参数，结束并打印
  function SetPrintPara(ADevType: Integer;ALabelFile: string;AExInfo: PExInfo): Integer;
  //票面内容设置
  function FileToLabelSetting(ADevType: Integer;ALabelFile: string;AExInfo: PExInfo): Integer;
  //关闭端口
  function ClosePrintPort(): Integer;

var
  SNBCPrt: TPrintInfo;
implementation

function PrintExecute(APortType, ADevType: Integer;ALabelFilep: PChar;AExInfo: PExInfo): Integer; stdcall;
var
  iResult: Integer;
  ALabelFile: string;
begin
  Result := -1;
  //SNBC BTP-L520
  if ADevType in [Dev_Type_L520_5640, Dev_Type_L520_3630] then
  begin
    try
      ALabelFile := ALabelFilep;
      //获取设备名称
      if not GetDeviceName(AExInfo) then
      begin
        Result := -111;
        Exit;
      end;
      //打开端口
      if not OpenPrintPort(APortType, AExInfo) then
      begin
        Result := -11;
        Exit;
      end;
      //查询状态
      iResult := CheckPrintStatus;
      if (iResult <> Prt_Status_OK) then
      begin
        Result := iResult;
        Exit;
      end;     
      //进入标签模式
      //打印设置
      //启动打印
      //设置参数
      iResult := SetPrintPara(ADevType, ALabelFile, AExInfo);
      if iResult <> Para_OK then
      begin
        Result := iResult;
        Exit;
      end;
    finally
      //关闭端口
      iResult := ClosePrintPort;
      if iResult <> Port_Close_OK then
      begin
        Result := iResult;
      end;
      Result := 0;
    end;
  end;
end;

{------------------------------SNBC BTP-L520----------------------------------}
function GetDeviceName(AExInfo: PExInfo): Boolean;
var
  pDevName: PChar;
  iReturn: PINT;
  slDevName: TStringList;
  iResult: Integer;
begin
  Result := False;
  pDevName := StrAlloc(SizeOf(Char) * 64);
  New(iReturn);
  slDevName := TStringList.Create;
  try
    iResult := Enum_DeviceNameList(0, pDevName, 64, iReturn, '');
    if iResult <> SDK_SUCCESS then
    begin
      Exit;
    end;
    slDevName.Delimiter := '@';
    slDevName.DelimitedText := pDevName;
    if slDevName.Count > 0 then             //修改当打印机关闭时错误
      SNBCPrt.DevName := slDevName.Strings[0];
    Result := True;
  finally
    StrDispose(pDevName);
    Dispose(iReturn);
    slDevName.Free;
  end;
end;

function OpenPrintPort(APortType: Integer; AExInfo: PExInfo): Boolean;
var
  uUSBPara: USBPara;
  cComPara: COMPara;
  lLPTPara: LPTPara;
  nNetPara: NetPara;
  dDrvPara: DrvPara;
  i, iResult, iUsbSaveEnable: Integer;
  sUsbDevName, sUsbFileName: string;
begin
  Result := False;
  iResult := -1;
  case APortType of
    //串口
    PORT_SERIAL:
      begin
        New(cComPara);
        Dispose(COMPara(cComPara));
      end;
    //并口
    PORT_PARALLEL:
      begin
        New(lLPTPara);
        Dispose(LPTPara(lLPTPara));
      end;
    //USB接口
    PORT_USBDEVICE:
      begin
        New(uUSBPara);
        //USB通讯模式，范围：0：API模式通讯，1：类模式通讯。
        //USB设备ID。如果iDevID = -1，采用直接打开API模式USB接口方式通讯；如果iDevID>=0，则通过内部ID方式打开API模式USB接口通讯。
        //类模式USB设备名称，iUSBMode = 1时有效，可以通过枚举函数Enum_DeviceNameList获取此名称。
        uUSBPara.iUSBMode := 1;
        uUSBPara.iDevID := -1;
        sUsbDevName := SNBCPrt.DevName;
        sUsbFileName := 'c:\test.txt';
        iUsbSaveEnable := 0;
        for i := 1 to 64 do
        begin
          uUSBPara.cDevName[i] := #0;
        end;
        for i := 1 to Length(sUsbDevName) do
        begin
          uUSBPara.cDevName[i] := sUsbDevName[i];
        end;
        iResult := Comm_OpenPort(APortType, uUSBPara, SizeOf(USBSetting), iUsbSaveEnable, sUsbFileName);
        Result := (iResult >= SDK_SUCCESS);
        Dispose(USBPara(uUSBPara));
      end;
    //网络接口
    PORT_ETHERNET:
      begin
        New(nNetPara);
        Dispose(NetPara(nNetPara));
      end;
    //驱动接口
    PORT_DRIVER:
      begin
        New(dDrvPara);
        Dispose(DrvPara(dDrvPara));
      end;
  end;  
  //设备端口句柄
  SNBCPrt.Comhwd := iResult;
end;

function CheckPrintStatus(): Integer;
var
  iResult: Integer;
  iBufLength: DWORD;
  pStatusBuf: PChar;
begin
  Result := 0;
  if SNBCPrt.Comhwd < 0 then
  begin
    Result := Prt_status_Exp;
    Exit;
  end;
  pStatusBuf := AllocMem(5);
  New(pStatusBuf);
  try
    iResult := Get_StatusData(SNBCPrt.Comhwd, pStatusBuf[0], 3, iBufLength, 3000);
    if (iResult <> SDK_SUCCESS) or (iBufLength <> 3) then
    begin
      Result := Prt_status_Exp;
      Exit;
    end;
    if((byte(pStatusBuf[0]) and $40) = $40) then
    begin
      Result := Prt_Status_PIE
    end
    else if((byte(pStatusBuf[0]) and $20) = $20) then
    begin
      Result := Prt_Status_RIE
    end
    else if((byte(pStatusBuf[0]) and $80) = $80) then
    begin
      Result := Prt_Status_DIB
    end
    else if((byte(pStatusBuf[0]) and $04) = $04) then
    begin
      Result := Prt_Status_DIPS
    end
    else if((byte(pStatusBuf[1]) and $80) = $80) then
    begin
      Result := Prt_Status_DSCIE
    end
    else if((byte(pStatusBuf[1]) and $20) = $20) then
    begin
      Result := Prt_Status_TIH
    end
    else if((byte(pStatusBuf[1]) and $08) = $08) then
    begin
      Result := Prt_Status_TIO
    end
    else if((byte(pStatusBuf[1]) and $04) = $04) then
    begin
      Result := Prt_Status_CIS
    end
    else
    begin
      Result := Prt_Status_OK
    end;
  finally
    FreeMem(pStatusBuf);
  end;
end;

function SetPrintPara(ADevType: Integer;ALabelFile: string;AExInfo: PExInfo): Integer;
var
  iResult: Integer;
  bBasePara: BasePara;
begin
  Result := 0;
  if SNBCPrt.Comhwd < 0 then
  begin
    Result := Para_ExpErr;
    Exit;
  end;
  //设置基本参数;
  New(bBasePara);
  try
    bBasePara.iDPI := 0;                  //设备分辨率（设置为当前使用打印机的分辨率），  范围：0：默认设置（200DPI）；200：200DPI；300：300DPI。
    bBasePara.iUnit := 0;                 //设备应用单位，范围：0 --- 3，分别表示：默认设置（毫米/10），毫米/10，点，英寸/100。
    bBasePara.iOutMode := 3;              //设置出纸方式，范围：0 --- 4，分别表示：默认设置，切刀，剥离，撕离，回卷。
    bBasePara.iPaperType := 3;            //设置纸张类型，范围：0 --- 3，分别表示：默认设置，连续纸，黑标纸，标签纸。
    bBasePara.iPrintMode := 0;            //设置打印模式，范围：0 --- 2，分别表示：默认设置，热敏打印，热转印打印。
    bBasePara.iAllRotateMode := 0;        //设置旋转模式，范围：0：不旋转，1：旋转180度。
    bBasePara.iAllMirror := 0;            //设置整体镜象，范围：0：不镜像，1：镜像。
    iResult := Set_BasePara(SNBCPrt.Comhwd, bBasePara, SizeOf(BaseParameter));
    if iResult <> SDK_SUCCESS then
    begin
      Result := Para_BaseParaErr;
      Exit;
    end;
  finally
    Dispose(BasePara(bBasePara));
  end;
  //设置出纸位置
  iResult := Set_OutPosition(SNBCPrt.Comhwd, 112);
  if iResult <> SDK_SUCCESS then
  begin
    Result := Para_OutPosErr;
    Exit;
  end;
  //进入标签模式
  iResult := Prt_EnterLabelMode(SNBCPrt.Comhwd, 0, 2000, 0, 0, 0, 20);
  if iResult <> SDK_SUCCESS then
  begin
    Result := Para_LabelModeErr;
    Exit;
  end;
  //票面内容设置
  iResult := FileToLabelSetting(ADevType, ALabelFile, AExInfo);
  if iResult <> SDK_SUCCESS then
  begin
    Result := iResult;
    Exit
  end;
  //结束标签模式并启动打印
  iResult := Prt_EndLabelAndPrint(SNBCPrt.Comhwd, 1, 1, 1);
  if iResult <> SDK_SUCCESS then
  begin
    Result := Para_StartErr;
    Exit;
  end;
end;

function FileToLabelSetting(ADevType: Integer;ALabelFile: string;AExInfo: PExInfo): Integer;
var
  F: TextFile;
  sLine, sTextMemo, sFontName: string;
  slLabel: TStringList;
  idx, i, iSize: Integer;
  iWidth, iHeight: Integer;
  tTrueType: TruetypePrintPara;
  iResult: Integer;
const
  Label_Width = 560;
  Label_Height_5640 = 400;
  Label_Height_3630 = 300;
  Label_Size = 30;
begin
  Result := 0;
  AssignFile(F, ALabelFile);
  Reset(F);
  slLabel := TStringList.Create;
  New(tTrueType);
  try
    if ADevType = Dev_Type_L520_5640 then
    begin
      iWidth := 10;
      iHeight := Label_Height_5640;
    end
    else
    begin
      iWidth := 100;
      iHeight := Label_Height_3630;
    end;
    while not Eof(F) do
    begin
      Readln(F, sLine);
      idx := Pos(']', sLine);
      if idx > 0 then
      begin
        iSize := Length(sLine) - idx;
        //空行跳过并增加实际空行距离
        if iSize = 0 then
        begin
          iHeight := iHeight - Label_Size;
          Continue;
        end;
        //rightstr,则会将汉字作为一个字符进行截取，midstr则按字符长度截取
        sTextMemo := MidStr(sLine, idx + 1, iSize);
        sLine := MidStr(sLine, 2, idx - 2);      
        slLabel.Delimiter := '+';
        slLabel.DelimitedText := sLine;
        GetMem(tTrueType.cText, iSize);
        CopyMemory(tTrueType.cText, PChar(sTextMemo), iSize);
        tTrueType.cText[iSize] := #0;
//        sLine := LeftStr(sLine, idx);        string动态分配，此处会引起最后一行中文结束带字符，Sline的操作放在打印串分配前
//        Delete(sLine, 1, 1);
//        Delete(sLine, Length(sLine), 1);
        if slLabel.Count = 6 then
        begin
          tTrueType.iStartX := iWidth;
//          tTrueType.iStartY := iHeight;                     //改动，先读出需打印字高度，以原高度减去字高度
          sFontName := FontSet[StrToIntDef(slLabel.Strings[0], 0)].fFontName;
          for i := 1 to Length(sFontName) do
          begin
            tTrueType.cFontName[i] := sFontName[i];
          end;
          tTrueType.iFontHeight := Round(Label_Size * StrToFloatDef(slLabel.Strings[1], 1));
          tTrueType.iFontWidth := 0;
          iHeight := iHeight - tTrueType.iFontHeight - 10;
          tTrueType.iStartY := iHeight;
          tTrueType.iRotate := StrToIntDef(slLabel.Strings[2], 1);
          tTrueType.iBold := StrToIntDef(slLabel.Strings[3], 0);
          tTrueType.iItalic := StrToIntDef(slLabel.Strings[4], 0);
          tTrueType.iUnderline := StrToIntDef(slLabel.Strings[5], 0);
        end;
      end
      //无标签则默认格式
      else
      begin
        iSize := Length(sLine);
        //空行跳过并增加实际空行距离
        if iSize = 0 then
        begin
          iHeight := iHeight - Label_Size;
          Continue;
        end;
        GetMem(tTrueType.cText, iSize);
        CopyMemory(tTrueType.cText, PChar(sLine), iSize);
        tTrueType.cText[iSize] := #0;
        tTrueType.iStartX := iWidth;
//        tTrueType.iStartY := iHeight;
        sFontName := FontSet[Ord(Fnt_SongTi)].fFontName;
        for i := 1 to Length(sFontName) do
        begin
          tTrueType.cFontName[i] := sFontName[i];
        end;
        tTrueType.iFontHeight := Label_Size;
        iHeight := iHeight - Label_Size - 10;
        tTrueType.iStartY := iHeight;
        tTrueType.iFontWidth := 0;
        tTrueType.iRotate := 1;
        tTrueType.iBold := 0;
        tTrueType.iItalic := 0;
        tTrueType.iUnderline := 0;
      end;
      iResult := Prt_LabelPrintSetting(SNBCPrt.Comhwd, PRINT_TREUTYPE, tTrueType, SizeOf(TruetypeSetting), 0);
      if iResult <> SDK_SUCCESS then
      begin
        Result := Para_ContentErr;
        Exit;
      end;
    end;
  finally
//    FreeMem(tTrueType.cText); //最后一个字符是中文时，指针错误。
    CloseFile(F);
    slLabel.Free;
    Dispose(TruetypePrintPara(tTrueType));
  end;
end;

function ClosePrintPort(): Integer;
var
  iResult: Integer;
begin
  Result := 0;
  if SNBCPrt.Comhwd < 0 then
  begin
    Result := Port_Close_Exp;
    Exit;
  end;
  iResult := Comm_ClosePort(SNBCPrt.Comhwd);
  if iResult <> SDK_SUCCESS then
  begin
    Result := Port_Close_Err;
    Exit;
  end;
  SNBCPrt.Comhwd := -1;
end;

end.

