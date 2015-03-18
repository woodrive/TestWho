unit PrintExtension;

interface
uses
  Windows;
var
  Com_Label, Com_ImageList: THandle;

{------------------------------------------BTP-L520打印机-----------------------}
//打印机型号区分
const
  Dev_Type_L520_5640 = 1;      //SNBC BTP-L520    560mm x 400mm
  Dev_Type_L520_3630 = 2;      //SNBC BTP-L520    360mm x 300mm
//打印机状态值
const
  Prt_Status_OK = 0;
  Prt_Status_PIE = -21;     //paper is end
  Prt_Status_RIE = -22;     //Ribbon is end
  Prt_Status_DIB = -23;     //Device is busy
  Prt_Status_DIPS = -24;    //Device is pause status
  Prt_Status_DSCIE = -25;   //Device serial communication is error
  Prt_Status_TIH = -26;     //TPH is hotter
  Prt_Status_TIO = -27;     //TPH is opened
  Prt_Status_CIS = -28;     //Cutter is error
  Prt_status_Exp = -29;     //get status error
//设置参数状态值
const
  Para_OK = 0;
  Para_BaseParaErr = -31;
  Para_OutPosErr = -32;
  Para_LabelModeErr = -33;
  Para_ContentErr = -34;
  Para_StartErr = -35;
  Para_ExpErr = -36;
//关闭端口状态值
const
  Port_Close_OK = 0;
  Port_Close_Err = -41;
  Port_Close_Exp = -42;
//默认字体
type
  TFontIndex = (Fnt_SongTi, Fnt_HeiTi, Fnt_WRYH);
const
  FontSet: array[0..2] of packed record
    fIdx: Integer;
    fFontName: string;
  end =
  ((fIdx: Ord(Fnt_SongTi); fFontName: '宋体'),
   (fIdx: Ord(Fnt_HeiTi); fFontName: '黑体'),
   (fIdx: Ord(Fnt_WRYH); fFontName: '微软雅黑'));

type
  TPrintInfo = packed record
    Comhwd: Integer;
    DevName: string;
  end;

  TExInfo = packed record
    i: Integer;
  end;
  PExInfo = ^TExInfo;


