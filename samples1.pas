
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}

Program samples1;

uses
  SysUtils, // UnixUtil, Video,
  //FVCommon,
  App,      // TApplication
  Objects,  // Fensterbereich (TRect)
  Drivers,  // Hotkey
  Views,    // Ereigniss (cmQuit)
  Menus,    // Statuszeile
  Dialogs, MsgBox,
  RSet, DmxGizma, DefaultDmx,
  FvStdDMX, fvDMX,
  fvGizma;
  //tvGizma, tvDMX, StdDMX, tvDmxHex, tvDmxRep, DmxForms;

const
    cmAbout	  =  101;
    cmHasDialog   =  103;

    cmAccounts	  =  111;
    cmPayroll	  =  112;
    cmBusy	  =  113;
    cmHex	  =  114;
    cmInvoice	  =  115;
    cmDialog	  =  116;
    cmRecDialog   =  117;
    cmPrint	  =  118;

    hcDeskTop	  = 1100;
    hcAccWin	  = 1100;
    hcPayWin	  = 1200;
    hcBusyWin	  = 1300;
    hcHexWin	  = 1400;
    hcInvoiceWin  = 1500;
    hcDialogs	  = 4000;
    hcMenus	  = 50000;

    hcReadOnly	  = 1502;
    hcEnumField	  = 1501;

    hcMain	  = hcMenus;
    hcAccounts	  = hcMain + 1;
    hcPayroll	  = hcMain + 2;
    hcBusy	  = hcMain + 3;
    hcHex	  = hcMain + 4;
    hcInvoice	  = hcMain + 5;
    hcDialog	  = hcMain + 6;
    hcPrint	  = hcMain + 7;

    hcWindow	  = hcMain + 10;
    hcUserScr	  = hcWindow + 1;

    hcOptions	  = hcMain + 20;
    hcSound	  = hcOptions + 1;
    hcVideo	  = hcOptions + 2;
    hcPrnOpt	  = hcOptions + 3;


{ ══ Accounts template and data structure ══════════════════════════════ }

const
    //AccountLabel : string[80] =
    // ' Transaction          Debit        Credit      [?] ';
    AccountLabel : String =
	' Transaction          Debit        Credit      [?] ';

    //AccountInfo  : string[80] =
	//' SSSSSSSSSSSSSSSS`SSSSSSSSSS| rrr,rrr.zz  | rrr,rrr.zz  | [x] ';
    AccountInfo  : string =
	' SSSSSSSSSSSSSSSS`SSSSSSSSSS| rrr,rrr.zz  | rrr,rrr.zz  | [x] ';

      { Note that the '`' character marks the end of the visible field. }

type
    PAccount	  = ^TAccount;
    TAccount	  =  RECORD
	//Account	:  string[26];
	Account	:  string;
	Debit	:  TREALNUM;
	Credit	:  TREALNUM;
	Status	:  boolean;
    end;


{ ══ Payroll template and data structure ═══════════════════════════════ }

const { The last three fields are marked READ-ONLY, and are automatically
	entered by the virtual methods in object TDmxPayroll. }

    PayrollLblA  = ' Employee                ID     Earnings       FICA        FITW        SITW   ';
    PayrollInfo  = ' ssssssssssssssssssssss| ZZW ║ $rr,rrr.zz | $r,rrr.zz '^R'| $r,rrr.zz '^R'| $r,rrr.zz '^R;
    PayrollLblB  = ' (dollar amounts are dependent upon Earnings)';

type
    PPayroll	  = ^TPayroll;
    TPayroll	  =  RECORD
	//Employee :  string[22];
	Employee :  string;
	ID	 :  word;
	Earnings :  TREALNUM;
	FICA	 :  TREALNUM;  { READ-ONLY }
	FITW	 :  TREALNUM;  { READ-ONLY }
	SITW	 :  TREALNUM;  { READ-ONLY }
    end;


{ ══ Busy data structure ═══════════════════════════════════════════════ }

const { The Busy Window's template uses many of the special options.  Since
	it uses an enumerated field, the template is defined in the method
	that instantiates these windows. }

    _BusyLabel	  =
	' Name                  SSN             Balance      Start Date   Time   <A>  [B]   Pointer       Value     RO ';

    // BusyLabel	  :  string[length(_BusyLabel)] =  _BusyLabel;
    BusyLabel	  :  string =  _BusyLabel;

