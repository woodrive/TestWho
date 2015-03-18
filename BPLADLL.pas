unit BPLADLL;

interface
uses
   Windows, PrintExtension;

// port type

Const PORT_SERIAL    = 1;
Const PORT_PARALLEL  = 2;
Const PORT_USBDEVICE = 3;
Const PORT_ETHERNET  = 4;
Const PORT_DRIVER    = 5;

// code of return value

Const SDK_SUCCESS		           = 0 ;
Const ERR_HANDLE			         = -1;
Const ERR_PARAMETER			       = -2;
Const ERR_APIFUNCTION			     = -3;
Const ERR_TIMEOUT			         = -4;
Const ERR_OPENFILE			       = -5;
Const ERR_READFILE			       = -6;
Const ERR_WRITEFILE			       = -7;
Const ERR_OUTBOUND			       = -8;
Const ERR_LOADDLLFILE			     = -9;
Const ERR_LOADDLLFUNCTION	     = -10;
Const ERR_DOWNLOADFILECLASH		 = -11;
Const ERR_DOWNLOADFILE			   = -12;
Const ERR_NOFLASH			         = -13;
Const ERR_NORAM			           = -14;
Const ERR_IMAGETYPE			       = -15;
Const ERR_BARCODE_PERCENTAGE	 = -16;
Const ERR_BARCODE_CHARACTEROUT = -17;
Const ERR_NOTSUPPORT				   = -18;
Const ERR_NOFILENAME           = -19;
Const ERR_BUFFERERROR          = -20;

//label printing commands

Const PRINT_LINE                 = 1;
Const PRINT_BOX                  = 2;
Const PRINT_CIRCLE               = 3;
Const PRINT_INNERFONT            = 4;
Const PRINT_DOWNLOADINGFONT      = 5;
Const PRINT_MIXFONT              = 6;
Const PRINT_CODE_39              = 7;
Const PRINT_CODE_UPCA            = 8;
Const PRINT_CODE_UPCE            = 9;
Const PRINT_CODE_NOVERIFY25      = 10;
Const PRINT_CODE_128             = 11;
Const PRINT_CODE_ENA13           = 12;
Const PRINT_CODE_ENA8            = 13;
Const PRINT_CODE_HBIC            = 14;
Const PRINT_CODE_CODABAR         = 15;
Const PRINT_CODE_VERIFY25        = 16;
Const PRINT_CODE_INDUSTRY25      = 17;
Const PRINT_CODE_TRANSPORT       = 18;
Const PRINT_CODE_UPC2            = 19;
Const PRINT_CODE_UPC5            = 20;
Const PRINT_CODE_93              = 21;
Const PRINT_CODE_POSTNET         = 22;
Const PRINT_CODE_UCCENA          = 23;
Const PRINT_CODE_EUROPE25        = 24;
Const PRINT_CODE_JAPAN25         = 25;
Const PRINT_CODE_CHINA25         = 26;
Const PRINT_PDF                  = 27;
Const PRINT_QR                   = 28;
Const PRINT_MAXI                 = 29;
Const PRINT_IMAGE                = 30;
Const PRINT_DOWNLOADINGIMAGE     = 31;
Const PRINT_GRAYIMAGE            = 32;
Const PRINT_TREUTYPE             = 33;
Const PRINT_GM                   = 34;


// serial port struct

type
COMSetting = packed record
  cPortName:array [1..32] of char;   //serial port name, spec: COM1, COM2 ... COM10, COM11, and so on.
  iBaudrate:integer;        //bits per second, spec: 9600, 19200, 38400, 57600, and 115200.
  iDataBits:integer;        //data bits, spec: 7 or 8.
	iStopBits:integer;        //stop bits, spec: 1 or 2.
	iParity:integer;          //Parity, spec: 0: None, 1: Odd, 2: Even.
	iFlowControl:integer;     //Flow control, spec: 0: DTR/DSR, 1: RTS/CTS, 2: Xon/Xoff, 3: None.
	iCheckEnable:integer;     //enable of checking communication, spec: 0: not check communication, 1: check communication.
	iCheckTimeout:integer;    //set time out of checking communication, spec: iCheckEnable = 1, iCheckTimeout is valid.
