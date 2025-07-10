
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}
{							}
{	fvGIZMA   --Turbo Vision Accessories		}
{							}
{	Copyright (c) 1992,94	Randolph Beck		}
{				P.O. Box  56-0487	}
{				Orlando, FL 32856	}
{				CIS:  72361,753		}
{							}
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}

unit fvGIZMA;

interface

uses
    // Dos, 
    SysUtils, DateUtils,
    Crt, 
    Objects, Drivers, Memory, Dialogs, Menus, HistList, Views, App, MsgBox, 
    RSet, DmxGizma;


const
    BeepOn	   : boolean = TRUE;	{ allows beeping from cmBeep event }
    //PreserveScreen : boolean = TRUE;	{ restore screen after done }
    PreserveScreen : boolean = False;	{ restore screen after done }

    SoundIndOn		= ' ON';	{ On & Off must be the same length }
    SoundIndOff		= 'OFF';

type

    PLtdFrame		= ^TLtdFrame;
    TLtdFrame		=  OBJECT(TFrame)
      procedure Draw;  VIRTUAL;
    end;

    PLtdWindow		= ^TLtdWindow;
    TLtdWindow		=  OBJECT(TWindow)
	Limit	: TRect;
      constructor Init(var Bounds,ALimit: TRect; ATitle: TTitleStr; ANumber: integer);
      constructor Load(var S: TStream);
      procedure ChangeBounds(var Bounds: TRect);  VIRTUAL;
      procedure InitFrame;  VIRTUAL;
      procedure Zoom;  VIRTUAL;
    end;


procedure AssignWinRect(var Bounds: TRect;  MaxX, MaxY: integer);
    { assigns a rectangle which cascades into the desktop }

function  wnNextAvail : integer;
    { finds the lowest available window number }


implementation


{ ══════════════════════════════════════════════════════════════════════ }


procedure AssignWinRect(var Bounds: TRect;  MaxX, MaxY: integer);
var  
  P: PView;
begin
// {$IFDEF VER60 }
//  DeskTop^.GetExtent(Bounds);
// {$ELSE }
  PApplication(Application)^.GetTileRect(Bounds);
// {$ENDIF }
  P := DeskTop^.Current;
  If (P <> nil) and (P^.Options and ofTileable = 0) then P := nil;
  If (P <> nil) then
    begin
      If (P^.Origin.X >= Bounds.A.X) and (P^.Origin.X < Bounds.B.X) then Bounds.A.X := succ(P^.Origin.X);
      If (P^.Origin.Y >= Bounds.A.Y) and (P^.Origin.Y < Bounds.B.Y) then Bounds.A.Y := succ(P^.Origin.Y);
      If (Bounds.B.X - Bounds.A.X < MinWinSize.X) or
         (Bounds.B.Y - Bounds.A.Y < MinWinSize.Y) then
      begin
//     {$IFDEF VER60 }
//      DeskTop^.GetExtent(Bounds);
//     {$ELSE }
        PApplication(Application)^.GetTileRect(Bounds);
//     {$ENDIF }
      end;
    end;
  If (MaxX > 0) and (Bounds.B.X - Bounds.A.X > MaxX) then Bounds.B.X := Bounds.A.X + MaxX;
  If (MaxY > 0) and (Bounds.B.Y - Bounds.A.Y > MaxY) then Bounds.B.Y := Bounds.A.Y + MaxY;
end;


{ ══════════════════════════════════════════════════════════════════════ }

function  wnNextAvail : integer;
var  
  wn : integer;
  function  UsedWN(P: PWindow) : boolean;
  begin
    UsedWN := (P <> PWindow(DeskTop^.Background)) and (P^.Number = wn)
  end;

begin
  wn := 0;
  Repeat Inc(wn) until (DeskTop^.FirstThat(@UsedWN) = nil);
  wnNextAvail := wn;
end;


{ ══ TLtdFrame ═════════════════════════════════════════════════════════ }


procedure TLtdFrame.Draw;
{ draws a zoom icon if the LtdWindow is at maximum size }
var 
  XY : TPoint;
begin
  TFrame.Draw;
  If (State and sfActive <> 0) and (Owner <> nil) and (PWindow(Owner)^.Flags and wfZoom <> 0) then
  begin
    If (PLtdWindow(Owner)^.Limit.B.X > 0) then
      XY.X := PLtdWindow(Owner)^.Limit.B.X else XY.X := Owner^.Owner^.Size.X;
    If (PLtdWindow(Owner)^.Limit.B.Y > 0) then
      XY.Y := PLtdWindow(Owner)^.Limit.B.Y else XY.Y := Owner^.Owner^.Size.Y;
    If (Size.X >= XY.X) and (Size.Y >= XY.Y) then
      WriteStr((Size.X - 4), 0, #18, 5);
  end;
end;


{ ══ TLtdWindow ════════════════════════════════════════════════════════ }


constructor TLtdWindow.Init(var Bounds,ALimit	: TRect;
				ATitle		: TTitleStr;
				ANumber		: integer);
begin
  TWindow.Init(Bounds, ATitle, ANumber);
  Move(ALimit, Limit, sizeof(Limit));
end;


constructor TLtdWindow.Load(var S: TStream);
begin
  TWindow.Load(S);
  S.Read(Limit, sizeof(Limit));
end;


procedure TLtdWindow.ChangeBounds(var Bounds: TRect);
begin
  If (Limit.A.X > 0) and (Bounds.B.X - Bounds.A.X <= Size.X - Limit.A.X) then
    Bounds.B.X := Bounds.A.X + succ(Limit.A.X);
  If (Limit.A.Y > 0) and (Bounds.B.Y - Bounds.A.Y <= Size.Y - Limit.A.Y) then
    Bounds.B.Y := Bounds.A.Y + succ(Limit.A.Y);
  If (Limit.B.X > 0) and (Bounds.B.X - Bounds.A.X > Limit.B.X) then Bounds.B.X := Bounds.A.X + Limit.B.X;
  If (Limit.B.Y > 0) and (Bounds.B.Y - Bounds.A.Y > Limit.B.Y) then Bounds.B.Y := Bounds.A.Y + Limit.B.Y;
  TWindow.ChangeBounds(Bounds);
end;


procedure TLtdWindow.InitFrame;
var R : TRect;
begin
  GetExtent(R);
  Frame := New(PLtdFrame, Init(R));
end;


procedure TLtdWindow.Zoom;
var R  : TRect;
    XY : TPoint;
begin
  If (Limit.B.X = 0) or (Limit.B.X > Owner^.Size.X) then
    XY.X := Owner^.Size.X else XY.X := Limit.B.X;
  If (Limit.B.Y = 0) or (Limit.B.Y > Owner^.Size.Y) then
    XY.Y := Owner^.Size.Y else XY.Y := Limit.B.Y;
  If ((Size.X <> XY.X) or (Size.Y <> XY.Y)) then
  begin
    GetBounds(ZoomRect);
    Owner^.GetExtent(R);
    Locate(R);
  end
  else
    Locate(ZoomRect);
end;

{ ══════════════════════════════════════════════════════════════════════ }


end.
