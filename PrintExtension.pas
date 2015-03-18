unit PrintExtension;

interface
uses
  Windows;
var
  Com_Label, Com_ImageList: THandle;

{------------------------------------------BTP-L520��ӡ��-----------------------}
//��ӡ���ͺ�����
const
  Dev_Type_L520_5640 = 1;      //SNBC BTP-L520    560mm x 400mm
  Dev_Type_L520_3630 = 2;      //SNBC BTP-L520    360mm x 300mm
//��ӡ��״ֵ̬
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
//���ò���״ֵ̬
const
  Para_OK = 0;
  Para_BaseParaErr = -31;
  Para_OutPosErr = -32;
  Para_LabelModeErr = -33;
  Para_ContentErr = -34;
  Para_StartErr = -35;
  Para_ExpErr = -36;
//�رն˿�״ֵ̬
const
  Port_Close_OK = 0;
  Port_Close_Err = -41;
  Port_Close_Exp = -42;
//Ĭ������
type
  TFontIndex = (Fnt_SongTi, Fnt_HeiTi, Fnt_WRYH);
const
  FontSet: array[0..2] of packed record
    fIdx: Integer;
    fFontName: string;
  end =
  ((fIdx: Ord(Fnt_SongTi); fFontName: '����'),
   (fIdx: Ord(Fnt_HeiTi); fFontName: '����'),
   (fIdx: Ord(Fnt_WRYH); fFontName: '΢���ź�'));

type
  TPrintInfo = packed record
    Comhwd: Integer;
    DevName: string;
  end;

  TExInfo = packed record
    i: Integer;
  end;
  PExInfo = ^TExInfo;