end;
COMPara = ^COMSetting;


// parallel port struct

type
LPTSetting  = packed record
	cPortName:array [1..32] of char;  //parallel port name, spec: LPT1, LPT2, and so on.
end;
LPTPara = ^LPTSetting;


// Ethernet port struct

type
NETSetting = packed record
	cIPAddr:array [1..40] of char;   //IP address
	iNetPort:integer;                //port
end;
NetPara = ^NETSetting;

// driver struct

type
DrvSetting = packed record
	cDrvName:array [1..64] of char; //driver name
end;
DrvPara = ^DrvSetting;

// USB port struct

type
USBSetting = packed record
	iUSBMode:integer;       //USB mode setting, spec: 0---API mode USB, 1---class mode USB.
	iDevID:integer;         //device ID,        spec: iDevID >= 0, iDevID express device internal ID, open usb port by internasl ID; iDevID < 0, open usb port.
	cDevName:array [1..64] of char; //device name,      spec: iUSBMode = 2, cDevName express class mode USB device name.
end;
USBPara = ^USBSetting;


// base parameter struct

type
BaseParameter = packed record
	iDPI:integer;            //device DPI,             spec: 0 (default setting (200 DPI)), 1 (200DPI), 2 (300DPI).
	iUnit:integer;           //device setting unit,    spec: 0 (default setting(millimeter/10)), 1 (millimeter/10), 2 (dot), 3 (inch/100).
	iOutMode:integer;        //paper present mode,     spec: 0 (default setting of EEPROM), 1 (cutter), 2 (peel off), 3 (tear off), 4 (rewind).
	iPaperType:integer;      //paper type,             spec: 0 (default setting of EEPROM), 1 (continuous paper),2 (mark paper), 3 (transmission label paper).
	iPrintMode:integer;      //print method,		   spec: 0 (default setting of EEPROM), 1 (thermal), 2 (thermal transfer).
	iAllRotateMode:integer;  //set rotary print,       spec: 0 (switch off 180 degree rotary printing), 1 (Switch on the rotary printing).
	iAllMirror:integer;      //set mirror image print, spec: 0 (not setting), 1 (set mirror image print).
end;
BasePara = ^BaseParameter;

// line printing struct

type
LineSetting = packed record

	iStartX:integer;         //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;         //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iEndX:integer;           //end X-coordinate,   spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iEndY:integer;           //end Y-coordinate,   spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iLineWidth:integer;      //line width,         spec: 0 --- 999, unit: dot.
end;
LinePrintPara = ^LineSetting;

// box printing struct

type
BoxSetting = packed record
	iStartX:integer;         //start X-coordinate,      spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;         //start Y-coordinate,      spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iWidth:integer;          //horizontal width of box, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iHeight:integer;         //vertical height of box,  spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iHorizontal:integer;     //thickness of right and left box edge, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iVertical:integer;       //thickness of bottom and top box edge, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
end;
BoxPrintPara = ^BoxSetting;

// circle printing struct

type
CircleSetting = packed record
	iCenterX:integer;        //the center X-coordinate of a circle, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iCenterY:integer;        //the center Y-coordinate of a circle, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRadius:integer;         //radius,         spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iLineWidth:integer;      //edge thickness, spec: 0 --- 999, unit: dot.
end;
CirclePrintPara = ^CircleSetting;

// downloading image printing struct

type
DownLoadingImageSetting = packed record

	cImageName:array [1..8] of char;   //bitmap name of memory module,  spec: Max 8 characters.
	iStartX:integer;          //start X-coordinate,            spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;          //start Y-coordinate,            spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iPointWidth:integer;      //Dot width multiplying factor,  spec: 1 --- 8.
	iPointHeight:integer;     //dot height multiplying factor, spec: 1 --- 8.
end;
DownLoadingImagePrintPara = ^DownLoadingImageSetting;

// image printing struct

type
ImageSetting = packed record
	cImageName:array [1..256] of char; //bitmap file path and name.
	iStartX:integer;          //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;          //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
