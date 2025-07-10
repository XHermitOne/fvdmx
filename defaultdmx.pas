
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}

unit DefaultDmx;

interface

uses
  //Objects, 
  //Drivers, 
  //Memory, 
  //Dialogs, 
  Menus;
  //HistList, 
  //Views, 
  //App, 
  //MsgBox, 

const

//{$IFDEF VER60 }
    hcNew	= $FF01;
    hcOpen	= $FF02;
    hcSave	= $FF03;
    hcSaveAs	= $FF04;
    hcSaveAll	= $FF05;
    hcChangeDir	= $FF06;
    hcDosShell	= $FF07;
    hcExit	= $FF08;

    hcUndo	= $FF10;
    hcCut	= $FF11;
    hcCopy	= $FF12;
    hcPaste	= $FF13;
    hcClear	= $FF14;

    hcTile	= $FF20;
    hcCascade	= $FF21;
    hcCloseAll	= $FF22;
    hcResize	= $FF23;
    hcZoom	= $FF24;
    hcNext	= $FF25;
    hcPrev	= $FF26;
    hcClose	= $FF27;
//{$ENDIF }


function  DefaultMenuHint(AHelpCtx: word) : string;
    { returns a context-sensitive hint string for any the Std????MenuItems
      that were introduced with Turbo Pascal 7.0. }

function  DefaultWindowHint(AHelpCtx: word) : string;
    { returns a context-sensitive hint string for StdWindowMenuItems }


implementation

{ ══════════════════════════════════════════════════════════════════════ }


function DefaultMenuHint(AHelpCtx: word) : string;
begin
  Case AHelpCtx of
    hcNew:	DefaultMenuHint := 'Create a new file in a new window';
    hcOpen:	DefaultMenuHint := 'Locate and open a file in a new window';
    hcSave:	DefaultMenuHint := 'Save the file in the active window';
    hcSaveAs:	DefaultMenuHint := 'Save the current file under a different name, directory or drive';
    hcSaveAll:	DefaultMenuHint := 'Save all modified files';
    hcChangeDir:DefaultMenuHint := 'Choose a new default directory';
    hcDosShell:	DefaultMenuHint := 'Temporarily exit to DOS';
    hcExit:	DefaultMenuHint := 'Exit program';

    hcUndo:	DefaultMenuHint := 'Undo the previous editor operation';
    hcCut:	DefaultMenuHint := 'Remove the selected text and put it in the clipboard';
    hcCopy:	DefaultMenuHint := 'Copy the selected text into the clipboard';
    hcPaste:	DefaultMenuHint := 'Insert the selected text from the clipboard at the cursor position';
    hcClear:	DefaultMenuHint := 'Delete the selected text';

    hcTile:	DefaultMenuHint := 'Arrange windows on desktop by tiling';
    hcCascade:	DefaultMenuHint := 'Arrange windows on desktop by cascading';
    hcCloseAll:	DefaultMenuHint := 'Close all windows on the desktop';
    hcResize:	DefaultMenuHint := 'Change the size or position of the active window';
    hcZoom:	DefaultMenuHint := 'Enlarge or restore the size of the active window';
    hcNext:	DefaultMenuHint := 'Make the next window active';
    hcPrev:	DefaultMenuHint := 'Make the previous window active';
    hcClose:	DefaultMenuHint := 'Close the active window';
   else		DefaultMenuHint := '';
    end;
end;


function DefaultWindowHint(AHelpCtx: word) : string;
begin
  Case AHelpCtx of
    hcTile:	DefaultWindowHint := 'Arrange windows on desktop by tiling';
    hcCascade:	DefaultWindowHint := 'Arrange windows on desktop by cascading';
    hcCloseAll:	DefaultWindowHint := 'Close all windows on the desktop';
    hcResize:	DefaultWindowHint := 'Change the size or position of the active window';
    hcZoom:	DefaultWindowHint := 'Enlarge or restore the size of the active window';
    hcNext:	DefaultWindowHint := 'Make the next window active';
    hcPrev:	DefaultWindowHint := 'Make the previous window active';
    hcClose:	DefaultWindowHint := 'Close the active window';
   else		DefaultWindowHint := '';
    end;
end;

end.