{------------------------------------------��ӡ��λͼ����-----------------------}
{//����ֵ˵��
const
  POS_SUCCESS                 = 1001;// ����ִ�гɹ�
  POS_FAIL                    = 1002;// ����ִ��ʧ��
  POS_ERROR_INVALID_HANDLE    = 1101;// �˿ڻ��ļ��ľ����Ч
  POS_ERROR_INVALID_PARAMETER = 1102;// ������Ч
  POS_ERROR_NOT_BITMAP        = 1103;// ����λͼ��ʽ���ļ�
  POS_ERROR_NOT_MONO_BITMAP   = 1104;// λͼ���ǵ�ɫ��
  POS_ERROR_BEYONG_AREA       = 1105;// λͼ������ӡ�����Դ���Ĵ�С
  POS_ERROR_INVALID_PATH      = 1106;// û���ҵ�ָ�����ļ�·������
  POS_ERROR_FILE              = 1301;// ������ļ�
  //Params
  //����ͨѶ����ֹͣλ��
  POS_COM_ONESTOPBIT             = $00; //ֹͣλΪ1
  POS_COM_ONE5STOPBITS           = $01;  //ֹͣλΪ1.5
  POS_COM_TWOSTOPBITS            = $02;  //ֹͣλΪ2
  //ָ�����ڵ���żУ�鷽����
  POS_COM_NOPARITY               = $00;  //��У��
  POS_COM_ODDPARITY              = $01;  //��У��
  POS_COM_EVENPARITY             = $02;  //żУ��
  POS_COM_MARKPARITY             = $03;  //���У��
  POS_COM_SPACEPARITY            = $04;  //�ո�У��
  //ָ�����ڵ������ƣ����֣���ʽ�����ʾͨѶ��ʽ
  POS_COM_DTR_DSR                = $00; // ������ΪDTR/DST
  POS_COM_RTS_CTS                = $01; // ������ΪRTS/CTS
  POS_COM_XON_XOFF               = $02; // ������ΪXON/OFF
  POS_COM_NO_HANDSHAKE           = $03; // ������
  POS_OPEN_PARALLEL_PORT         = $12; // �򿪲���ͨѶ�˿�
  POS_OPEN_BYUSB_PORT            = $13; // ��USBͨѶ�˿�
  POS_OPEN_PRINTNAME             = $14; //�򿪴�ӡ����������
  POS_OPEN_NETPORT               = $15; // ����̫����ӡ��
  POS_FONT_TYPE_STANDARD         = $00; // ��׼ ASCII
  POS_FONT_TYPE_COMPRESSED       = $01; // ѹ�� ASCII
  POS_FONT_TYPE_UDC              = $02; // �û��Զ����ַ�
  POS_FONT_TYPE_CHINESE          = $03; // ��׼ �����塱
  POS_FONT_STYLE_NORMAL          = $00; // ����
  POS_FONT_STYLE_BOLD            = $08; // �Ӵ�
  POS_FONT_STYLE_THIN_UNDERLINE  = $80; // 1��ֵ��»���
  POS_FONT_STYLE_THICK_UNDERLINE = $100; // 2��ֵ��»���
  POS_FONT_STYLE_UPSIDEDOWN      = $200; // ���ã�ֻ��������Ч��
  POS_FONT_STYLE_REVERSE         = $400; // ���ԣ��ڵװ��֣�
  POS_FONT_STYLE_SMOOTH          = $800; // ƽ���������ڷŴ�ʱ��
  POS_FONT_STYLE_CLOCKWISE_90    = $1000; // ÿ���ַ�˳ʱ����ת 90 ��
  POS_PRINT_MODE_STANDARD        = $00; // ��׼ģʽ����ģʽ��
  POS_PRINT_MODE_PAGE            = $01; // ҳģʽ
  POS_PRINT_MODE_BLACK_MARK_LABEL = $02; // �ڱ�Ǳ�ǩģʽ
  POS_BARCODE_TYPE_UPC_A         = $41; // UPC-A
  POS_BARCODE_TYPE_UPC_E         = $42; // UPC-C
  POS_BARCODE_TYPE_JAN13         = $43; // JAN13(EAN13)
  POS_BARCODE_TYPE_JAN8          = $44; // JAN8(EAN8)
  POS_BARCODE_TYPE_CODE39        = $45; // CODE39
  POS_BARCODE_TYPE_ITF           = $46; // INTERLEAVED 2 OF 5
  POS_BARCODE_TYPE_CODEBAR       = $47; // CODEBAR
  POS_BARCODE_TYPE_CODE93        = $48; // 25
  POS_BARCODE_TYPE_CODE128       = $49; // CODE 128
  POS_HRI_POSITION_NONE          = $00; // ����ӡ
  POS_HRI_POSITION_ABOVE         = $01; // ֻ�������Ϸ���ӡ
  POS_HRI_POSITION_BELOW         = $02; // ֻ�������·���ӡ
  POS_HRI_POSITION_BOTH          = $03; // �����ϡ��·�����ӡ
  POS_BITMAP_PRINT_NORMAL        = $00; // ����
  POS_BITMAP_PRINT_DOUBLE_WIDTH  = $01; // ����
  POS_BITMAP_PRINT_DOUBLE_HEIGHT = $02; // ����
  POS_BITMAP_PRINT_QUADRUPLE     = $03; // �����ұ���
  POS_CUT_MODE_FULL              = $00; // ȫ��
  POS_CUT_MODE_PARTIAL           = $01; // ����
  POS_AREA_LEFT_TO_RIGHT         = $0; // ���Ͻ�
  POS_AREA_BOTTOM_TO_TOP         = $1; // ���½�
  POS_AREA_RIGHT_TO_LEFT         = $2; // ���½�
  POS_AREA_TOP_TO_BOTTOM         = $3; // ���Ͻ�

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


{***************************ֻ֧�ֱ�׼��ӡģʽ(��ģʽ)�ĺ���***********************}
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


{************************ֻ֧��ҳ��ӡģʽ(P)���ǩ��ӡģʽ(L)�ĺ���**********************************}
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


{*************************����--��Ҫ���ڵ��Ժ��Զ�����ƺ���ʹ��************************}
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
 