type
    PBusyData	  = ^TBusyData;
    TBusyData	  =  RECORD
	Marker		:  byte;	{ HIDDEN field }
	//Name		:  string[30];
	Name		:  string;
	//SSN		:  string[9];
	SSN		:  string;
	realfield1	:  TREALNUM;
	// DT		:  datetime;
	DT		:  TDateTime;
	intfield0	:  integer;	{ READ-ONLY }
	intfield1	:  integer;
	ptrfield	:  pointer;
	realfield2	:  TREALNUM;
	hextwo		:  byte;	{ READ-ONLY }
    end;


{ ══ Invoice data structure ════════════════════════════════════════════ }

      { The Invoice Window is a TDmxForm-descendant, so its template uses
	is built by nested NewSItem() calls.  See function InvoiceForm(). }

const
    UnitPrice	= 20.00;
    SitePrice	= 50.00;

    { bit values for TInvoiceRec.Tools }
    AnsiView	= $0001;
    Blaise	= $0002;
    Btrieve	= $0004;
    PXE		= $0008;
    Topaz	= $0010;
    TPW		= $0020;
    TurboPower	= $0040;

    BBS		=   0;
    CIS		=   1;
    Internet	=   2;
    UserGroup	=   3;
    Friend	=   4;
    OtherSource	=   5;

type
    TInvoiceRec		= RECORD
	//Co,Addr,City,Rep1,Rep2	: string[25];
	//ContactA,ContactB	: string[25];
	Co,Addr,City,Rep1,Rep2	: string;
	ContactA,ContactB	: string;
	Quantity		: integer;
	Item			: (Registration, SiteLicense);
	Price,Total		: TREALNUM;
	DiskType		: (disk3p5, disk5p25);
	SendWhen		: (whenrx, whennextver);
	 { How long have you been using Turbo Vision? }
	Years,Months		: word;
	 { Which version of Borland Pascal are you using? }
	TPversion		: TREALNUM;
	 { List any programming tools/add-ins that you use... }
	Tools,WhoSaid		: word;
	//BlaiseProd		: string[21];
	//SourceName		: string[14];
	//TPowerProd		: string[17];
	//Others			: array[0..4] of string[44];
	BlaiseProd		: string;
	SourceName		: string;
	TPowerProd		: string;
	Others			: array[0..4] of string;
    end;


{ ══════════════════════════════════════════════════════════════════════ }
type
    //PDmxInvoice	  = ^TDmxInvoice;
    //TDmxInvoice	  =  OBJECT(TDmxForm)
    //  procedure EvaluateField;  VIRTUAL;
    //  procedure FieldText(var S: string;  var Color: word;