end;
ImagePrintPara = ^ImageSetting;

// inner font printing struct

type
InnerFontSetting = packed record
	cTextData:pchar;      //printing text data.
	iStartX:integer;          //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;          //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;          //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iFontType:integer;        //font type ID,          spec: 0 --- 22.
	iWidthMultiple:integer;   //dot width multiplying factor,  spec: 1 --- 8.
	iHeightMultiple:integer;  //dot height multiplying factor, spec: 1 --- 8.
	iSpace:integer;           //character space,               spec: -99 --- 99.
  iMirrorEnable:integer;    //mirror setting,                spec:0(mirror disabled),1(mirror enabled)
end;
InnerFontPrintPara = ^InnerFontSetting;

// downloading font printing struct

type
DownloadingFontSetting = packed record
	cText:pchar;          //printing text data
	iStartX:integer;		  //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;          //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;          //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	cFontName:array [1..20] of char;  //font name, which is name of memory module font.
	iWidthMultiple:integer;   //dot width multiplying factor,  spec: 1 --- 8.
	iHeightMultiple:integer;  //dot height multiplying factor, spec: 1 --- 8.
	iSpace:integer;           //character space,               spec: -99 --- 99.
  iMirrorEnable:integer;    //mirror setting,                spec:0(mirror disabled),1(mirror enabled)
end;
DownloadingFontPrintPara = ^DownloadingFontSetting;

// mix font printing struct

type
MixFontSetting = packed record
	cText:pchar;             //printing text data  
	iStartX:integer;             //start X-coordinate,                  spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iCN_StartY:integer;          //Chinese start Y-coordinate,          spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iXY_Adjust:integer;          //English font Offset against Chinese, spec: -999 --- +999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise,         spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	cEN_FontType:array [1..20] of char;  //English font name,             spec: "XYNN".
	cCN_FontName:array [1..20] of char;  //Chinese font name, which is name of memory module font.
	iWidthMultiple:integer;      //dot width multiplying factor,  spec: 1 --- 8.
	iHeightMultiple:integer;     //dot height multiplying factor, spec: 1 --- 8.
	iSpace:integer;              //character space,               spec: -99 --- 99.
  iMirrorEnable:integer;       //mirror setting,                spec:0(mirror disabled),1(mirror enabled)
end;
MixFontPrintPara = ^MixFontSetting;

// vector font printing struct 

type
TruetypeSetting = packed record
	cText:pchar;             //printing text data  
	iStartX:integer;             //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	cFontName:array [1..100] of char;     //system font name.
	iFontHeight:integer;         //font height.
	iFontWidth:integer;          //font width.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iBold:integer;               //bold setting,       spec: 0 (normal), 1 (bold).
	iItalic:integer;             //italic setting,     spec: 0 (normal), 1 (italic).
	iUnderline:integer;          //underline setting,  spec: 0 (normal), 1 (underline).
end;
TruetypePrintPara = ^TruetypeSetting;

// code 39 printing struct

type
Code39Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,     spec: 0 (with no text), 1 (with text).
	iHeight:integer;             //bar code height,   spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,   spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator, spec: 1 --- 24.
end;
Code39PrintPara = ^Code39Setting;


// code UPCA printing struct

type
CodeUPCASetting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodeUPCAPrintPara = ^CodeUPCASetting;

// code UPCE printing struct

type
CodeUPCESetting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).  
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodeUPCEPrintPara = ^CodeUPCESetting;

// interleaved 2 of 5 (without check character) code printing struct

type
NoVerify25CodeSetting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,     spec: 0 (with no text), 1 (with text).      
	iHeight:integer;             //bar code height,   spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,   spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator, spec: 1 --- 24.
end;
NoVerify25CodePrintPara = ^NoVerify25CodeSetting;

// code 128 printing struct

type
Code128Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).  
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
Code128PrintPara = ^Code128Setting;

// code ENA13 printing struct

type
CodeEna13Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).  
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodeEna13PrintPara = ^CodeEna13Setting;

// code ENA8 printing struct

type
CodeEna8Setting = record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodeEna8PrintPara = ^CodeEna8Setting;

