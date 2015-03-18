unit PrintImageUnit;

interface
uses
  Windows, PrintExtension, StrUtils, SysUtils, Classes, BaseClass, Graphics,
  Math;

  //ABmpImageList: 图片名称列表 分隔符'|'
  //APortName: 端口名称
  //返回值: integer

  function POS_LoadImageListExt(AComm: TMyComm;APrintName, APortName, ABmpImageList: PChar): Integer; stdcall;

  {//打开端口
  function POS_OpenPort(APortName: string): THandle; stdcall;
  //关闭端口
  function POS_ClosePort(): Integer; stdcall;
  //print
  function POS_Print(): Integer; stdcall; }
  //IBM4610
  function POS_LoadImage_IBM(AComm: TMyComm;ABmpImageList: array of PChar): Boolean;
  //EPSON TM88/PT900TA/HKP600T
  function POS_LoadImage_EPSON(AComm: TMyComm;APortName: PChar;ABmpImageList: array of PChar): Boolean;
  //
  function ParsePixel(InPixel: Integer): String;


implementation

function POS_LoadImageListExt(AComm: TMyComm;APrintName, APortName, ABmpImageList: PChar): Integer; stdcall;
var
  wArrBmp: array of Pchar;
  wSL: TStringList;
  i: Integer;
begin
  Result := -1;
//    if wPOSHandle <> INVALID_HANDLE_VALUE then

      //截取图像文件名
  wSL := TStringList.Create;
  try
//        wSL.Delimiter := ';';
//        wSL.DelimitedText := StrPas(ABmpImageList);
//        iResult := Pos(';', ABmpImageList);
//        wStr := MidStr(ABmpImageList, 1, iResult);     //空格被当作一个分隔符
    ExtractStrings(['|'], [], ABmpImageList, wSL);
    if wSL.Count <= 0 then Exit;
    //原因不详，初始化长度+1   调用新北洋动态库bmp写入传参列表+1
//    SetLength(wArrBmp, wSL.Count + 1);
    SetLength(wArrBmp, wSL.Count);
    for i := 0 to wSL.Count - 1 do
    begin
      wArrBmp[i] := PChar(wSL.Strings[i]);
    end;
    if APrintName = 'IBM4610' then
    begin
      POS_LoadImage_IBM(AComm, wArrBmp);
      Result := 0;
    end
    else if (APrintName = 'TM88') or (APrintName = 'PT900TA')  or (APrintName = 'HKP600T') then
    begin
      POS_LoadImage_EPSON(AComm, APortName, wArrBmp);
      Result := 0;
    end;
//        iResult := POS_PreDownloadBmpsToFlash(wArrBmp, wSL.Count);
  finally
    wSL.Free;
  end;
end;

{function POS_OpenPort(APortName: string): THandle; stdcall;
var
  iComBaudrate, iComDataBits, iComStopBits, iComParity, iParam: Integer;
begin
  if Pos('COM', APortName) > 0 then
  begin
    iComBaudrate := 9600;  //指定串口的波特率（bps）。 2400，4800，9600，19200，38400，57600，115200等。
    iComDataBits := 7;  //指定串口通讯时的数据位数。5 到 8。
    iComStopBits := POS_COM_ONESTOPBIT;  //指定串口通讯时的数据停止位数。
    iComParity := POS_COM_ODDPARITY;  //指定串口的奇偶校验方法。
    iParam := POS_COM_RTS_CTS;  //指定串口的流控制（握手）方式、或表示通讯方式。
    Result := POS_Open(PChar(APortName), iComBaudrate, iComDataBits, iComStopBits,
      iComParity, iParam);
  end
  else if Pos('LPT', APortName) > 0 then
  begin
    iComBaudrate := 0;
    iComDataBits := 0;
    iComStopBits := 0;
    iComParity := 0;
    iParam := POS_OPEN_PARALLEL_PORT;
    Result := POS_Open(PChar(APortName), iComBaudrate, iComDataBits, iComStopBits,
      iComParity, iParam);
  end
  else if Pos('USB', APortName) > 0 then
  begin
    iComBaudrate := 0;
    iComDataBits := 0;
    iComStopBits := 0;
    iComParity :=0;
    iParam := POS_OPEN_BYUSB_PORT;
    Result := POS_Open(PChar(APortName), iComBaudrate, iComDataBits, iComStopBits,
      iComParity, iParam);
  end
  else
    Result := INVALID_HANDLE_VALUE;
end;

function POS_ClosePort(): Integer; stdcall;
begin
  Result := POS_Close;
end;

function POS_Print(): Integer; stdcall;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to 4 do
  begin
    POS_S_PrintBmpInFlash(i, 0, $00);
  end;
  POS_FeedLine;
  POS_FeedLine;
  POS_FeedLine;
  POS_FeedLine;
  POS_FeedLine;
  POS_CutPaper($00, 0);
end;}

function POS_LoadImage_IBM(AComm: TMyComm;ABmpImageList: array of PChar): Boolean;
var

  BM: TBitmap;
  i, w, h, L9, b, index: integer;
  s, s0, s1, Data: string;
