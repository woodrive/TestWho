unit BaseClass;
//********************基础类定义******************//
// TMySocket：Socket操作类；
// TMyComm  ：串 口 操作类;
// Create by wyh 2004.02.29

interface

uses
  Windows, Forms, WinSock, SysUtils, Classes, Math;

const
  CommInQueSize  = 2048;     //TMyComm:输入缓冲区大小
  CommOutQueSize = 2048;     //TMyComm:输出缓冲区大小

  dcb_Binary              = $00000001;
  dcb_ParityCheck         = $00000002; 
  dcb_OutxCtsFlow         = $00000004; 
  dcb_OutxDsrFlow         = $00000008; 
  dcb_DtrControlMask      = $00000030; 
  dcb_DtrControlDisable   = $00000000; 
  dcb_DtrControlEnable    = $00000010; 
  dcb_DtrControlHandshake = $00000020; 
  dcb_DsrSensitvity       = $00000040; 
  dcb_TXContinueOnXoff    = $00000080; 
  dcb_OutX                = $00000100; 
  dcb_InX                 = $00000200; 
  dcb_ErrorChar           = $00000400;
  dcb_NullStrip           = $00000800;
  dcb_RtsControlMask      = $00003000;
  dcb_RtsControlDisable   = $00000000;
  dcb_RtsControlEnable    = $00001000;
  dcb_RtsControlHandshake = $00002000;
  dcb_RtsControlToggle    = $00003000;
  dcb_AbortOnError        = $00004000;
  dcb_Reserveds           = $FFFF8000;

type
  TMySocket = class
    FConnect: Boolean;
  private
    FSocket: integer;
    FServer: sockaddr_in;
    FWSAInit: Boolean;
  public
    constructor Create(addr: String; port: Word; msec: integer; nodelay: Boolean);
    destructor Destroy; override;
    function Read(buffer: Pointer; len: Word): Word;   //读函数
    function Write(buffer: Pointer; len: Word): Word;  //写函数
    function FSelect(ReadReady, WriteReady, ExceptFlag: PBoolean; TimeOut: Integer): Boolean; //监控事件
    function WaitFor(TimeOut: Integer; Flag: Integer): Boolean;  //等待超时
    procedure Discard; //清空接受缓存区
  end;

  TMyComm = class  //MyComm := TMyComm.Create('COM1',9600,'N',8,1,true);
    OpenFlag: Boolean;
  private
    CommHandle: THandle;
  protected
    procedure OpenComm(Com: string; Bps: longint; Par: char; Dbit, Sbit: byte; Retry: Boolean; Hint: Boolean = true);  //打开并初始化串口
    procedure CloseComm; //关闭串口
  public
    constructor Create(Com:string; Bps: longint; Par: char; Dbit, Sbit: byte; Retry: Boolean; Hint: Boolean = true);
    destructor Destroy; override;
    function InbufComm: dword; //返回输入缓冲区中的字符数
    function OutBufComm: dword; //返回输出缓冲区中的字符数
    function Send(var buf; len: dword): boolean; //写串口 buf:存放要写的数据，len:数据长度
    function Recv(var buf; len: dword; timeout: Cardinal): boolean; //读串口
    function PutChar(ch: char): boolean; //向串口发一个字符
    function PutStr(s: string): boolean; //向串口发一个字符串
    function PutStrA(s: string): boolean; //向串口发一个字符串数组,以2048为限
    function GetChar(ch: Char; timeout: Cardinal): boolean; //从串口读一个字符，未收到字符则返回#0
    function GetStr(var Str: string; timeout: Cardinal): boolean; //从串口取一个字符串，忽略不可见字符,收到#13或1000个字符结束
    procedure ClearBuf(flag: Boolean); //清缓冲区
  end;

implementation

// Mysocket
constructor TMySocket.Create(addr: String; port: Word; msec: integer; nodelay: Boolean);
var
  fNodelay,fDONTLINGER: Bool;
  fFIONBIO: u_long;
  fConnectRtn: Integer;
  fWSAData: TWSAData;