{------------------------------------------打印机位图载入-----------------------}
{//返回值说明
const
  POS_SUCCESS                 = 1001;// 函数执行成功
  POS_FAIL                    = 1002;// 函数执行失败
  POS_ERROR_INVALID_HANDLE    = 1101;// 端口或文件的句柄无效
  POS_ERROR_INVALID_PARAMETER = 1102;// 参数无效
  POS_ERROR_NOT_BITMAP        = 1103;// 不是位图格式的文件
  POS_ERROR_NOT_MONO_BITMAP   = 1104;// 位图不是单色的
  POS_ERROR_BEYONG_AREA       = 1105;// 位图超出打印机可以处理的大小
  POS_ERROR_INVALID_PATH      = 1106;// 没有找到指定的文件路径或名
  POS_ERROR_FILE              = 1301;// 错误的文件
  //Params
  //串口通讯数据停止位数
  POS_COM_ONESTOPBIT             = $00; //停止位为1
  POS_COM_ONE5STOPBITS           = $01;  //停止位为1.5
  POS_COM_TWOSTOPBITS            = $02;  //停止位为2
  //指定串口的奇偶校验方法。
  POS_COM_NOPARITY               = $00;  //无校验
  POS_COM_ODDPARITY              = $01;  //奇校验
  POS_COM_EVENPARITY             = $02;  //偶校验
  POS_COM_MARKPARITY             = $03;  //标记校验
  POS_COM_SPACEPARITY            = $04;  //空格校验
  //指定串口的流控制（握手）方式、或表示通讯方式
  POS_COM_DTR_DSR                = $00; // 流控制为DTR/DST
  POS_COM_RTS_CTS                = $01; // 流控制为RTS/CTS
  POS_COM_XON_XOFF               = $02; // 流控制为XON/OFF
  POS_COM_NO_HANDSHAKE           = $03; // 无握手
  POS_OPEN_PARALLEL_PORT         = $12; // 打开并口通讯端口
  POS_OPEN_BYUSB_PORT            = $13; // 打开USB通讯端口
  POS_OPEN_PRINTNAME             = $14; //打开打印机驱动程序
  POS_OPEN_NETPORT               = $15; // 打开以太网打印机
  POS_FONT_TYPE_STANDARD         = $00; // 标准 ASCII
  POS_FONT_TYPE_COMPRESSED       = $01; // 压缩 ASCII
  POS_FONT_TYPE_UDC              = $02; // 用户自定义字符
  POS_FONT_TYPE_CHINESE          = $03; // 标准 “宋体”
  POS_FONT_STYLE_NORMAL          = $00; // 正常
  POS_FONT_STYLE_BOLD            = $08; // 加粗
  POS_FONT_STYLE_THIN_UNDERLINE  = $80; // 1点粗的下划线
  POS_FONT_STYLE_THICK_UNDERLINE = $100; // 2点粗的下划线
  POS_FONT_STYLE_UPSIDEDOWN      = $200; // 倒置（只在行首有效）
  POS_FONT_STYLE_REVERSE         = $400; // 反显（黑底白字）
  POS_FONT_STYLE_SMOOTH          = $800; // 平滑处理（用于放大时）
  POS_FONT_STYLE_CLOCKWISE_90    = $1000; // 每个字符顺时针旋转 90 度
  POS_PRINT_MODE_STANDARD        = $00; // 标准模式（行模式）
  POS_PRINT_MODE_PAGE            = $01; // 页模式
  POS_PRINT_MODE_BLACK_MARK_LABEL = $02; // 黑标记标签模式
  POS_BARCODE_TYPE_UPC_A         = $41; // UPC-A
  POS_BARCODE_TYPE_UPC_E         = $42; // UPC-C
  POS_BARCODE_TYPE_JAN13         = $43; // JAN13(EAN13)
  POS_BARCODE_TYPE_JAN8          = $44; // JAN8(EAN8)
  POS_BARCODE_TYPE_CODE39        = $45; // CODE39
  POS_BARCODE_TYPE_ITF           = $46; // INTERLEAVED 2 OF 5
  POS_BARCODE_TYPE_CODEBAR       = $47; // CODEBAR
  POS_BARCODE_TYPE_CODE93        = $48; // 25
  POS_BARCODE_TYPE_CODE128       = $49; // CODE 128
  POS_HRI_POSITION_NONE          = $00; // 不打印
  POS_HRI_POSITION_ABOVE         = $01; // 只在条码上方打印
  POS_HRI_POSITION_BELOW         = $02; // 只在条码下方打印
  POS_HRI_POSITION_BOTH          = $03; // 条码上、下方都打印
  POS_BITMAP_PRINT_NORMAL        = $00; // 正常
  POS_BITMAP_PRINT_DOUBLE_WIDTH  = $01; // 倍宽
  POS_BITMAP_PRINT_DOUBLE_HEIGHT = $02; // 倍高
  POS_BITMAP_PRINT_QUADRUPLE     = $03; // 倍宽且倍高
  POS_CUT_MODE_FULL              = $00; // 全切
  POS_CUT_MODE_PARTIAL           = $01; // 半切
  POS_AREA_LEFT_TO_RIGHT         = $0; // 左上角
  POS_AREA_BOTTOM_TO_TOP         = $1; // 左下角
  POS_AREA_RIGHT_TO_LEFT         = $2; // 右下角
  POS_AREA_TOP_TO_BOTTOM         = $3; // 右上角

type
  PArrStr = array of string;
  TArrStr = ^PArrStr;  }