//			  Field: pDMXfieldrec;  var DataRec );  VIRTUAL;
//      function	GetHelpCtx : word;  VIRTUAL;
//    end;


    PDmxEditTbl	   = ^TDmxEditTbl;
    PDmxEditTblWin = ^TDmxEditTblWin;


    TDmxEditTbl     =  OBJECT(TDmxEditor)
      function	GetHelpCtx : word;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure SetState(AState: word; Enable: boolean);  VIRTUAL;
      function  Valid(Command: word) : boolean;  VIRTUAL;
    end;


    TDmxEditTblWin  =  OBJECT(TDmxWindow)
      procedure InitDMX(ATemplate: String;  var AData;
			ALabels,ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
    end;


//    PDmxPayroll    = ^TDmxPayroll;

//    TDmxPayroll	   =  OBJECT(TDmxEditTbl)
//      procedure EvaluateField;	VIRTUAL;
//      procedure ZeroizeField(Whole: boolean; Field: pDMXfieldrec);  VIRTUAL;
//      procedure RecalcRecord;
//    end;


    PMyStatusLine  = ^TMyStatusLine;
    TMyStatusLine  =  OBJECT(TStatusLine)
      function	Hint(AHelpCtx: word): ShortString;  VIRTUAL;
      // function	Hint(AHelpCtx: word): Sw_String;  VIRTUAL;
    end;


type
  TMyApp = object(TApplication)

      constructor Init;
      //procedure Idle;  VIRTUAL;
      procedure HandleEvent(var Event: TEvent);  VIRTUAL;
      procedure InitMenuBar;	 VIRTUAL;
      procedure InitStatusLine;  VIRTUAL;
      procedure AccountWindow;
      //procedure PayrollWindow;
      //procedure BusyWindow;
      //procedure HexWindow;
      //procedure InvoiceFormWin;
      //procedure AccountDialog(P: PDmxEditTbl);
      //procedure PayrollDialog(P: PDmxPayroll);
      //procedure BusyDialog(P: PDmxEditTbl);

end;

const
    MaxRecordNum  =   49;

{ ══════════════════════════════════════════════════════════════════════ }
var
    Accounts	:  array[0..MaxRecordNum] of TAccount;
    Payroll	:  array[0..MaxRecordNum] of TPayroll;
    BusyData	:  array[0..MaxRecordNum] of TBusyData;
    InvoiceRec	:  TInvoiceRec;


  procedure InitializeData;  forward;  { for the sample data }


{ ══════════════════════════════════════════════════════════════════════ }
procedure InitializeData;
{ creates test data }
var  i, j  : integer;
     // F	  : SearchRec;
     F	  : TSearchRec;
     find_error: LongInt;

    procedure InitAccount(ARecNum: integer; AName: string);
    begin
      With Accounts[ARecNum] do
      begin
	Account	:= AName;
	Debit	:= Random(50000) * 0.9;
	Credit	:= Random(50000) * 0.9;
	Status	:= (Credit > Debit);
      end;
    end;

    procedure InitBusyRec(ARecNum: integer; AName: string);
    var  i : integer;
    begin
      With BusyData[ARecNum] do
      begin
	Name := AName;
	intfield0 := ARecNum;
	hextwo := lo(ARecNum);
	If ARecNum < 26 then
	begin
	  intfield1	:= random(255);
	  ptrfield	:= pointer(random(MaxInt));
	  realfield1	:= random(200) * random(200) / succ(random(199));
	  realfield2	:= random(200) * random(200) / succ(random(199));
	  // DT.Year	:= 1988 + random(4);
	  // DT.Month	:= succ(random(12));
	  // DT.Day	:= succ(random(28));
	  // DT.Hour	:= random(24);
	  // DT.Min	:= random(60);
	  // DT.Sec	:= random(60);
          DT := EncodeDate(1988 + random(4), succ(random(12)), succ(random(28))) + EncodeTime(random(24), random(60), random(60), 0);
	  // SSN[0]	:= #9;
	  SSN	:= #9;
	  For i := 1 to 9 do SSN := SSN + chr(random(10) + 48);
          
	end;
      end;
    end;

    procedure InitPayroll(ARecNum: integer; AName: string);
    begin
      With Payroll[ARecNum] do
      begin
	Employee :=  AName;
	If (ARecNum = 0) then ID := 44 else ID := Random(400);
	Earnings :=  Random(3000) + 4000.0;
	FICA	 :=  Earnings * 0.075;
	FITW	 :=  Earnings * 0.28;
	SITW	 :=  Earnings * 0.05;
      end;
    end;

begin
  RandSeed := 31;
  //FillChar(Accounts,   sizeof(Accounts),   0);
  //FillChar(Payroll,    sizeof(Payroll),	   0);
  //FillChar(BusyData,   sizeof(BusyData),   0);
  //FillChar(InvoiceRec, sizeof(InvoiceRec), 0);

  InitAccount( 0, 'ACME TOOL CO.');
  InitAccount( 1, 'READING R. R.');
  InitAccount( 2, 'EXXON CORP.');
  InitAccount( 3, 'ELECTRIC CO.');
  InitAccount( 4, 'B&O R. R.');
  InitAccount( 5, 'NYNEX');
  //for i := 0 to MaxRecordNum do
  //  WriteLn(Format('Account: %s %f %f', [Accounts[i].Account, Accounts[i].Debit, Accounts[i].Credit]));

  InitBusyRec( 0, 'Abigail Adams');
  InitBusyRec( 1, 'Betty Boop');
  InitBusyRec( 2, 'Cindy Crawford');
  InitBusyRec( 3, 'Dana Delaney');
  InitBusyRec( 4, 'Eve Easton');
  InitBusyRec( 5, 'Farrah Fawcett');
  InitBusyRec( 6, 'Ginger Grant');
  InitBusyRec( 7, 'Holly Hunter');
  InitBusyRec( 8, 'Ida Inman');
  InitBusyRec( 9, 'Janet Jackson');
  InitBusyRec(10, 'Katie Kingfield');
  InitBusyRec(11, 'Lois Lane');
  InitBusyRec(12, 'Marilyn Monroe');
  InitBusyRec(13, 'Nichelle Nichols');
  InitBusyRec(14, 'Olive Oyl');
  InitBusyRec(15, 'Paula Prentiss');
  InitBusyRec(16, 'Quia Quinn');
  InitBusyRec(17, 'Rita Rudner');
  InitBusyRec(18, 'Samantha Stevens');
  InitBusyRec(19, 'Tina Turner');
  InitBusyRec(20, 'Ursula Upton');
  InitBusyRec(21, 'Vicky Vail');
  InitBusyRec(22, 'Wendy Wilson');
  InitBusyRec(23, 'Xuxa');
  InitBusyRec(24, 'Yvette Yokomuro');
  InitBusyRec(25, 'Zelda Zimmerman');

  For i := 26 to MaxRecordNum do InitBusyRec(i, '');
  BusyData[0].SSN  := '';

  //for i := 0 to MaxRecordNum do
  //  WriteLn(Format('BusyData: %s %s %f %f %d %d', [BusyData[i].Name, BusyData[i].SSN, BusyData[i].realfield1, BusyData[i].realfield2, BusyData[i].intfield0, BusyData[i].intfield1]));


  InitPayroll( 0, 'Alex Trebek');
  InitPayroll( 1, 'Pat Sajak');
  InitPayroll( 2, 'Vanna White');
  InitPayroll( 3, 'Merv Griffin');

  //for i := 0 to MaxRecordNum do
  //  WriteLn(Format('Payroll: %s %d %f %f %f %f', [Payroll[i].Employee, Payroll[i].ID, Payroll[i].Earnings, Payroll[i].FICA, Payroll[i].FITW, Payroll[i].SITW]));

  InvoiceRec.Quantity := 1;
  InvoiceRec.Price := UnitPrice;
  InvoiceRec.Total := UnitPrice;

  {$IFDEF VER60 }
  InvoiceRec.TPversion := 6.0;
  {$ELSE }
  InvoiceRec.Tools  := InvoiceRec.Tools or TPW;
  {$ENDIF }

  {$IFDEF VER70 }
  InvoiceRec.TPversion := 7.0;
  {$ENDIF }
  {$IFDEF VER75 }
  InvoiceRec.TPversion := 7.5;
  {$ENDIF }
  {$IFDEF VER80 }
  InvoiceRec.TPversion := 8.0;
  {$ENDIF }

  // FindFirst('\TVDT', Directory, F);
  find_error := FindFirst('\TVDT', faDirectory, F);
  // If (DosError = 0) then
  If (find_error = 0) then
    begin
    InvoiceRec.Tools := InvoiceRec.Tools or Blaise;
    InvoiceRec.BlaiseProd := 'TVDT';
    end;

  // FindFirst('\PXENG*.', Directory, F);
  find_error := FindFirst('\PXENG*.', faDirectory, F);
  // While (DosError = 0) and (F.Attr and faDirectory = 0) do FindNext(F);
  // If (DosError = 0) then InvoiceRec.Tools := InvoiceRec.Tools or PXE;
  While (find_error = 0) and (F.Attr and faDirectory = 0) do FindNext(F);
  If (find_error = 0) then InvoiceRec.Tools := InvoiceRec.Tools or PXE;

  // FindFirst('\CIM', Directory, F);
  find_error := FindFirst('\CIM', faDirectory, F);
  // If (DosError = 0) then
  If (find_error = 0) then
    InvoiceRec.WhoSaid := CIS
   else
    begin
    // FindFirst('\WINCIM', Directory, F);
    find_error := FindFirst('\WINCIM', faDirectory, F);
    // If (DosError = 0) then InvoiceRec.WhoSaid := CIS;
    If (find_error = 0) then InvoiceRec.WhoSaid := CIS;
    end;

end;



{ ══ TDmxEditTbl ═══════════════════════════════════════════════════════ }


function TDmxEditTbl.GetHelpCtx : word;
begin
  If (CurrentField^.typecode = fldENUM) then
    GetHelpCtx := hcEnumField
  else
  If (CurrentField^.access and accReadOnly <> 0) then
    GetHelpCtx := hcReadOnly
  else
    GetHelpCtx := HelpCtx;
end;


procedure TDmxEditTbl.HandleEvent(var Event: TEvent);
begin
  TDmxEditor.HandleEvent(Event);
  With Event do
    If (What = evCommand) then
      begin
      Case Command of
	cmDialog,cmDMX_DoubleClick:
	  Message(Application, evCommand, cmRecDialog, @Self);
	cmHasDialog:
	  begin end;  	// just allow this event to clear 
       else	Exit;
	end;
      ClearEvent(Event);
      end;
end;


procedure TDmxEditTbl.SetState(AState: word; Enable: boolean);
begin
  TDmxEditor.SetState(AState, Enable);
  If (AState and sfActive <> 0) then
    begin
    If Enable then EnableCommands([cmDialog]) else DisableCommands([cmDialog]);
    end;
end;


function  TDmxEditTbl.Valid(Command: word) : boolean;
var  V	: boolean;
begin
  V := TDmxEditor.Valid(Command);
  If not V and
    ((Command = cmDMX_ZeroizeField) or (Command = cmDMX_ZeroizeRecord))
   then
    If (MessageBox('Records has READ-ONLY fields.'^M
		 + 'Should a partial erase be performed?',
		nil, mfError or mfYesButton or mfNoButton) = cmYes) then V := TRUE;
  Valid := V;
end;


{ ══ TDmxEditTblWin ════════════════════════════════════════════════════ }


procedure TDmxEditTblWin.InitDMX(ATemplate: String;  var AData;
				  ALabels,ARecInd: PDmxLink;
				  BSize: longint);
{ To override TDmxEditor (as does object TDmxEditTbl above), you could
  override a TDmxWindow object to insert the new object.  This window
  type is used for the "Accounts" and "Busy" windows.  (The "Payroll"
  window uses a regular TWindow type.)
 }
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If ALabels <> nil then Inc(R.A.Y, ALabels^.Size.Y);
  DMX := New(PDmxEditTbl, Init(ATemplate, AData, BSize, R,
		ALabels, ARecInd,
		StandardScrollBar(sbHorizontal),
		StandardScrollBar(sbVertical)));
  Insert(DMX);
end;


{ ══ TMyStatusLine ═════════════════════════════════════════════════════ }

function  TMyStatusLine.Hint(AHelpCtx: word) : ShortString;
// function  TMyStatusLine.Hint(AHelpCtx: word) : Sw_String;
begin
  Case AHelpCtx of
    hcDragging:   Hint := #24#25#26#27' Move  Shift-'#24#25#26#27' Resize  '#17#196#217' Done  Esc Cancel';
    hcReadOnly:   Hint := '(Read-Only field)';
    hcEnumField:  Hint := '(Use "+" or "-")';

    hcAccWin:	  Hint := '';
    hcPayWin:	  Hint := '';
    hcBusyWin:	  Hint := '';
    hcHexWin:	  Hint := '';
    hcInvoiceWin: Hint := '';
    hcDialogs:	  Hint := '';

    hcMain:	  Hint := 'Demonstration window selections';
    hcAccounts:   Hint := 'Demo of simple data structure';
    hcPayroll:	  Hint := 'Demo of read-only fields which are entered by virtual methods';
    hcBusy:	  Hint := 'Demo of complex date fields, hidden fields, and a "skip" field';
    hcHex:	  Hint := 'Hex editor using the same data as the Busy window';
    hcInvoice:	  Hint := 'Demo form window using a descendant of object TDmxForm';
    hcDialog:	  Hint := 'Open a dialog box for the current record';
    hcPrint:	  Hint := 'Print data in the current window (set destination in Options menu)';

    hcWindow:	  Hint := 'Arrange and manipulate windows';
    hcUserScr:	  Hint := 'Display the original user screen';

    hcOptions:	  Hint := 'Sound, video and printer options';
    hcSound:	  Hint := 'Toggle sound on/off';
    hcVideo:	  Hint := 'Toggle video mode';
    hcPrnOpt:	  Hint := 'Change printer/output destination and parameters';

  else		  
    Hint := DefaultMenuHint(AHelpCtx);  { from DefaultDmx.PAS }
  end;
end;


{ ══════════════════════════════════════════════════════════════════════ }



{ ══ TMyApp ════════════════════════════════════════════════════════════ }
constructor TMyApp.Init;
begin
  //TAppN.Init;
  TApplication.Init;
  MenuBar^.HelpCtx := hcMenus;
  DeskTop^.HelpCtx := hcDeskTop;
  // hcEntryBox	   := hcDialogs;
  InitializeData;  { initialize the sample data }

  { Open the first 5 selections }
  AccountWindow;
  //PayrollWindow;
  //BusyWindow;
  //HexWindow;
  //InvoiceFormWin;

  // DeskTop^.SelectNext(FALSE);  { change back to account window }

  Message(Application, evCommand, cmAbout, @Self);
end;


procedure TMyApp.HandleEvent(var Event: TEvent);

    procedure About;
    const AIntro = #32'tvDMX Demo'#13
		 + #32'Copyright (c) 1994'#13
		 + #32'Randolph Beck'#13;
	{$IFDEF DPMI}
	  AVStr	 = 'Protected';
	{$ELSE }
	  AVStr	 = 'Real';
	{$ENDIF }
	 //Intro	: string[length(AIntro)] = AIntro;
	 //VStr	: string[length(AVStr)]	 = AVStr;
	 Intro	: string = AIntro;
	 VStr	: string = AVStr;
    var	 R	: TRect;
	 Dialog	: PDialog;
	 S	: string;
    begin
      R.Assign(0, 0, 41, 13);
      Dialog := New(PDialog, Init(R, 'About'));
      With Dialog^ do
	begin
	Options := Options or ofCentered;
	R.Grow(-1, -2);
	//FormatStr(S, '%s'^M^C'Memory available: %d'^M^C'[%s mode]',
	//	sparam(@Intro,
	//	dparam(MemAvail,
	//	sparam(@VStr,
	//		nil)))^
	//	);
	S := Format('%s'#13'[%s mode]', [Intro, VStr]);

	Insert(New(PStaticText, Init(R, S)));
	R.Assign(16, 10, 26, 12);
	Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));
	HelpCtx := hcDialogs;
	end;
      ExecView(Dialog);
      Dispose(Dialog, Done);
    end;

