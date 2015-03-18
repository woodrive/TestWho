unit PrintSetting;

interface
uses
  BPLADLL, PrintExtension, Windows, Classes, StrUtils, SysUtils;


  //PortType:�˿�����
  //DevName:�豸����
  //ExInfo:Ԥ����չ��Ϣ
  function PrintExecute(APortType, ADevType: Integer;ALabelFilep: PChar;AExInfo: PExInfo): Integer; stdcall;
  {------------------------------SNBC BTP-L520----------------------------------}
  //��ȡ�豸��
  function GetDeviceName(AExInfo: PExInfo): Boolean;
  //�򿪶˿�
  function OpenPrintPort(APortType: Integer; AExInfo: PExInfo): Boolean;
  //��ѯ״̬
  function CheckPrintStatus(): Integer;
  //���ò�������������ӡ
  function SetPrintPara(ADevType: Integer;ALabelFile: string;AExInfo: PExInfo): Integer;
  //Ʊ����������
  function FileToLabelSetting(ADevType: Integer;ALabelFile: string;AExInfo: PExInfo): Integer;
  //�رն˿�
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
      //��ȡ�豸����
      if not GetDeviceName(AExInfo) then
      begin
        Result := -111;
        Exit;
      end;
      //�򿪶˿�
      if not OpenPrintPort(APortType, AExInfo) then
      begin
        Result := -11;
        Exit;
      end;
      //��ѯ״̬
      iResult := CheckPrintStatus;
      if (iResult <> Prt_Status_OK) then
      begin
        Result := iResult;
        Exit;
      end;     
      //�����ǩģʽ
      //��ӡ����
      //������ӡ
      //���ò���
      iResult := SetPrintPara(ADevType, ALabelFile, AExInfo);
      if iResult <> Para_OK then
      begin
        Result := iResult;
        Exit;
      end;
    finally
      //�رն˿�
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
    if slDevName.Count > 0 then             //�޸ĵ���ӡ���ر�ʱ����
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
    //����
    PORT_SERIAL:
      begin
        New(cComPara);
        Dispose(COMPara(cComPara));
      end;
    //����
    PORT_PARALLEL:
      begin
        New(lLPTPara);
        Dispose(LPTPara(lLPTPara));
      end;
    //USB�ӿ�
    PORT_USBDEVICE:
      begin
        New(uUSBPara);
        //USBͨѶģʽ����Χ��0��APIģʽͨѶ��1����ģʽͨѶ��
        //USB�豸ID�����iDevID = -1������ֱ�Ӵ�APIģʽUSB�ӿڷ�ʽͨѶ�����iDevID>=0����ͨ���ڲ�ID��ʽ��APIģʽUSB�ӿ�ͨѶ��
        //��ģʽUSB�豸���ƣ�iUSBMode = 1ʱ��Ч������ͨ��ö�ٺ���Enum_DeviceNameList��ȡ�����ơ�
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
    //����ӿ�
    PORT_ETHERNET:
      begin
        New(nNetPara);
        Dispose(NetPara(nNetPara));
      end;
    //�����ӿ�
    PORT_DRIVER:
      begin
        New(dDrvPara);
        Dispose(DrvPara(dDrvPara));
      end;
  end;  
  //�豸�˿ھ��
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
  //���û�������;
  New(bBasePara);
  try
    bBasePara.iDPI := 0;                  //�豸�ֱ��ʣ�����Ϊ��ǰʹ�ô�ӡ���ķֱ��ʣ���  ��Χ��0��Ĭ�����ã�200DPI����200��200DPI��300��300DPI��
    bBasePara.iUnit := 0;                 //�豸Ӧ�õ�λ����Χ��0 --- 3���ֱ��ʾ��Ĭ�����ã�����/10��������/10���㣬Ӣ��/100��
    bBasePara.iOutMode := 3;              //���ó�ֽ��ʽ����Χ��0 --- 4���ֱ��ʾ��Ĭ�����ã��е������룬˺�룬�ؾ�
    bBasePara.iPaperType := 3;            //����ֽ�����ͣ���Χ��0 --- 3���ֱ��ʾ��Ĭ�����ã�����ֽ���ڱ�ֽ����ǩֽ��
    bBasePara.iPrintMode := 0;            //���ô�ӡģʽ����Χ��0 --- 2���ֱ��ʾ��Ĭ�����ã�������ӡ����תӡ��ӡ��
    bBasePara.iAllRotateMode := 0;        //������תģʽ����Χ��0������ת��1����ת180�ȡ�
    bBasePara.iAllMirror := 0;            //�������徵�󣬷�Χ��0��������1������
    iResult := Set_BasePara(SNBCPrt.Comhwd, bBasePara, SizeOf(BaseParameter));
    if iResult <> SDK_SUCCESS then
    begin
      Result := Para_BaseParaErr;
      Exit;
    end;
  finally
    Dispose(BasePara(bBasePara));
  end;
  //���ó�ֽλ��
  iResult := Set_OutPosition(SNBCPrt.Comhwd, 112);
  if iResult <> SDK_SUCCESS then
  begin
    Result := Para_OutPosErr;
    Exit;
  end;
  //�����ǩģʽ
  iResult := Prt_EnterLabelMode(SNBCPrt.Comhwd, 0, 2000, 0, 0, 0, 20);
  if iResult <> SDK_SUCCESS then
  begin
    Result := Para_LabelModeErr;
    Exit;
  end;
  //Ʊ����������
  iResult := FileToLabelSetting(ADevType, ALabelFile, AExInfo);
  if iResult <> SDK_SUCCESS then
  begin
    Result := iResult;
    Exit
  end;
  //������ǩģʽ��������ӡ
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
        //��������������ʵ�ʿ��о���
        if iSize = 0 then
        begin
          iHeight := iHeight - Label_Size;
          Continue;
        end;
        //rightstr,��Ὣ������Ϊһ���ַ����н�ȡ��midstr���ַ����Ƚ�ȡ
        sTextMemo := MidStr(sLine, idx + 1, iSize);
        sLine := MidStr(sLine, 2, idx - 2);      
        slLabel.Delimiter := '+';
        slLabel.DelimitedText := sLine;
        GetMem(tTrueType.cText, iSize);
        CopyMemory(tTrueType.cText, PChar(sTextMemo), iSize);
        tTrueType.cText[iSize] := #0;
//        sLine := LeftStr(sLine, idx);        string��̬���䣬�˴����������һ�����Ľ������ַ���Sline�Ĳ������ڴ�ӡ������ǰ
//        Delete(sLine, 1, 1);
//        Delete(sLine, Length(sLine), 1);
        if slLabel.Count = 6 then
        begin
          tTrueType.iStartX := iWidth;
//          tTrueType.iStartY := iHeight;                     //�Ķ����ȶ������ӡ�ָ߶ȣ���ԭ�߶ȼ�ȥ�ָ߶�
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
      //�ޱ�ǩ��Ĭ�ϸ�ʽ
      else
      begin
        iSize := Length(sLine);
        //��������������ʵ�ʿ��о���
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
//    FreeMem(tTrueType.cText); //���һ���ַ�������ʱ��ָ�����
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