begin
  inherited Create;
  FConnect := false;
  FWSAInit := true;
  fNodelay := true;   //小数据包发送不延迟
  fDONTLINGER := true;//Do not block close waiting for unsent data to be sent.
  fFIONBIO := 1;      //先置Socket为非阻塞模式,控制connect超时时间

  if WSAStartup(MakeWord(2, 0), fWSAData) <> 0 then
    if WSAStartup(MakeWord(1, 1), fWSAData) <> 0 then
    begin
      FWSAInit := false;
      Exit;
    end;

  FSocket := Socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if FSocket >= 0 then
  begin
    FServer.sin_family := AF_INET;
    FServer.sin_addr.S_addr := inet_addr(PChar(addr));
    FServer.sin_port := htons(port);

    if nodelay then  //非阻塞->阻塞模式
    begin
      if ioctlsocket(FSocket, FIONBIO, fFIONBIO) = 0 then //置Socket为非阻塞模式成功
      begin
        fConnectRtn := Connect(FSocket, FServer, Sizeof(FServer));
        if (fConnectRtn = SOCKET_ERROR) and (WSAGetLastError <> WSAEWOULDBLOCK) then
        begin
          CloseSocket(FSocket);
          Exit;
        end;
        if WaitFor(Msec, 1) then // select 写操作
        begin
          fFIONBIO := 0;
          if ioctlsocket(FSocket, FIONBIO, fFIONBIO) = 0 then // 置Socket为阻塞模式成功
          begin
            SetSockopt(FSocket, SOL_SOCKET, SO_DONTLINGER, PChar(@fDONTLINGER), Sizeof(fDONTLINGER));
            SetSockopt(FSocket, IPPROTO_TCP, TCP_NODELAY, PChar(@fNodelay), Sizeof(fNodelay));
            FConnect := true;
          end
          else
            CloseSocket(FSocket);
        end
        else
          CloseSocket(FSocket);
      end
      else
        CloseSocket(FSocket);
    end
    else  //阻塞模式
    begin
      SetSockopt(FSocket, SOL_SOCKET, SO_DONTLINGER, PChar(@fDONTLINGER), Sizeof(fDONTLINGER));
      SetSockopt(FSocket, IPPROTO_TCP, TCP_NODELAY, PChar(@fNodelay), Sizeof(fNodelay));
      if Connect(FSocket, FServer, Sizeof(FServer)) = 0 then
        FConnect := true
      else
        CloseSocket(FSocket);
    end;
  end;
end;

destructor TMySocket.Destroy;
begin
  if FConnect then
  begin
    ShutDown(FSocket, SD_BOTH);
    CloseSocket(FSocket);
  end;
  if FWSAInit then WSACleanup;
  inherited;
end;

function TMySocket.Read(buffer: Pointer; len: Word): Word;
var
  n,m: Word;
begin
  result := 0;
  n := 0;
  if FConnect then
  begin
    while n < len do
    begin
      m := recv(FSocket, pchar(buffer)^, len - n, 0);
      if m > 0 then
      begin
        inc(Pchar(buffer), m);
        n := n + m;
      end
      else
        exit;
    end;
    result := n;
  end;
end;

function TMySocket.Write(buffer: Pointer; len: Word): Word;
var
  n,m: Word;
begin
  result := 0;
  n := 0;
  if FConnect then
  begin
    while n < len do
    begin
      m := send(FSocket, pchar(buffer)^, len - n, 0);
      if m > 0 then
      begin
        inc(Pchar(buffer), m);
        n := n + m;
      end
      else
        exit;
    end;
    result := n;
  end;
end;

function TMySocket.FSelect(ReadReady, WriteReady, ExceptFlag: PBoolean; TimeOut: Integer): Boolean;
var
  ReadFds: TFDset;
  ReadFdsptr: PFDset;
  WriteFds: TFDset;
  WriteFdsptr: PFDset;
  ExceptFds: TFDset;
  ExceptFdsptr: PFDset;
  tv: timeval;
  Timeptr: PTimeval;