//    procedure DoChime;
//    begin
//      If BeepOn then
//	begin
//	Sound(1047);
//	Delay(50);
//	If (Event.InfoPtr = nil) or (PTimeView(Event.InfoPtr)^.Min = 0) then
//	  begin
//	  NoSound;
//	  Delay(50);
//	  Sound(2094);
//	  end
//	 else
//	  Sound(523);
//	Delay(100);
//	NoSound;
//	end;
//    end;

//    procedure DoRecDialog;
//    var  P : PDmxEditTbl;
//    begin
//      P := Event.InfoPtr;
//      If (P <> nil) then
//	begin
//	If (P^.WorkingData = @Accounts) then AccountDialog(P)
//	else
//	If (P^.WorkingData = @Payroll)	then PayrollDialog(PDmxPayroll(P))
//	else
//	If (P^.WorkingData = @BusyData) then BusyDialog(P);
//	end;
//    end;

//    procedure PrintPageTop;
//    var  S : string;
//    begin
//      S := PWindow(PDmxReport(Event.InfoPtr)^.DMX^.Owner)^.Title^;
//      PDmxReport(Event.InfoPtr)^.PrintLn(S);  { prints window title }
//    end;

//    procedure PrintPageEnd;
//    begin
//      With PDmxReport(Event.InfoPtr)^ do
//	If (succ(pred(LastRecord) div PageSize) > 1) then
//	  PrnPageEnd(Event)
//	 else
//	  PDmxReport(Event.InfoPtr)^.PrintLn('tvDMX 2.5');
//    end;