// code HBIC printing struct

type
CodeHBICSetting = record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).    
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,  spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator, spec: 1 --- 24.
end;
CodeHBICPrintPara = ^CodeHBICSetting;

// CODABAR printing struct

type
CodaBarSetting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,     spec: 0 (with no text), 1 (with text).     
	iHeight:integer;             //bar code height,   spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,   spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator, spec: 1 --- 24.
end;
CodaBarPrintPara = ^CodaBarSetting;

// Interleaved 2 of 5 (with check character) code printing struct

type
CodeVerify25Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,     spec: 0 (with no text), 1 (with text).      
	iHeight:integer;             //bar code height,   spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,   spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator, spec: 1 --- 24.
end;
CodeVerify25PrintPara = ^CodeVerify25Setting;

// industrial 2 of 5 code printing struct

type
CodeIndustry25Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,     spec: 0 (with no text), 1 (with text).
	iHeight:integer;             //bar code height,   spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,   spec: 1 --- 24.
	
	iNumberBase:integer;         //ratio denominator, spec: 1 --- 24.
end;
CodeIndustry25PrintPara = ^CodeIndustry25Setting;

// shipping bearer code printing struct

type
CodeTransportSetting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,     spec: 0 (with no text), 1 (with text).
	iHeight:integer;             //bar code height,   spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,   spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator, spec: 1 --- 24.
end;
CodeTransportPrintPara = ^CodeTransportSetting;

// UPC2 code printing struct

type
CodeUPC2Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).      
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodeUPC2PrintPara = ^CodeUPC2Setting;

// UPC5 code printing struct

type
CodeUPC5Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).   
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodeUPC5PrintPara = ^CodeUPC5Setting;

// 93 code printing struct

type
Code93Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).  
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
Code93PrintPara = ^Code93Setting;

// POSTNET code printing struct

type
CodePOSTNETSetting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).      
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodePOSTNETPrintPara = ^CodePOSTNETSetting;

// UCC/ENA code printing struct

type
CodeUCCENASetting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,    spec: 0 (with no text), 1 (with text).  
	iHeight:integer;             //bar code height,  spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumberBase:integer;         //narrow bar width, spec: 1 --- 24.
end;
CodeUCCENAPrintPara = ^CodeUCCENASetting;

// Matrix 2 of 5(Europe standard) printing struct

type
CodeEurope25Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,         spec: 0 (with no text), 1 (with text).     
	iHeight:integer;             //bar code height,       spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,       spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator,     spec: 1 --- 24.
end;
CodeEurope25PrintPara = ^CodeEurope25Setting;

// Matrix 2 of 5(Japan standard) printing struct

type
CodeJapan25Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;			 //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,         spec: 0 (with no text), 1 (with text).
	iHeight:integer;             //bar code height,       spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,       spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator,     spec: 1 --- 24.
end;
CodeJapan25PrintPara = ^CodeJapan25Setting;

// Postnet 2 of 5(China) printing struct

type
CodeChina25Setting = packed record
	cCodeData:pchar;         //bar code data.
	iStartX:integer;			 //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iType:integer;               //bar code type,         spec: 0 (with no text), 1 (with text).      
	iHeight:integer;             //bar code height,       spec: 0 --- 999, unit: dot, millimeter/10, inch/100.
	iNumber:integer;             //ratio numerator,       spec: 1 --- 24.
	iNumberBase:integer;         //ratio denominator,     spec: 1 --- 24.
end;
CodeChina25PrintPara = ^CodeChina25Setting;


// PDF417 printing struct

type
PDFSetting = packed record
	cCodeData:pchar;         //bar code data.
	iDataLen:integer;            //bar code data length.
	iStartX:integer;             //start X-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate,    spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iBaseWidth:integer;          //factor width,          spec: 1 --- 24.
	iBaseHeight:integer;         //factor height,         spec: 1 --- 24.
	iScaleWidth:integer;         //appearance ratio numerator,   spec: 0 --- 9.
	iScaleHeight:integer;        //appearance ratio denominator, spec: 0 --- 9.
	iRow:integer;                //the number of lines,          spec: 3 --- 90.
	iColumn:integer;             //the number of columns,        spec: 1 --- 30.
	iCutMode:integer;            //truncate type,                spec: 0 (normal type), 1 (truncate type).
	iLeve:integer;               //check level,                  spec: 0 --- 8.
	iDataMode:integer;           //data mode,                    spec: 0 (character string mode), 1 (specify data length mode).