//*********************************Api Function*******************************//
{//pos_open
  function POS_Open(lpName: PChar;nComBaudrate, nComDataBits, nComStopBits,
   nComParity, nParam: Integer): THandle; stdcall; external 'POSDLL.dll';

//pos_close
  function POS_Close(): Integer; stdcall; external 'POSDLL.dll';

//pos_reset
  function POS_Reset(): Integer; stdcall; external 'POSDLL.dll';

//pos_SetMode
  function POS_SetMode(nPrintMode: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_SetMotionUnit
  function POS_SetMotionUnit(nHorizontalMU, nVerticalMU: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_SetCharSetAndCodePage
  function POS_SetCharSetAndCodePage(nCharSet, nCodePage: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_FeedLine
  function POS_FeedLine(): Integer; stdcall; external 'POSDLL.dll';

//pos_SetLineSpacing
  function POS_SetLineSpacing(nDistance: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_SetRightSpacing
  function POS_SetRightSpacing(nDistance: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_PreDownLoadBmpToRam
  function POS_PreDownloadBmpToRAM(pszPath: PChar;nID: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_PreDownLoadBmpsToFlash
  function POS_PreDownloadBmpsToFlash(pszPaths: array of Pchar;nCount: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_QueryStatus
  function POS_QueryStatus(pszStatus: PChar;nTimeouts: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_RTQueryStatus
  function POS_RTQueryStatus(pszStatus: PChar): Integer; stdcall; external 'POSDLL.dll';

//pos_NetQueryStatus
  function POS_NETQueryStatus(ipAddress, pszStatus: PChar): Integer; stdcall; external 'POSDLL.dll';

//pos_KickOutDrawer
  function POS_KickOutDrawer(nID, nOnTimes, nOffTimes: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_CutPaper
  function POS_CutPaper(nMode, nDistance: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_StartDoc
  function POS_StartDoc(): Boolean; stdcall; external 'POSDLL.dll';

//pos_EndDoc
  function POS_EndDoc(): Boolean; stdcall; external 'POSDLL.dll';

//pos_EndSaveFile
  function POS_EndSaveFile(): Boolean; stdcall; external 'POSDLL.dll';

//pos_BeginSaveFile
  function POS_BeginSaveFile(lpFileName: PChar;bToPrinter: Boolean): Boolean; stdcall; external 'POSDLL.dll';   }


{***************************只支持标准打印模式(行模式)的函数***********************}
{//pos_S_SetAreaWidth
  function POS_S_SetAreaWidth(nWidth: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_S_TextOut
  function POS_S_TextOut(pszString: PChar;nOrgx, nWidthTimes, nHeightTimes, nFontType,
   nFontStyle: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_S_DownloadAndPrintBmp
  function POS_S_DownloadAndPrintBmp(pszPath: PChar;nOrgx, nMode: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_S_PrintBmpInRAM
  function POS_S_PrintBmpInRAM(nID, nOrgx, nMode: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_S_PrintBmpInFlash
  function POS_S_PrintBmpInFlash(nID, nOrgx, nMode: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_S_SetBarcode
  function POS_S_SetBarcode(pszInfoBuffer: PChar;nOrgx, nType, nWidthX, nHeight,
   nHriFontType, nHriFontPosition, nBytesToPrint: Integer): Integer; stdcall; external 'POSDLL.dll';    }


{************************只支持页打印模式(P)或标签打印模式(L)的函数**********************************}
{//pos_PL_SetArea
  function POS_PL_SetArea(nOrgx, nOrgy, nWidth, nHeight, nDirection: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_PL_TextOut
  function POS_PL_TextOut(pszString: PChar;nOrgx, nOrgy, nWidthTimes, nHeightTimes,
   nFontType, nFontStyle: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_PL_DownloadAndPrintBmp
  function POS_PL_DownloadAndPrintBmp(pszPath: PChar;nOrgx, nOrgy, nMode: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_Raster_DownloadAndPrintBmp
  function POS_Raster_DownloadAndPrintBmp(pszPath: PChar;nOrgx: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_Raster_DownloadAndPrintBmpEx
  function POS_Raster_DownloadAndPrintBmpEx(pszPath: PChar;nOrgx, nWidthMulti,
   nHeightMulti, nDensity: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_PL_PrintBmpInRAM
  function POS_PL_PrintBmpInRAM(nID, nOrgx, nOrgy, nMode: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_PL_SetBarcode
  function POS_PL_SetBarcode(pszInfoBuffer: PChar;nOrgx, nOrgy, nType, nWidthX,
   nHeight, nHriFontType, nHriFontPosition, nBytesToPrint: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_PL_Print
  function POS_PL_Print(): Integer; stdcall; external 'POSDLL.dll';

//pos_PL_Clear
  function POS_PL_Clear(): Integer; stdcall; external 'POSDLL.dll';   }


{*************************杂项--主要用于调试和自定义控制函数使用************************}
{//pos_WriteFile
  function POS_WriteFile(hPort: THandle;pszData: PChar;nBytesToWrite: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_ReadFile
  function POS_ReadFile(hPort: THandle;pszData: PChar;nBytesToRead, nTimeouts: Integer): Integer; stdcall; external 'POSDLL.dll';

//pos_SetHandle
  function POS_SetHandle(hNewHandle: THandle): THandle; stdcall; external 'POSDLL.dll';

//pos_GetVersionInfo
  function POS_GetVersionInfo(pnMajor, pnMinor: PChar): Integer; stdcall; external 'POSDLL.dll';
}

implementation

initialization
  Com_Label := LoadLibrary(PChar('bpladll.dll'));
  Com_ImageList := LoadLibrary(PChar('POSDLL.dll'));

finalization
  if Com_Label <> 0 then
    FreeLibrary(Com_Label);
  if Com_ImageList <> 0 then
    FreeLibrary(Com_Label);

end.
 