begin
  Result := False;
  if FSocket >= 0 then
  begin
    if Assigned(ReadReady) then
    begin
      ReadFdsptr := @ReadFds;
      FD_ZERO(ReadFds);
      FD_SET(FSocket, ReadFds);
    end
    else
      ReadFdsptr := nil;
    if Assigned(WriteReady) then
    begin
      WriteFdsptr := @WriteFds;
      FD_ZERO(WriteFds);
      FD_SET(FSocket, WriteFds);
    end
    else
      WriteFdsptr := nil;
    if Assigned(ExceptFlag) then
    begin
      ExceptFdsptr := @ExceptFds;
      FD_ZERO(ExceptFds);
      FD_SET(FSocket, ExceptFds);
    end
    else
      ExceptFdsptr := nil;
    if TimeOut >= 0 then
    begin
      tv.tv_sec := TimeOut div 1000;
      tv.tv_usec :=  1000 * (TimeOut mod 1000);
      Timeptr := @tv;
    end
    else
      Timeptr := nil;
    try
      Result := Select(FSocket + 1, ReadFdsptr, WriteFdsptr, ExceptFdsptr, Timeptr) > 0;
    except
      Result := False;
    end;
    if Assigned(ReadReady) then
      ReadReady^ := FD_ISSET(FSocket, ReadFds);
    if Assigned(WriteReady) then
      WriteReady^ := FD_ISSET(FSocket, WriteFds);
    if Assigned(ExceptFlag) then
      ExceptFlag^ := FD_ISSET(FSocket, ExceptFds);
  end;
end;

function TMySocket.WaitFor(TimeOut: Integer; Flag: Integer): Boolean;
var
  ReadReady,WriteReady: Boolean;
  c: Char;
begin
  result := false;
  case flag of
    0: //read
    begin
      if FSelect(@ReadReady, nil, nil, TimeOut) then
        result := ReadReady and (recv(FSocket, c, sizeof(c), MSG_PEEK) = 1);
    end;
    1: //write
    begin
      if FSelect(nil, @WriteReady, nil, TimeOut) then
        result := WriteReady ;
    end;
  end;
end;

procedure TMySocket.Discard;
var
  len: Word;
  Chr: Char;
begin
  len := 0;
  Chr := #0;
  if FConnect then Recv(FSocket, Chr, len, 0);
end;

{串口操作类}
constructor TMyComm.Create(Com: string; Bps: longint; Par: char; Dbit, Sbit: byte; Retry: Boolean; Hint: Boolean);
begin
  inherited Create;
  OpenComm(Com, Bps, Par, Dbit, Sbit, Retry, Hint);
end;

destructor TMyComm.Destroy;
begin
  CloseComm;
  inherited;
end;

function TMyComm.InBufComm: dword;
var
  ErrCode: DWord;
  Stat: TComStat;
begin
  result := 0;
  if not OpenFlag then exit;
  ClearCommError(CommHandle, ErrCode, @Stat);
  result := Stat.cbInQue;
end;

function TMyComm.OutBufComm: dword;
var
  ErrCode: DWord;
  Stat: TCOMSTAT;
begin
  result := 0;
  if not OpenFlag then exit;
  ClearCommError(CommHandle, ErrCode, @Stat);
  result := Stat.cbOutQue;
end;

procedure TMyComm.OpenComm(Com: String; Bps: longint; Par: Char; Dbit, Sbit: byte; Retry: Boolean; Hint: Boolean);
var
  CommTimeOut: TCOMMTIMEOUTS;
  DCB: TDCB;