begin
  Result := False;
  for index := 0 to Length(ABmpImageList) - 1 do
  begin
    BM := TBitmap.Create;
    try
      s := '';
      s0 := '';
      s1 := '';

      BM.LoadFromFile(ABmpImageList[index]);

      w := BM.Width Div 8;
      h := BM.Height Div 8;

      SetLength(Data, w);

      for L9 := 0 to BM.Height - 1 do
      begin
        Move(BM.ScanLine[L9]^, Data[1], w);

        for i := 1 to w do
        begin
          b := byte(Data[i]) xor $FF;
          s := s + char(b);
        end;
      end;
    finally
      BM.Free;
    end;

    if AComm.OpenFlag then
    begin
      AComm.PutStr(Char($1D) + Char($2A) + Char(StrToInt('$' + IntToHex(index + 1, 2))) +          //循环写入对应存储位
         Char(StrToInt('$' + IntToHex(w, 2))) + Char(StrToInt('$' + IntToHex(h, 2))) + s);
      Result := true;
    end;
  end;
end;
  //EPSON
function POS_LoadImage_EPSON(AComm: TMyComm;APortName: PChar;ABmpImageList: array of PChar): Boolean;
var
  fp: textfile;
  IsLpt: Boolean;
  BM: TBitmap;
  i, j, k, w, h, L9, b, index: integer;
  s, s0, s1, Data, sTemp: string;

  ii: array of array of integer;
begin
  Result := False;     
  sTemp := '';
  for index := 0 to Length(ABmpImageList) - 1 do
  begin
    BM := TBitmap.Create;
    try
      s := '';
      s0 := '';
      s1 := '';
      BM.LoadFromFile(ABmpImageList[index]);

      w := BM.Width Div 8;
      h := BM.Height Div 8;

      SetLength(Data, w);
      //EPSON,HISENSE
      SetLength(ii, 8 * w, 8 * h);

      for L9 := 0 to BM.Height - 1 do
      begin
        Move(BM.ScanLine[L9]^, Data[1], w);

        for i := 1 to w do
        begin
          b := byte(Data[i]) xor $FF;
          s := s + char(b);
        end;
      end;

      //
      for L9 := 0 To 8 * h - 1 Do
      begin
        Move(BM.ScanLine[L9]^, Data[1], w);
        for i := 1 to w do
        begin
          b := byte(Data[i]) xor $FF;
          s0 := ParsePixel(b);
          for j := 1 to 8 do
          begin
            ii[8 * (i - 1) + j - 1, L9] := StrToInt(s0[j]);
          end;
        end;
      end;
      for i := 1 to 8 * w do
      begin
        for j := 1 to h do
        begin
          b := 0;
          for k := 7 downto 0 do b := b + Trunc(IntPower(2, k)) * ii[i - 1, 8 * (j - 1) + 7 - k];
          s1 := s1 + Char(StrToInt('$' + IntToHex(b, 2)));
        end;
      end;
      //Hex		1C		71		n		[xL xH yL yH d1...dk]1 ... [xL xH yL yH d1...dk]n
      //https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=90
      //char(strtoint('$' + inttohex(integer('['), 2)))
      s1 := Char(w mod 256) + Char(w div 256) + Char(h mod 256) + Char(h div 256) + s1;
    finally
      BM.Free;
    end;
    sTemp := sTemp + s1;
  end;


  IsLpt := false;
  if Pos('LPT', APortName) > 0 then
  begin
    IsLpt := True;
    AssignFile(fp, PChar(APortName));
    Rewrite(fp);
  end;

  if (not IsLpt) and AComm.OpenFlag then
  begin
//    if (P_PrintType = 'TM88') or (P_PrintType = 'PT900TA')  or (P_PrintType = 'HKP600T') then
    begin
      AComm.PutStr(char($1C) + char($71) + Char(Length(ABmpImageList)) + sTemp);
      Result := true;
    end;
  end
  else if IsLpt then
  begin
//    if (P_PrintType = 'TM88') or (P_PrintType = 'PT900TA')  or (P_PrintType = 'HKP600T') then
    begin
      Writeln(fp, char($1C) + char($71) + Char(Length(ABmpImageList)) + sTemp);
      Result := true;
    end;
  end;

  if IsLpt then  // 并口打印机
  begin
    Flush(fp);
    CloseFile(fp);
  end;
end;

function ParsePixel(InPixel: Integer): String;
var
  Bit: array[0..7] of Integer;
  temp,i: Integer;
begin
  Result := '00000000'; //白点

  Bit[0] := 1;
  Bit[1] := 2;
  Bit[2] := 4;
  Bit[3] := 8;
  Bit[4] := 16;
  Bit[5] := 32;
  Bit[6] := 64;
  Bit[7] := 128;

  temp := InPixel;
  if (temp > 0) and (temp <= 255) then
  begin
  while temp >= 0 do
    begin
      for i := 7 downto 0 do
      begin
        if temp >= Bit[i] then
        begin
          temp := temp - Bit[i];
          Result := Copy(Result, 1, 7 - i) + '1' + Copy(Result, 8 - i + 1, i);
          if temp = 0 then temp := -1;
          Break;
        end;
      end;
    end;
  end;
end;

end.