end;
PDFPrintPara = ^PDFSetting;

// QR code printing struct

type
QRSetting = packed record
	cCodeData:pchar;         //bar code data.
	iDataLen:integer;            //length of bar code data.
	iStartX:integer;             //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iWeigth:integer;             //unit factor width,  spec: 1 --- 10.
	iSymbolType:integer;         //symbol type,        spec: 1 (the original type), 2 (enhanced type).
	iLanguageMode:integer;       //language mode,      spec: 0 (Chinese), 1 (Japan).
end;
QRPrintPara = ^QRSetting;

// MAXI code printing struct

type
MAXISetting = packed record

	cCodeData:pchar;         //bar code data.
	iDataLen:integer;            //length of data.
	iStartX:integer;             //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
end;
MAXIPrintPara = ^MAXISetting;

// GM code printing struct

type
GMSetting = packed record
  cCodeData:pchar;             //bar code data.
  iDataLen:integer;            //length of data.
	iStartX:integer;             //start X-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iStartY:integer;             //start Y-coordinate, spec: 0 --- 9999, unit: dot, millimeter/10, inch/100.
	iRotate:Integer;             //rotation in clockwise, spec: 1 (0 degree), 2 (90 degree), 3 (180 degree), 4 (270 degree).
	iLevel:Integer;              //check level,           spec: 0 --- 5.
	iWidth:Integer;              //unit factor width,  spec: 1 --- 99.
	iHeight:Integer;             //bar code height,    spec: 1 --- 999, unit: dot, millimeter/10, inch/100.
end;
GMPrintPara = ^GMSetting;

// Gray image printing struct

type
GrayImageSetting = packed record
	cImageFileName:array [1..256] of char;//Gray image file name
  iGrayMode:integer;                    //Gray data mode, spec: 0 --- general mode, 1 --- data format mode.
end;
GrayImagePrintPara = ^GrayImageSetting;


//****************API function*************************************************/

// Enum class mode USB device name or driver name list

function Enum_DeviceNameList(iOperationType:integer;cDevNameBuf:pchar;iBufLen:integer;iNumber:pint;cFilterInfor:string):integer;

// open port

function Comm_OpenPort(iPortType:integer;vPortPara:pointer;iPortParaStructLen:integer;iSaveFileEnable:integer;cFileName:string):integer;

// close port

function Comm_ClosePort(hDev:integer):integer;

// write port

function Comm_WritePort(hDev:integer;cBuf:pchar;iBufLen:integer;iReturnLen:pint):integer;

// read port

function Comm_ReadPort(hDev:integer;cBuf:pchar;iBufLen:integer;iReturnLen:pint):integer;

// set timeout of port

function Comm_SetPortTimeout(hDev:integer;iWriteTimeout:integer;iReadTimeout:integer):integer;

// send file data to device

function Comm_SendFile(hDev:integer;cFileName:string):integer;

// document start of driver

function Comm_DrvDocOperation(hDev:integer;iOperation:integer):integer;

// device control operation

function Ctrl_DevControl(hDev:integer;iOperationID:integer):integer;

// device control of download image

function Ctrl_DownLoadImage(hDev:integer;cImageName:string;iImageType:integer; iModuleType:integer;cFileName:string;iCheckTimeout:integer):integer;

// device control of delete files from module

function Ctrl_EraseModuleAndFile(hDev:integer;iEraseMode:integer;iModuleType:integer;iFileType:integer; cFileName:string;iWaitTimeout:integer):integer;

// device control of feed and back paper

function Ctrl_FeedAndBack(hDev:integer;iDistance:integer;iDelayTime:integer):integer;

// get version information

function Get_VersionInfo(hDev:integer;cVersionInfo:pchar;iInfoLength:integer;iInfoTrueLen:pint;iCheckTimeout:integer):integer;