begin
  OpenFlag := false;
  CommHandle := CreateFile(PChar(Com), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if CommHandle = INVALID_HANDLE_VALUE then
  begin
    if Hint then Application.Messagebox(PChar('无法打开串口[ ' + Com + ' ],请通知相关技术部门！'), '系统提示', MB_ICONWARNING);
    Exit;
  end;
  GetCommTimeouts(CommHandle, CommTimeOut);
  CommTimeOut.ReadIntervalTimeout := MAXDWORD;
  CommTimeOut.ReadTotalTimeoutMultiplier := 0;
  CommTimeOut.ReadTotalTimeoutConstant := 0;
  CommTimeOut.WriteTotalTimeoutMultiplier := 0;
  CommTimeOut.WriteTotalTimeoutConstant := 0;
  SetCommTimeouts(CommHandle, CommTimeOut);

  GetCommState(CommHandle, DCB);
  with DCB do
  begin
    case Bps of    //波特率  CBR_9600
      110: BaudRate := CBR_110;
      300: BaudRate := CBR_300;
      600: BaudRate := CBR_600;
      1200: BaudRate := CBR_1200;
      2400: BaudRate := CBR_2400;
      4800: BaudRate := CBR_4800;
      9600: BaudRate := CBR_9600;
      14400: BaudRate := CBR_14400;
      19200: BaudRate := CBR_19200;
      38400: BaudRate := CBR_38400;
      56000: BaudRate := CBR_56000;
      57600: BaudRate := CBR_57600;
      115200: BaudRate := CBR_115200;
      128000: BaudRate := CBR_128000;
      256000: BaudRate := CBR_256000;
    end;
    case Par of                     //校验位
      'n','N': Parity := NOPARITY;    //no
      'o','O': Parity := ODDPARITY;   //odd
      'e','E': Parity := EVENPARITY;  //even
      'm','M': Parity := MARKPARITY;  //mark
      's','S': Parity := SPACEPARITY; //space
      else     Parity := NOPARITY;    //no
    end;
    if Dbit in [4, 5, 6, 7, 8] then     //数据位
      ByteSize := dbit
    else
      ByteSize := 8;
    case Sbit of                    // 停止位
      1: StopBits := ONESTOPBIT;     // 1
      2: StopBits := TWOSTOPBITS;    // 2
      else StopBits := ONE5STOPBITS; // 1.5
    end;
    if Retry then Flags := Flags or dcb_OutxCtsFlow or dcb_RtsControlHandshake; //改变握手模式为硬件控制模式
  end;
  if SetCommState(CommHandle, DCB) then
  begin
    SetupComm(CommHandle, CommOutQueSize, CommInQueSize);
    //清空输入输出缓存区
    PurgeComm(CommHandle, PURGE_TXABORT or PURGE_RXABORT or PURGE_TXCLEAR or PURGE_RXCLEAR);
    OpenFlag := true;
  end
  else
    CloseHandle(CommHandle);
end;

procedure TMyComm.CloseComm;
begin
  if OpenFlag then CloseHandle(CommHandle);
  OpenFlag := false;
end;

procedure TMyComm.ClearBuf(flag: Boolean);
begin
  if not OpenFlag then exit;
  if flag then // true: 清接受缓存区
    PurgeComm(CommHandle, PURGE_RXCLEAR)  //Clears the input buffer
  else
    PurgeComm(CommHandle, PURGE_TXCLEAR); //Clears the output buffer
end;

function TMyComm.Send(var buf; len: dword): boolean;
var
  i: dword;
begin
  result := false;
  if not OpenFlag then exit;
  while len > 0 do
  begin
    if WriteFile(CommHandle, Buf, len, i, nil) then  //写串口
    begin
      len := len - i;
      result := true;
    end
    else
    begin
      result := false;
      Break;
    end;
  end;
end;

function TMyComm.Recv(var buf; len: dword; timeout: Cardinal): boolean;
var
  i: dword;
  oldtime: Cardinal;
begin
  result := false;
  if not OpenFlag then exit;
  oldtime := GetTickCount;
  repeat until (GetTickCount - oldtime >= timeout) or (InbufComm >= len);
  len := min(len, InbufComm);
  if ReadFile(CommHandle, Buf, len, i, nil) then result := true;
end;

function TMyComm.PutChar(ch: char): boolean;
begin
  if Send(ch, 1) then
    result := true
  else
    result := false;
end;

function TMyComm.PutStr(s: string): boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to Length(s) do
  begin
    if not PutChar(s[i]) then
    begin
      result := false;
      Break;
    end;
  end;
end;

function TMyComm.PutStrA(s: string): boolean;
var
  i: integer;
  a: array[0..2048] of char;
begin
  if Length(s) < 2048 then
  begin
    for i := 1 to Length(s) do a[i - 1] := s[i];
    Result := Send(a, Length(s));
  end
  else
    result := PutStr(s);
end;

function TMyComm.GetChar(ch: Char; timeout: Cardinal): boolean;
begin
  if Recv(ch, 1, timeout) then
    result := true
  else
    result := false;
end;

function TMyComm.GetStr(var Str: string; timeout: Cardinal): boolean;
var
  ch: Char;
begin
  ch := #0;
  Str := #0;
  result := false;
  while true do
  begin
    if not GetChar(ch, timeout) then
    begin
      result := false;
      Break;
    end;
    if ch >= #32 then Str := Str + ch;
    if (ch = #13) or (Length(str) > 1000) then
    begin
      result := true;
      Break;
    end;
  end;
end;

end.