begin
  TApplication.HandleEvent(Event);
  If (Event.What and evMessage <> 0) then
    begin
    Case Event.Command of
      cmAbout:		About;
//      cmAccounts:	AccountWindow;
//      cmPayroll:	PayrollWindow;
//      cmBusy:		BusyWindow;
//      cmHex:		HexWindow;
//      cmInvoice:	InvoiceFormWin;
//      cmRecDialog:	DoRecDialog;
//      cmChime:		DoChime;
//      cmPrint:		If PrnSetOptions(hcDialogs,hcDialogs,hcDialogs) = cmOK
//			 then PrnCurrentDMX;
//      cmPRN_SetOptions:	PrnSetOptions(hcDialogs,hcDialogs,hcDialogs);
//      cmPRN_NewPage:	PrintPageTop;
//      cmPRN_EndPage:	PrintPageEnd;
     else
      Exit;
      end;
    If (Event.What = evCommand) then ClearEvent(Event);
    end;
end;


procedure TMyApp.InitMenuBar;
var  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~S~amples', hcMain, NewMenu(
      NewItem('~A~ccounts', '',    kbNoKey, cmAccounts,hcAccounts,
      NewItem('Pa~y~roll',  '',    kbNoKey, cmPayroll, hcPayroll,
      NewItem('~B~usy',     'F4',  kbF4,    cmBusy,    hcBusy,
      NewItem('~H~ex',	    '',    kbNoKey, cmHex,     hcHex,
      NewItem('~I~nvoice',  '',    kbNoKey, cmInvoice, hcInvoice,
      NewLine(
      NewItem('~P~rint',    'F9',  kbF9,    cmPrint,   hcPrint,
      NewItem('~D~ialog',   'F2',  kbF2,    cmDialog,  hcDialog,
      NewLine(
      NewItem('e~X~it',   'Alt-X', kbAltX,  cmQuit,    hcExit,
      nil))))))))))),
    NewSubMenu('~W~indow', hcWindow, NewMenu(
      NewItem('~S~ize/Move', 'Ctrl-F5', kbCtrlF5, cmResize, hcResize,
      NewItem('~Z~oom',      'F5',  kbF5,    cmZoom,	hcZoom,
      NewItem('~T~ile',      '',    kbNoKey, cmTile,	hcTile,
      NewItem('C~a~scade',   '',    kbNoKey, cmCascade, hcCascade,
      NewItem('~N~ext',      'F6',  kbF6,    cmNext,	hcNext,
      NewItem('~P~revious',  'Shift-F6', kbShiftF6, cmPrev, hcPrev,
      NewItem('~C~lose', 'Alt-F3',  kbAltF3, cmClose,	hcClose,
      NewLine(
      NewItem('~U~ser screen', 'Alt-F5',  kbAltF5, cmUserScreen, hcUserScr,
      nil)))))))))),
//    NewSubMenu('~O~ptions', hcOptions, NewMenu(
//      NewSoundItem(hcSound,
//      NewVideoItem(hcVideo,
//      NewItem('~P~rint options...','', kbNoKey, cmPRN_SetOptions, hcPrnOpt,
//      nil)))),
    nil //)
  )))));