// get status data

function Get_StatusData(hDev:integer;var cStatusBuf;iStatusBufLen:integer;var iStatusDataLen:DWORD;iTimeout:integer):integer;

// base parameter setting

function Set_BasePara(hDev:integer;sBasePara:BASEPARA;iStructLen:integer):integer;

// set print stop position

function Set_OutPosition(hDev:integer;iPosition:integer):integer;

// set paper length

function Set_PaperLength(hDev:integer;iContinueLength:integer):integer;

// set water mark mode

function Set_WaterMarkMode(hDev:integer;iLayoutMode:integer;cFileName:string;iCheckTimeout:integer):integer;

// set horizontally duplicate printing

function Set_HorizontalCopy(hDev:integer;iPieces:integer;iGap:integer):integer;

// set label store for printing

function Prt_LabelToMemory(hDev:integer):integer;

// quantity for stored labels and start printing

function Prt_MemoryLabel(hDev:integer;iPieces:integer):integer;

// enter label mode for printing

function Prt_EnterLabelMode(hDev:integer;iGrayModeEnable:integer;iWidth:integer;iColumn:integer;iRow:integer;iSpeed:integer;iDarkness:integer):integer;

// out label mode and start printing

function Prt_EndLabelAndPrint(hDev:integer;iTotalNum:integer;iSameNum:integer;iOutUnit:integer):integer;

// set last field for printing

function Prt_LastFieldSetting(hDev:integer;cDataBuf:pchar;iDataLength:integer;cFileEnter:string;iFieldStartPoint:integer;iFieldLength:integer):integer;

// set label record for printing

function Prt_LabelPrintSetting(hDev:integer;iSettingCommand:integer;vParaSetting:Pointer;iStructLen:integer;iBitMode:integer):integer;


implementation

function Enum_DeviceNameList(iOperationType:integer;cDevNameBuf:pchar;iBufLen:integer;iNumber:pint;cFilterInfor:string):integer;
var
  wProc: function (iOperationType:integer;cDevNameBuf:pchar;iBufLen:integer;iNumber:pint;cFilterInfor:string):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Enum_DeviceNameList'));
    if Assigned(wProc) then
      Result := wProc(iOperationType, cDevNameBuf, iBufLen, iNumber, cFilterInfor);
  end;
end;

// open port

function Comm_OpenPort(iPortType:integer;vPortPara:pointer;iPortParaStructLen:integer;iSaveFileEnable:integer;cFileName:string):integer;
var
  wProc: function (iPortType:integer;vPortPara:pointer;iPortParaStructLen:integer;iSaveFileEnable:integer;cFileName:string):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Comm_OpenPort'));
    if Assigned(wProc) then
      Result := wProc(iPortType, vPortPara, iPortParaStructLen, iSaveFileEnable, cFileName);
  end;
end;

// close port

