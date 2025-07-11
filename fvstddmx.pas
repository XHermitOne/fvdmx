
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}
{							}
{	StdDMX	 --Standard tvDMX Interface Unit	}
{	tvDMX	 --data editing project (ver 2.x)	}
{							}
{	Copyright (c) 1992,93	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}

unit FvStdDMX;

// {$B-,D+,O+,R-,X+,V- }
//{$mode objfpc}{$H+}

interface

uses  
  Objects, Drivers, Views, Dialogs, App, MsgBox,
  RSet, fvGizma, DmxGizma, fvDMX,
  DB;

const	
	CDmxEditDlg	= #19#20#06#06#01#02; { similar to CInputLine }
			 {  |  |  |  |	|  | }
  {  1 normal fields -------+  |  |  |	|  | }
  {  2 normal selected field --+  |  |	|  | }
  {  3 read-only selected field --+  |	|  | }
  {  4 locked field -----------------+	|  | }
  {  5 delimiter -----------------------+  | }
  {  6 border -----------------------------+ }

type
    //PDmxEditDlg	 = ^TDmxEditDlg;  { tvDMX editor for dialog boxes }
    //PInputFields = ^TInputFields; { line-editor for dialog boxes }
    //PValidFields = ^TValidFields; { validating line-editor }

    PDmxViewer	 = ^TDmxViewer;   { tvDMX data scroller window }
    TDmxViewer	 =  OBJECT(TLtdWindow)
	DMX	: PDmxEditor;
      constructor Init(var Bounds: TRect;  ATitle: TTitleStr;  ANumber: Sw_Integer;
		       ATemplate: string; ADataSource: TDataSource;  BSize: longint;
		       ALabels: string);
      // constructor Load(var S: TStream);
      procedure InitDMX(ATemplate: string; ADataSource: TDataSource;
			ALabels, ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
      function	NewDmxLabels(var ALabels ) : PDmxLink;	VIRTUAL;
      // procedure Store(var S: TStream);
      function	Valid(Command: word) : boolean;  VIRTUAL;
    end;


    PDmxWindow	 = ^TDmxWindow;   { tvDMX data editor window  }
    TDmxWindow	 =  OBJECT(TDmxViewer)
      constructor Init(var Bounds: TRect;  ATitle: TTitleStr;  ANumber: Sw_Integer;
		       ATemplate: string; ADataSource: TDataSource;  BSize: longint;
		       ALabels: string;	IndLen	: integer);

      procedure InitDMX(ATemplate: string; ADataSource: TDataSource;
			ALabels, ARecInd: PDmxLink;
			BSize: longint);  VIRTUAL;
      function	NewRecInd(Len: integer) : PDmxLink;  VIRTUAL;
    end;


implementation

{ ══ TDmxViewer ════════════════════════════════════════════════════════ }

constructor TDmxViewer.Init(var Bounds	   : TRect;
			    ATitle     : TTitleStr;
			    ANumber    : Sw_Integer;
			    ATemplate  : string;
			    ADataSource: TDataSource;
			    BSize	   : longint;
			    ALabels    : string);
// const  NilWin	: array[0..1] of Longint = (0,0);
const 
  NilWin: TRect = (A: (X: 0; Y: 0); B: (X: 0; Y: 0));
begin
  // TLtdWindow.Init(Bounds, TRect(NilWin), ATitle, ANumber);
  // TLtdWindow.Init(Bounds, NilWin, ATitle, ANumber);
  inherited Init(Bounds, NilWin, ATitle, ANumber);

  InitDMX(ATemplate, ADataSource, NewDmxLabels(ALabels), nil, BSize);
  Options := Options or ofTileable;
end;


{
constructor TDmxViewer.Load(var S: TStream);
begin
  TLtdWindow.Load(S);
  GetSubViewPtr(S, DMX);
end;
}


procedure TDmxViewer.InitDMX(ATemplate: string;
			     ADataSource: TDataSource;
			     ALabels,ARecInd: PDmxLink;
			     BSize: longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If (ALabels <> nil) then Inc(R.A.Y, ALabels^.Size.Y);
  Insert(New(PDmxScroller, Init(ATemplate, ADataSource, BSize, R, ALabels,
				   StandardScrollBar(sbHorizontal),
				   StandardScrollBar(sbVertical))));
end;


function  TDmxViewer.NewDmxLabels(var ALabels) : PDmxLink;
begin
  If (@ALabels = nil) or (string(ALabels) = '') then
    NewDmxLabels := nil
   else
    NewDmxLabels := New(PDmxLabels, InitInsert(@Self, @ALabels));
end;


{
procedure TDmxViewer.Store(var S: TStream);
begin
  TLtdWindow.Store(S);
  PutSubViewPtr(S, DMX);
end;
}


function  TDmxViewer.Valid(Command: word) : boolean;
var  Len : integer;
     V	 : boolean;
begin
  V := TLtdWindow.Valid(Command);
  If V and (Command = cmValid) then
    begin
    If (DMX = nil) then DMX := Message(@Self, evCommand, cmDMX_RollCall, nil);
    If (DMX <> nil) and (DMX^.Labels <> nil) then
      begin
      If (Limit.A.Y > 0) then Limit.A.Y := succ(Size.Y - DMX^.Size.Y);
      Limit.B.X	:= PDmxLabels(DMX^.Labels)^.Len + (Size.X - DMX^.Size.X);
      Len	:= length(GetTitle(MaxViewWidth)) + 12;
      If (Len > ScreenWidth) then Len := ScreenWidth;
      If (Len > Limit.B.X) then Limit.B.X := Len;
      If (Limit.B.X < MinWinSize.X) then Limit.B.X := MinWinSize.X;
      end;
    end;
  Valid := V;
end;


{ ══ TDmxWindow ════════════════════════════════════════════════════════ }

constructor TDmxWindow.Init(var Bounds	   : TRect;
			    ATitle     : TTitleStr;
			    ANumber    : Sw_Integer;
			    ATemplate  : string;
			    ADataSource: TDataSource;
			    BSize	   : longint;
			    ALabels    : string;
			    IndLen     : integer);
// const  NilWin	: array[0..1] of Longint = (0,0);
const 
  NilWin: TRect = (A: (X: 0; Y: 0); B: (X: 0; Y: 0));
begin
  // TLtdWindow.Init(Bounds, TRect(NilWin), ATitle, ANumber);
  // TLtdWindow.Init(Bounds, NilWin, ATitle, ANumber);

  inherited Init(Bounds, ATitle, ANumber, ATemplate, ADataSource, BSize, ALabels);

  InitDMX(ATemplate, ADataSource, NewDmxLabels(ALabels), NewRecInd(IndLen), BSize);
  Options := Options or ofTileable;
end;


procedure TDmxWindow.InitDMX(ATemplate: string; ADataSource: TDataSource;
			     ALabels, ARecInd: PDmxLink;
			     BSize: longint);
var  R	: TRect;
begin
  GetExtent(R);
  R.Grow(-1,-1);
  If (ALabels <> nil) then Inc(R.A.Y, ALabels^.Size.Y);
  Insert(New(PDmxEditor, Init(ATemplate, ADataSource, BSize, R,
				ALabels, ARecInd,
				StandardScrollBar(sbHorizontal),
				StandardScrollBar(sbVertical))));
end;


function  TDmxWindow.NewRecInd(Len: integer) : PDmxLink;
begin
  If (Len <= 0) then
    NewRecInd := nil
   else
    NewRecInd := New(PDmxRecInd, InitInsert(@Self, Len));
end;


{ ══════════════════════════════════════════════════════════════════════ }

end.