end;


procedure TMyApp.InitStatusLine;
var  R:	TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PMyStatusLine, Init(R,
    NewStatusDef(hcNoContext, hcDeskTop - 1,
      NewStatusKey('tvDMX',		kbNoKey,cmAbout,
      nil),
    NewStatusDef(hcDeskTop, hcDialogs - 1,
      NewStatusKey('tv~DMX~  ',	kbNoKey,cmAbout,
      NewStatusKey('~F2~ Dialog',	kbF2,	cmDialog,
      NewStatusKey('~F5~ Zoom',	kbF5,	cmZoom,
      NewStatusKey('~F6~ Next',	kbF6,	cmNext,
      NewStatusKey('~F9~ Print',	kbF9,	cmPrint,
      NewStatusKey('~F10~ Menu',	kbF10,	cmMenu,
      nil)))))),
    NewStatusDef(hcDialogs, hcMenus - 1,
      NewStatusKey('~Esc~ Cancel',	kbEsc,	cmCancel,
      nil),
    NewStatusDef(hcMenus, $FFFF,
      NewStatusKey('tv~DMX~',		kbNoKey,cmAbout,
      nil),
    nil))))
  ));
end;


procedure TMyApp.AccountWindow;
var  
  R: TRect;
  W: PDmxWindow;
begin
  AssignWinRect(R, length(AccountLabel) + 2, 0);
  // WriteLn(Format('Rect: [%d, %d, %d, %d]', [R.A.X, R.A.Y, R.B.X, R.B.Y]));
  W := New(PDmxEditTblWin, Init(R,	{ window rectangle }
		'Accounts',		{ window title }
		wnNextAvail,		{ window number }
		AccountInfo,		{ template string }
		Accounts,		{ data records }
		sizeof(Accounts),	{ data size }
		AccountLabel,		{ heading label }
		7));			{ indicator width }
  W^.HelpCtx := hcAccWin;
  DeskTop^.Insert(ValidView(W));
end;


var  
  MyApp  : TMyApp;

begin
  { set default printing options }
  //PrnOpt.Dest	 := 0;					{ default output=PRN }
  //PrnOpt.Options := PrnOpt.Options and not repLineNums;	{ no line numbers }
  //PrnOpt.Options := PrnOpt.Options or repExtChars;	{ extended chars }
  //PrnOpt.Len	 :=  55;				{ rows per page }
  //PrnOpt.Wid	 :=  80;				{ maximum page width }

  // InitializeData;
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.