function Comm_ClosePort(hDev:integer):integer;
var
  wProc: function (hDev:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Comm_ClosePort'));
    if Assigned(wProc) then
      Result := wProc(hDev);
  end;
end;

// write port

function Comm_WritePort(hDev:integer;cBuf:pchar;iBufLen:integer;iReturnLen:pint):integer;
var
  wProc: function (hDev:integer;cBuf:pchar;iBufLen:integer;iReturnLen:pint):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Comm_WritePort'));
    if Assigned(wProc) then
      Result := wProc(hDev, cBuf, iBufLen, iReturnLen);
  end;
end;

// read port

function Comm_ReadPort(hDev:integer;cBuf:pchar;iBufLen:integer;iReturnLen:pint):integer;
var
  wProc: function (hDev:integer;cBuf:pchar;iBufLen:integer;iReturnLen:pint):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc :=  GetProcAddress(Com_Label, PChar('Comm_ReadPort'));
    if Assigned(wProc) then
      Result := wProc(hDev, cBuf, iBufLen, iReturnLen);
  end;
end;

// set timeout of port

function Comm_SetPortTimeout(hDev:integer;iWriteTimeout:integer;iReadTimeout:integer):integer;
var
  wProc: function (hDev:integer;iWriteTimeout:integer;iReadTimeout:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Comm_SetPortTimeout'));
    if Assigned(wProc) then
      Result := wProc(hDev, iWriteTimeout, iReadTimeout);
  end;
end;

// send file data to device

function Comm_SendFile(hDev:integer;cFileName:string):integer;
var
  wProc: function (hDev:integer;cFileName:string):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Comm_SendFile'));
    if Assigned(wProc) then
      Result := wProc(hDev, cFileName);
  end;
end;

// document start of driver

function Comm_DrvDocOperation(hDev:integer;iOperation:integer):integer;
var
  wProc: function (hDev:integer;iOperation:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Comm_DrvDocOperation'));
    if Assigned(wProc) then
      Result := wProc(hDev, iOperation);
  end;
end;

// device control operation

function Ctrl_DevControl(hDev:integer;iOperationID:integer):integer;
var
  wProc: function (hDev:integer;iOperationID:integer):integer;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Ctrl_DevControl'));
    if Assigned(wProc) then
      Result := wProc(hDev, iOperationID);
  end;
end;

// device control of download image

function Ctrl_DownLoadImage(hDev:integer;cImageName:string;iImageType:integer; iModuleType:integer;cFileName:string;iCheckTimeout:integer):integer;
var
  wProc: function (hDev:integer;cImageName:string;iImageType:integer; iModuleType:integer;cFileName:string;iCheckTimeout:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Ctrl_DownLoadImage'));
    if Assigned(wProc) then
      Result := wProc(hDev, cImageName, iImageType, iModuleType, cFileName, iCheckTimeout);
  end;
end;

// device control of delete files from module

function Ctrl_EraseModuleAndFile(hDev:integer;iEraseMode:integer;iModuleType:integer;iFileType:integer; cFileName:string;iWaitTimeout:integer):integer;
var
  wProc: function (hDev:integer;iEraseMode:integer;iModuleType:integer;iFileType:integer; cFileName:string;iWaitTimeout:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Ctrl_EraseModuleAndFile'));
    if Assigned(wProc) then
      Result := wProc(hDev, iEraseMode, iModuleType, iFileType, cFileName, iWaitTimeout);
  end;
end;

// device control of feed and back paper

function Ctrl_FeedAndBack(hDev:integer;iDistance:integer;iDelayTime:integer):integer;
var
  wProc: function (hDev:integer;iDistance:integer;iDelayTime:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Ctrl_FeedAndBack'));
    if Assigned(wProc) then
      Result := wProc(hDev, iDistance, iDelayTime);
  end;
end;

// get version information

function Get_VersionInfo(hDev:integer;cVersionInfo:pchar;iInfoLength:integer;iInfoTrueLen:pint;iCheckTimeout:integer):integer;
var
  wProc: function (hDev:integer;cVersionInfo:pchar;iInfoLength:integer;iInfoTrueLen:pint;iCheckTimeout:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Get_VersionInfo'));
    if Assigned(wProc) then
      Result := wProc(hDev, cVersionInfo, iInfoLength, iInfoTrueLen, iCheckTimeout);
  end;
end;

// get status data

function Get_StatusData(hDev:integer;var cStatusBuf;iStatusBufLen:integer;var iStatusDataLen:DWORD;iTimeout:integer):integer;
var
  wProc: function (hDev:integer;var cStatusBuf;iStatusBufLen:integer;var iStatusDataLen:DWORD;iTimeout:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Get_StatusData'));
    if Assigned(wProc) then
      Result := wProc(hDev, cStatusBuf, iStatusBufLen, iStatusDataLen, iTimeout);
  end;
end;

// base parameter setting

function Set_BasePara(hDev:integer;sBasePara:BASEPARA;iStructLen:integer):integer;
var
  wProc: function (hDev:integer;sBasePara:BASEPARA;iStructLen:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Set_BasePara'));
    if Assigned(wProc) then
      Result := wProc(hDev, sBasePara, iStructLen);
  end;
end;

// set print stop position

function Set_OutPosition(hDev:integer;iPosition:integer):integer;
var
  wProc: function (hDev:integer;iPosition:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Set_OutPosition'));
    if Assigned(wProc) then
      Result := wProc(hDev, iPosition);
  end;
end;

// set paper length

function Set_PaperLength(hDev:integer;iContinueLength:integer):integer;
var
  wProc: function (hDev:integer;iContinueLength:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Set_PaperLength'));
    if Assigned(wProc) then
      Result := wProc(hDev, iContinueLength);
  end;
end;

// set water mark mode

function Set_WaterMarkMode(hDev:integer;iLayoutMode:integer;cFileName:string;iCheckTimeout:integer):integer;
var
  wProc: function (hDev:integer;iLayoutMode:integer;cFileName:string;iCheckTimeout:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Set_WaterMarkMode'));
    if Assigned(wProc) then
      Result := wProc(hDev, iLayoutMode, cFileName, iCheckTimeout);
  end;
end;

// set horizontally duplicate printing

function Set_HorizontalCopy(hDev:integer;iPieces:integer;iGap:integer):integer;
var
  wProc: function (hDev:integer;iPieces:integer;iGap:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Set_HorizontalCopy'));
    if Assigned(wProc) then
      Result := wProc(hDev, iPieces, iGap);
  end;
end;

// set label store for printing

function Prt_LabelToMemory(hDev:integer):integer;
var
  wProc: function (hDev:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Prt_LabelToMemory'));
    if Assigned(wProc) then
      Result := wProc(hDev);
  end;
end;

// quantity for stored labels and start printing

function Prt_MemoryLabel(hDev:integer;iPieces:integer):integer;
var
  wProc: function (hDev:integer;iPieces:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Prt_MemoryLabel'));
    if Assigned(wProc) then
      Result := wProc(hDev, iPieces);
  end;
end;

// enter label mode for printing

function Prt_EnterLabelMode(hDev:integer;iGrayModeEnable:integer;iWidth:integer;iColumn:integer;iRow:integer;iSpeed:integer;iDarkness:integer):integer;
var
  wProc: function (hDev:integer;iGrayModeEnable:integer;iWidth:integer;iColumn:integer;iRow:integer;iSpeed:integer;iDarkness:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Prt_EnterLabelMode'));
    if Assigned(wProc) then
      Result := wProc(hDev, iGrayModeEnable, iWidth, iColumn, iRow, iSpeed, iDarkness);
  end;
end;

// out label mode and start printing

function Prt_EndLabelAndPrint(hDev:integer;iTotalNum:integer;iSameNum:integer;iOutUnit:integer):integer;
var
  wProc: function (hDev:integer;iTotalNum:integer;iSameNum:integer;iOutUnit:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Prt_EndLabelAndPrint'));
    if Assigned(wProc) then
      Result := wProc(hDev, iTotalNum, iSameNum, iOutUnit);
  end;
end;

// set last field for printing

function Prt_LastFieldSetting(hDev:integer;cDataBuf:pchar;iDataLength:integer;cFileEnter:string;iFieldStartPoint:integer;iFieldLength:integer):integer;
var
  wProc: function (hDev:integer;cDataBuf:pchar;iDataLength:integer;cFileEnter:string;iFieldStartPoint:integer;iFieldLength:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Prt_LastFieldSetting'));
    if Assigned(wProc) then
      Result := wProc(hDev, cDataBuf, iDataLength, cFileEnter, iFieldStartPoint, iFieldLength);
  end;
end;

// set label record for printing

function Prt_LabelPrintSetting(hDev:integer;iSettingCommand:integer;vParaSetting:Pointer;iStructLen:integer;iBitMode:integer):integer;
var
  wProc: function (hDev:integer;iSettingCommand:integer;vParaSetting:Pointer;iStructLen:integer;iBitMode:integer):integer;stdcall;
begin
  Result := ERR_HANDLE;
  if Com_Label <> 0 then
  begin
    @wProc := GetProcAddress(Com_Label, PChar('Prt_LabelPrintSetting'));
    if Assigned(wProc) then
      Result := wProc(hDev, iSettingCommand, vParaSetting, iStructLen, iBitMode);
  end;
end;

end.
