{ EasyCRT v4.02 }

{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Runtime Library        }
{       Windows CRT Interface Unit                      }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit EasyCrt;

{$S-}

interface

uses WinTypes, WinProcs, Win31, WinDos, EasyGDI, Bitmaps, strings;

const
  ScreenSize: TPoint = (X: 80; Y: 29{RWH 25}); { Screen buffer dimensions }
  Cursor: TPoint = (X: 0; Y: 0);            { Cursor location }
  Origin: TPoint = (X: 0; Y: 0);            { Client area origin }
  InactiveTitle: PChar = '(Inactive %s)';   { Inactive window title }
  AutoTracking: Boolean = True;             { Track cursor on Write? }
  CheckEOF: Boolean = False;                { Allow Ctrl-Z for EOF? }
  CheckBreak: Boolean = True;               { Allow Ctrl-C for break? }
  firstline:integer = 0;
var
  WindowTitle: array[0..79] of Char;        { CRT window title }

procedure InitWinCrt;
procedure DoneWinCrt;

procedure WriteBuf(Buffer: PChar; Count: Word);
procedure WriteChar(Ch: Char);

function KeyPressed: Boolean;
function ReadKey: Char;
function ReadBuf(Buffer: PChar; Count: Word): Word;

procedure GotoXY(X, Y: Integer);
function WhereX: Integer;
function WhereY: Integer;
procedure ClrScr;
procedure ClrEol;

procedure CursorTo(X, Y: Integer);
procedure ScrollTo(X, Y: Integer);
procedure TrackCursor;

procedure AssignCrt(var F: Text);

{  RUSS   }

const
  boxshape        = 0;
  fillboxshape    = 1;

  windowx    = 0;
  windowy    = 1;
  windoww    = 2;
  windowh    = 3;
  clientw    = 4;
  clienth    = 5;
  idealh     = 6;
  idealw     = 7;
  CRTcolumns = 8;
  CRTrows    = 9;

  caption    = 0;
  borders    = 1;
  scrollbar  = 2;
  minbox     = 3;
  maxbox     = 4;
  sysmenu    = 5;
  enabled    = 6;

  autotrack    = 0;
  restrictsize = 1;
  keyscroll    = 2;
  thumbtrack   = 3;
  colorcrt     = 4;

  VK_LBUTTON   = $01;
  VK_RBUTTON   = $02;
  VK_CANCEL    = $03;
  VK_MBUTTON   = $04;
  VK_BACK      = $08;
  VK_TAB       = $09;
  VK_CLEAR     = $0C;
  VK_RETURN    = $0D;
  VK_SHIFT     = $10;
  VK_CONTROL   = $11;
  VK_MENU      = $12;
  VK_PAUSE     = $13;
  VK_CAPITAL   = $14;
  VK_ESCAPE    = $1B;
  VK_SPACE     = $20;
  VK_PRIOR     = $21;
  VK_NEXT      = $22;
  VK_END       = $23;
  VK_HOME      = $24;
  VK_LEFT      = $25;
  VK_UP        = $26;
  VK_RIGHT     = $27;
  VK_DOWN      = $28;
  VK_SELECT    = $29;
  VK_EXECUTE   = $2B;
  VK_SNAPSHOT  = $2C;
  VK_INSERT    = $2D;
  VK_DELETE    = $2E;
  VK_HELP      = $2F;
  VK_0         = $30;
  VK_1         = $31;
  VK_2         = $32;
  VK_3         = $33;
  VK_4         = $34;
  VK_5         = $35;
  VK_6         = $36;
  VK_7         = $37;
  VK_8         = $38;
  VK_9         = $39;
  VK_A         = $41;
  VK_B         = $42;
  VK_C         = $43;
  VK_D         = $44;
  VK_E         = $45;
  VK_F         = $46;
  VK_G         = $47;
  VK_H         = $48;
  VK_I         = $49;
  VK_J         = $4A;
  VK_K         = $4B;
  VK_L         = $4C;
  VK_M         = $4D;
  VK_N         = $4E;
  VK_O         = $4F;
  VK_P         = $50;
  VK_Q         = $51;
  VK_R         = $52;
  VK_S         = $53;
  VK_T         = $54;
  VK_U         = $55;
  VK_V         = $56;
  VK_W         = $57;
  VK_X         = $58;
  VK_Y         = $59;
  VK_Z         = $5A;
  VK_NUMPAD0   = $60;
  VK_NUMPAD1   = $61;
  VK_NUMPAD2   = $62;
  VK_NUMPAD3   = $63;
  VK_NUMPAD4   = $64;
  VK_NUMPAD5   = $65;
  VK_NUMPAD6   = $66;
  VK_NUMPAD7   = $67;
  VK_NUMPAD8   = $68;
  VK_NUMPAD9   = $69;
  VK_MULTIPLY  = $6A;
  VK_ADD       = $6B;
  VK_SEPARATOR = $6C;
  VK_SUBTRACT  = $6D;
  VK_DECIMAL   = $6E;
  VK_DIVIDE    = $6F;
  VK_F1        = $70;
  VK_F2        = $71;
  VK_F3        = $72;
  VK_F4        = $73;
  VK_F5        = $74;
  VK_F6        = $75;
  VK_F7        = $76;
  VK_F8        = $77;
  VK_F9        = $78;
  VK_F10       = $79;
  VK_F11       = $7A;
  VK_F12       = $7B;
  VK_F13       = $7C;
  VK_F14       = $7D;
  VK_F15       = $7E;
  VK_F16       = $7F;
  VK_F17       = $80;
  VK_F18       = $81;
  VK_F19       = $82;
  VK_F20       = $83;
  VK_F21       = $84;
  VK_F22       = $85;
  VK_F23       = $86;
  VK_F24       = $87;
  VK_NUMLOCK   = $90;
  VK_SCROLL    = $91;


{ CRT COLOR TEXT FUNCTIONS }
var foreground, background: longint;
procedure setcolors(f,b:longint);
procedure colorspot(x,y:integer);
procedure colorspots(x1,y1,x2,y2,shape:integer);
function getspotFcolor(x,y:integer):longint;
function getspotBcolor(x,y:integer):longint;

{ CRT WINDOW FUNCTIONS }

procedure settitle(lbl:string);
function gettitle: string;
procedure minimize;
procedure maximize;
procedure restore;
procedure show;
procedure hide;
procedure setpos(x,y: integer);
procedure setsize(w,h: integer);
procedure propersize;
procedure setscreensize(rows,cols:Byte);
function getpos(index:integer):integer;
procedure setborder(index,setting: integer);
procedure setbehave(aspect:integer; behavior:boolean);
function getbehave(aspect:integer):boolean;
const CrtWindow: HWnd = 0;                  { CRT window handle }
      Focused: Boolean = False;             { CRT window focused? }


{ CRT INPUT FUNCTIONS }

procedure resetkeys;
function inkey:word;
function inkeyasc:char;
procedure showcursor;
procedure hidecursor;
function mousex: integer;
function mousey: integer;
var ldown,rdown: boolean;
    lastclick: points;
procedure getclick;


{ GRAPHICS FUNCTIONS }

var CRT:BMP;
    TheFont:FONT;


{ PROGRAM OR INFORMATION FUNCTIONS }

procedure unfreeze;
procedure delay(milliseconds:longint);
procedure startdelay(var t: longint);
procedure finishdelay(milliseconds,t:longint);
function FileOpen(path,ftype,extension: string):string;
function FileSave(path,ftype,extension: string):string;
function apppath: string;
function appdir: string;

{  /RUSS  }

implementation

{ Double word record }

type
  LongRec = record
    Lo, Hi: Integer;
  end;

{ MinMaxInfo array }

type
  PMinMaxInfo = ^TMinMaxInfo;
  TMinMaxInfo = array[0..4] of TPoint;

{ Scroll key definition record }

type
  TScrollKey = record
    Key: Byte;
    Ctrl: Boolean;
    SBar: Byte;
    Action: Byte;
  end;

{ CRT window procedure }

function CrtWinProc(Window: HWnd; Message, WParam: Word;
  LParam: Longint): Longint; export; forward;

{ CRT window class }

const
  CrtClass: TWndClass = (
    style: CS_DBLCLKS;
    lpfnWndProc: @CrtWinProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TPWinCrt');

const
{RWH CrtWindow: HWnd = 0;}              { CRT window handle }
{  FirstLine: Integer = 0;               { First line in circular buffer }
  KeyCount: Integer = 0;                { Count of keys in KeyBuffer }
  Created: Boolean = False;       	{ CRT window created? }
{RWH Focused: Boolean = False; }        { CRT window focused? }
  Reading: Boolean = False;             { Reading from CRT window? }
  Painting: Boolean = False;            { Handling wm_Paint? }

var
  SaveExit: Pointer;                    { Saved exit procedure pointer }
  ScreenBuffer: PChar;                  { Screen buffer pointer }
  ClientSize: TPoint;                   { Client area dimensions }
  Range: TPoint;                        { Scroll bar ranges }
  CharSize: TPoint;                     { Character cell size }
  CharAscent: Integer;                  { Character ascent }
  DC: HDC;                              { Global device context }
  PS: TPaintStruct;                     { Global paint structure }
  SaveFont: HFont;                      { Saved device context font }
  KeyBuffer: array[0..63] of Char;      { Keyboard type-ahead buffer }

{ Scroll keys table }

const
  ScrollKeyCount = 12;
  ScrollKeys: array[1..ScrollKeyCount] of TScrollKey = (
    (Key: vk_Left;  Ctrl: False; SBar: sb_Horz; Action: sb_LineUp),
    (Key: vk_Right; Ctrl: False; SBar: sb_Horz; Action: sb_LineDown),
    (Key: vk_Left;  Ctrl: True;  SBar: sb_Horz; Action: sb_PageUp),
    (Key: vk_Right; Ctrl: True;  SBar: sb_Horz; Action: sb_PageDown),
    (Key: vk_Home;  Ctrl: False; SBar: sb_Horz; Action: sb_Top),
    (Key: vk_End;   Ctrl: False; SBar: sb_Horz; Action: sb_Bottom),
    (Key: vk_Up;    Ctrl: False; SBar: sb_Vert; Action: sb_LineUp),
    (Key: vk_Down;  Ctrl: False; SBar: sb_Vert; Action: sb_LineDown),
    (Key: vk_Prior; Ctrl: False; SBar: sb_Vert; Action: sb_PageUp),
    (Key: vk_Next;  Ctrl: False; SBar: sb_Vert; Action: sb_PageDown),
    (Key: vk_Home;  Ctrl: True;  SBar: sb_Vert; Action: sb_Top),
    (Key: vk_End;   Ctrl: True;  SBar: sb_Vert; Action: sb_Bottom));

{ Return the smaller of two integer values }



{   RUSS   }

const easycrt_icon = 1;

var existscrollv, existscrollh, enablescrollkeys, nazisize, thumbtracking, usecolors: boolean;
    FColors, BColors: pchar;

function ScreenPtr(X, Y: Integer): PChar; forward; {internal}
procedure InitDeviceContext; forward;
procedure donedevicecontext; forward;
procedure Terminate; forward;
function Max(X, Y: Integer): Integer; forward;

{ COLOR CRT TEXT FUNCTIONS }

const nochars = 4;
procedure clearcolors; {internal}
  var n: longint;
  begin
    for n := 0 to ScreenSize.X * ScreenSize.Y - 1 do
      begin
        plongint(@Fcolors[n*4])^ := foreground;
        plongint(@Bcolors[n*4])^ := background;
      end;
  end;
procedure makecolors; {internal}
  begin
    GetMem(FColors, (ScreenSize.X * ScreenSize.Y) * nochars);
    GetMem(BColors, (ScreenSize.X * ScreenSize.Y) * nochars);
  end;
function getFcolor(X,Y:integer):plongint; {internal}
  begin
    Inc(Y, FirstLine);
    if Y >= ScreenSize.Y then Dec(Y, ScreenSize.Y);
    getFcolor := @FColors[ (Y * ScreenSize.X + X)*nochars ];
  end;
function getBcolor(X,Y:integer):plongint; {internal}
  begin
    Inc(Y, FirstLine);
    if Y >= ScreenSize.Y then Dec(Y, ScreenSize.Y);
    getBcolor := @BColors[ (Y * ScreenSize.X + X)*nochars ] ;
  end;

procedure setspotcolors(X,Y:integer); {internal}
  begin
    getFcolor(X,Y)^ := foreground;
    getBcolor(X,Y)^ := background;
  end;
procedure setlinecolors(X1,Y1,X2:integer); {internal}
  var n: integer;
  begin
    for n := X1 to X2 do
      begin
        setspotcolors(n,Y1);
      end;
  end;
procedure spotout(DC: HDC; X,Y:integer); {internal}
  var Bcolor: longint;
  begin
    SetTextColor(DC,getFcolor(X,Y)^);
    Bcolor := getBcolor(X,Y)^;
    if (Bcolor<0) then
      setbkmode(DC, transparent)
    else
      begin
        setbkmode(DC, OPAQUE);
        setbkcolor(DC, Bcolor);
      end;
    Textout(DC,(X - Origin.X) * CharSize.X,
               (Y - Origin.y) * Charsize.Y,
                ScreenPtr(X, Y), 1);
   end;
procedure lineout(DC: HDC; X1,Y1,X2:integer); {internal}
  var n: integer;
  begin
    for n:= X1 to X2-1 do
      begin
        spotout(DC,n,Y1);
      end;
  end;
procedure killcolors; {internal}
  begin
    FreeMem(FColors, ScreenSize.X * ScreenSize.Y * nochars);
    FreeMem(BColors, ScreenSize.X * ScreenSize.Y * nochars);
  end;

procedure setcolors(f,b:longint);
  begin
    foreground := f;
    background := b;
  end;

procedure colorspot(x,y:integer);
  begin
    setspotcolors(x-1,y-1);
    initdevicecontext;
    spotout(DC,x-1,y-1);
    donedevicecontext;
  end;

procedure colorspots(x1,y1,x2,y2,shape:integer);
  var i,j,k: integer;
      r,s,t: real;
  begin
    dec(x1); dec(y1); dec(x2); dec(y2);
    initdevicecontext;
    case shape of
    boxshape:
      begin
        for i := x1 to x2 do
          begin
            setspotcolors(i,y1); spotout(DC,i,y1);
            setspotcolors(i,y2); spotout(DC,i,y2);
          end;
        for i := y1 to y2 do
          begin
            setspotcolors(x1,i); spotout(DC,x1,i);
            setspotcolors(x2,i); spotout(DC,x2,i);
          end;
      end;
    fillboxshape:
      begin
        for i := x1 to x2 do
          for j := y1 to y2 do
            begin
              setspotcolors(i,j); spotout(DC,i,j);
            end;
      end;
    end;
    donedevicecontext;
  end;

function getspotFcolor(x,y:integer):longint;
  begin
    getspotFcolor := getFcolor(X-1,Y-1)^;
  end;

function getspotBcolor(x,y:integer):longint;
  begin
    getspotBcolor := getBcolor(X-1,Y-1)^;
  end;

{ CRT WINDOW FUNCTIONS }

procedure settitle(lbl:string);
  begin
    SetWindowText(CrtWindow, pc(lbl));
    StrCopy(WindowTitle, pc(lbl))
  end;

function gettitle: string;
  var text: array[0..255] of char;
      l : integer;
  begin
    l := getwindowtext(CrtWindow,text,255);
    gettitle := strpas(text);
  end;

procedure minimize;
  begin
    ShowWindow(CrtWindow, sw_minimize);
    UpdateWindow(CrtWindow);
  end;

procedure maximize;
  begin
    ShowWindow(CrtWindow, sw_maximize);
    UpdateWindow(CrtWindow);
  end;

procedure restore;
  begin
    ShowWindow(CrtWindow, sw_restore);
    UpdateWindow(CrtWindow);
  end;

procedure show;
  begin
    ShowWindow(CrtWindow, sw_show);
    UpdateWindow(CrtWindow);
  end;

procedure hide;
  begin
    ShowWindow(CrtWindow, sw_hide);
    UpdateWindow(CrtWindow);
  end;

procedure setpos(x,y: integer);
  begin
    setwindowpos(crtwindow,0,x,y,0,0,SWP_NOZORDER or SWP_NOSIZE);
  end;

procedure setsize(w,h: integer);
  begin
    setwindowpos(crtwindow,0,0,0,w,h,SWP_NOZORDER or SWP_NOMOVE);
  end;

procedure propersize;
  var size: tminmaxinfo;
  begin
    sendmessage(CrtWindow,WM_GETMINMAXINFO,0,longint(@size));
    setsize(size[1].x,size[1].y);
  end;

procedure setscreensize(rows,cols:Byte);
  var size: tminmaxinfo;
  begin
    if usecolors then killcolors;
    FreeMem(ScreenBuffer, ScreenSize.X * ScreenSize.Y);
    screensize.x := cols;
    screensize.y := rows;
    GetMem(ScreenBuffer, ScreenSize.X * ScreenSize.Y);
    if usecolors then makecolors;
    Range.X := Max(0, ScreenSize.X - ClientSize.X);
    Range.Y := Max(0, ScreenSize.Y - ClientSize.Y);
    ClrScr;
    if nazisize then propersize;
  end;

function getpos(index:integer):integer;
  var windowpos: trect;
  var size: tminmaxinfo;
  begin
    getwindowrect(Crtwindow,windowpos);
    GetClientRect(Crtwindow,windowpos);
    case index of
    windowx:                                             {x coordinate}
        begin
          getwindowrect(Crtwindow,windowpos);            
          getpos := windowpos.left;
        end;
    windowy:                                             {y coordinate}
        begin
          getwindowrect(Crtwindow,windowpos);            
          getpos := windowpos.top;
        end; 
    windoww:                                              {width}
        begin
          getwindowrect(Crtwindow,windowpos);            
          getpos := windowpos.right-windowpos.left;
        end;
    windowh:                                             {height}
        begin
          getwindowrect(Crtwindow,windowpos);            
          getpos := windowpos.bottom-windowpos.top;
        end;

    clientw:                                             {client width}
        begin
          GetClientRect(Crtwindow,windowpos);            
          getpos := windowpos.right-windowpos.left;
        end;
    clienth:                                             {client height}
        begin
          GetClientRect(Crtwindow,windowpos);
          getpos := windowpos.bottom-windowpos.top;
        end;                
    idealh:    
        begin
          sendmessage(CrtWindow,WM_GETMINMAXINFO,0,longint(@size));  {windowminmaxinfo(@size);}
          getpos := size[1].x;
        end;
    idealw:   
        begin
          sendmessage(CrtWindow,WM_GETMINMAXINFO,0,longint(@size));  {windowminmaxinfo(@size);}
          getpos := size[1].y;
        end;
    CRTcolumns:  getpos := screensize.x;                          {CRT Columns}
    CRTrows:     getpos := screensize.y;                          {CRT Rows}
    end;
  end;

procedure setborder(index,setting: integer);
  var now,new: longint;
      nowx,newx:longint;
  begin
    now  := getwindowlong(CrtWindow, GWL_Style);
    case index of
    caption: { 0=no caption 1=caption} 
         case setting of
         0:   new := now and not WS_CAPTION
         else new := now or WS_CAPTION; end;
    borders: { 0=no border 1=thin border 2=thick border }
         case setting of
         0:   new := now and not (ws_border or ws_thickframe or ws_caption);
         1:   new := now and not (ws_thickframe) or ws_border;
         else new := now or ws_thickframe or ws_border; end;
    scrollbar: { 0=no scrollb 1=vertical scrollb 2=horizontal scrollb 3=both }
         case setting of
         0:   begin
                new := now and not (ws_hscroll or ws_vscroll);
                existscrollh := false;  existscrollv := false;
              end;
         1:   begin
                new := now and (not ws_hscroll) or ws_vscroll;
                existscrollh := false;  existscrollv := true;
              end;
         2:   begin
                new := now and (not ws_vscroll) or ws_hscroll;
                existscrollh := true;  existscrollv := false;
              end;
         else begin
                new := now or ws_hscroll or ws_vscroll;
                existscrollh := true;  existscrollv := true;
              end; end;
    minbox: { 0=no minimize box 1=minimize box}
         case setting of
         0:   new := now and not WS_MINIMIZEBOX 
         else new := now or WS_CAPTION or WS_MINIMIZEBOX; end;
    maxbox: { 0=no maximize box 1=minimize box}
         case setting of
         0:   new := now and not WS_MAXIMIZEBOX 
         else new := now or WS_CAPTION or WS_MAXIMIZEBOX; end;
    sysmenu: { 0=no system menu 1=system menu}
         case setting of
         0:   new := now and not WS_SYSMENU
         else new := now or WS_CAPTION or WS_SYSMENU; end;
    enabled: { 0=not disabled 1=disabled}
         case setting of
         0:   new := now and not WS_DISABLED
         else new := now or WS_DISABLED; end;
    else new := now; end;
    setwindowlong(CrtWindow, GWL_Style,new);
    setwindowpos(crtwindow,0,0,0,0,0,SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or SWP_DRAWFRAME);
    InvalidateRect(CrtWindow, nil,false);
    updatewindow(CrtWindow);
  end;

procedure setbehave(aspect:integer; behavior:boolean);
  begin
    case aspect of
      autotrack:     autotracking     := behavior;
      restrictsize:  nazisize         := behavior;
      keyscroll:     enablescrollkeys := behavior;
      thumbtrack:    thumbtracking    := behavior;
      colorcrt:
         begin
           if (not usecolors) and behavior then makecolors;
           if (usecolors) and (not behavior) then killcolors;
           usecolors := behavior;
         end;
    end;
  end;

function getbehave(aspect:integer):boolean;
  begin
    case aspect of
      autotrack:    getbehave := autotracking;
      restrictsize: getbehave := nazisize;
      keyscroll:    getbehave := enablescrollkeys;
      thumbtrack:   getbehave := thumbtracking;
      colorcrt:     getbehave := usecolors;
    end;
  end;

{ CRT INPUT FUNCTIONS }

var ink: word;

procedure resetkeys;
  begin
    ink := 0;
    keycount := 0;
  end;

function inkey:word;
  begin  
    unfreeze;
    inkey:=ink;
  end;

function inkeyasc:char;
  begin
    unfreeze;
    inkeyasc:=chr(0);
    if keypressed then 
      begin
        inkeyasc := KeyBuffer[0];
        Dec(KeyCount);
        Move(KeyBuffer[1], KeyBuffer[0], KeyCount);
      end;
  end;

function mousex: integer;
  var mousepos: tpoint;
  begin
    getcursorpos(mousepos);
    ScreenToClient(CrtWindow, mousepos);
    DPtoLP(CRT^.dchandle,mousepos,1);
    mousex:=mousepos.x;
  end;

function mousey: integer;
  var mousepos: tpoint;
  begin
    getcursorpos(mousepos);
    ScreenToClient(CrtWindow, mousepos);
    DPtoLP(CRT^.dchandle,mousepos,1);
    mousey:=mousepos.y;
  end;

procedure getclick;
  begin
    repeat
      unfreeze;
    until ldown;
  end;

{ GRAPHICS FUNCTIONS }

{ PROGRAM FUNCTIONS }

procedure unfreeze; 
  var Msg: TMsg;
  begin  
    while PeekMessage(Msg, CrtWindow, 0, 0, pm_Remove) do
    begin
      if Msg.Message = WM_QUIT then terminate; 
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  end;

procedure delay(milliseconds:longint);
  var t: longint;
  begin
    t:=gettickcount;
    repeat
      unfreeze;
    until gettickcount-t>=milliseconds;
  end;

procedure startdelay(var t: longint);
  begin
    t := gettickcount;
  end;

procedure finishdelay(milliseconds,t:longint);
  begin
    repeat
      unfreeze;
    until gettickcount-t>=milliseconds;
  end;

function apppath: string;
  begin
    apppath := getapppath(hinstance);
  end;

function appdir: string;
  begin
    appdir := getappdir(hinstance);
  end;

function FileOpen(path,ftype,extension:string):string;
  begin
    fileopen := wfileopen(crtwindow,path,ftype,extension)
  end;

function FileSave(path,ftype,extension: string):string;
  begin
    filesave := wfilesave(crtwindow,path,ftype,extension);
  end;

{   /RUSS   }

function Min(X, Y: Integer): Integer;
begin
  if X < Y then Min := X else Min := Y;
end;

{ Return the larger of two integer values }

function Max(X, Y: Integer): Integer;
begin
  if X > Y then Max := X else Max := Y;
end;

{ Allocate device context }

procedure InitDeviceContext;
begin
  if Painting then
    DC := BeginPaint(CrtWindow, PS) else
    DC := GetDC(CrtWindow);
  SaveFont := SelectObject(DC, GetStockObject(System_Fixed_Font));
end;

{ Release device context }

procedure DoneDeviceContext;
begin
  SelectObject(DC, SaveFont);
  if Painting then
    EndPaint(CrtWindow, PS) else
    ReleaseDC(CrtWindow, DC);
end;

{ Show caret }

procedure ShowCursor;
begin
  CreateCaret(CrtWindow, 0, CharSize.X, 2);
  SetCaretPos((Cursor.X - Origin.X) * CharSize.X,
    (Cursor.Y - Origin.Y) * CharSize.Y + CharAscent);
  ShowCaret(CrtWindow);
end;

{ Hide caret }

procedure HideCursor;
begin
  DestroyCaret;
end;

{ Update scroll bars }

procedure SetScrollBars;
begin
  if existscrollh then
    begin
      SetScrollRange(CrtWindow, sb_Horz, 0, Max(1, Range.X), False);
      SetScrollPos(CrtWindow, sb_Horz, Origin.X, True);
    end;
  if existscrollv then
    begin
      SetScrollRange(CrtWindow, sb_Vert, 0, Max(1, Range.Y), False);
      SetScrollPos(CrtWindow, sb_Vert, Origin.Y, True); 
    end;
end;

{ Terminate CRT window }

procedure Terminate;
begin
  if Focused and Reading then HideCursor;
  Halt(255);
end;

{ Set cursor position }

procedure CursorTo(X, Y: Integer);
begin
  Cursor.X := Max(0, Min(X, ScreenSize.X - 1));
  Cursor.Y := Max(0, Min(Y, ScreenSize.Y - 1));
end;

{ Scroll window to given origin }

procedure ScrollTo(X, Y: Integer);
begin
  if Created then
  begin
    X := Max(0, Min(X, Range.X));
    Y := Max(0, Min(Y, Range.Y));
    if (X <> Origin.X) or (Y <> Origin.Y) then
    begin
      if X <> Origin.X then SetScrollPos(CrtWindow, sb_Horz, X, True);
      if Y <> Origin.Y then SetScrollPos(CrtWindow, sb_Vert, Y, True);
      ScrollWindow(CrtWindow,
	(Origin.X - X) * CharSize.X,
	(Origin.Y - Y) * CharSize.Y, nil, nil);
      Origin.X := X;
      Origin.Y := Y;
{RWH} SetWindowOrg(CRT^.DChandle,Origin.X*Charsize.X,Origin.Y*Charsize.Y);
      UpdateWindow(CrtWindow);
    end;
  end;
end;

{ Scroll to make cursor visible }

procedure TrackCursor;
begin
  ScrollTo(Max(Cursor.X - ClientSize.X + 1, Min(Origin.X, Cursor.X)),
    Max(Cursor.Y - ClientSize.Y + 1, Min(Origin.Y, Cursor.Y)));
end;

{ Return pointer to location in screen buffer }

function ScreenPtr(X, Y: Integer): PChar;
begin
  Inc(Y, FirstLine);
  if Y >= ScreenSize.Y then Dec(Y, ScreenSize.Y);
  ScreenPtr := @ScreenBuffer[Y * ScreenSize.X + X];
end;

{ Update text on cursor line }

procedure ShowText(L, R: Integer);
var n: integer;
begin
  if L < R then
  begin
    InitDeviceContext;
    if usecolors then
      lineout(DC, L, Cursor.Y, R)
    else
    TextOut(DC, (L - Origin.X) * CharSize.X,
      (Cursor.Y - Origin.Y) * CharSize.Y,
      ScreenPtr(L, Cursor.Y), R - L);
    DoneDeviceContext;
  end;
end;

{ Write text buffer to CRT window }

procedure WriteBuf(Buffer: PChar; Count: Word);
var
  L, R: Integer;

procedure NewLine;
begin
  ShowText(L, R);
  L := 0;
  R := 0;
  Cursor.X := 0;
  Inc(Cursor.Y);
  if Cursor.Y = ScreenSize.Y then
  begin
    Dec(Cursor.Y);
    Inc(FirstLine);
    if FirstLine = ScreenSize.Y then FirstLine := 0;
    FillChar(ScreenPtr(0, Cursor.Y)^, ScreenSize.X, ' ');
    if usecolors then setlinecolors(0,Cursor.Y,ScreenSize.X-1);
    ScrollWindow(CrtWindow, 0, -CharSize.Y, nil, nil);
    UpdateWindow(CrtWindow);
    ShowText(0,Screensize.X);
  end;
end;

begin
  InitWinCrt;
  L := Cursor.X;
  R := Cursor.X;
  while Count > 0 do
  begin
    case Buffer^ of
      #32..#255:
	begin
	  ScreenPtr(Cursor.X, Cursor.Y)^ := Buffer^;
          if usecolors then setspotcolors(Cursor.X,Cursor.Y);
	  Inc(Cursor.X);
	  if Cursor.X > R then R := Cursor.X;
	  if Cursor.X = ScreenSize.X then NewLine;
	end;
      #13:
	NewLine;
      #8:
	if Cursor.X > 0 then
	begin
	  Dec(Cursor.X);
	  ScreenPtr(Cursor.X, Cursor.Y)^ := ' ';
	  if Cursor.X < L then L := Cursor.X;
	end;
      #7:
        MessageBeep(0);
    end;
    Inc(Buffer);
    Dec(Count);
  end;
  ShowText(L, R);
  if AutoTracking then TrackCursor;
end;

{ Write character to CRT window }

procedure WriteChar(Ch: Char);
begin
  WriteBuf(@Ch, 1);
end;

{ Return keyboard status }

function KeyPressed: Boolean;
var
  M: TMsg;
begin
  InitWinCrt;
  while PeekMessage(M, 0, 0, 0, pm_Remove) do
  begin
    if M.Message = wm_Quit then Terminate;
    TranslateMessage(M);
    DispatchMessage(M);
  end;
  KeyPressed := KeyCount > 0;
end;

{ Read key from CRT window }

function ReadKey: Char;
begin
  TrackCursor;
  if not KeyPressed then
  begin
    Reading := True;
    if Focused then ShowCursor;
    repeat until KeyPressed;
    if Focused then HideCursor;
    Reading := False;
  end;
  ReadKey := KeyBuffer[0];
  Dec(KeyCount);
  Move(KeyBuffer[1], KeyBuffer[0], KeyCount);
end;

{ Read text buffer from CRT window }

function ReadBuf(Buffer: PChar; Count: Word): Word;
var
  Ch: Char;
  I: Word;
begin
  I := 0;
  repeat
    Ch := ReadKey;
    case Ch of
      #8:
	if I > 0 then
	begin
	  Dec(I);
	  WriteChar(#8);
	end;
      #32..#255:
	if I < Count - 2 then
	begin
	  Buffer[I] := Ch;
	  Inc(I);
	  WriteChar(Ch);
	end;
    end;
  until (Ch = #13) or (CheckEOF and (Ch = #26));
  Buffer[I] := Ch;
  Inc(I);
  if Ch = #13 then
  begin
    Buffer[I] := #10;
    Inc(I);
    WriteChar(#13);
  end;
  TrackCursor;
  ReadBuf := I;
end;

{ Set cursor position }

procedure GotoXY(X, Y: Integer);
begin
  CursorTo(X - 1, Y - 1);
end;

{ Return cursor X position }

function WhereX: Integer;
begin
  WhereX := Cursor.X + 1;
end;

{ Return cursor Y position }

function WhereY: Integer;
begin
  WhereY := Cursor.Y + 1;
end;

{ Clear screen }

procedure ClrScr;
begin
  InitWinCrt;
  FillChar(ScreenBuffer^, ScreenSize.X * ScreenSize.Y, ' ');
  if usecolors then clearcolors; 
  Longint(Cursor) := 0;
  Longint(Origin) := 0;
  SetScrollBars;
  InvalidateRect(CrtWindow, nil, True);
  UpdateWindow(CrtWindow);
end;

{ Clear to end of line }

procedure ClrEol;
begin
  InitWinCrt;
  FillChar(ScreenPtr(Cursor.X, Cursor.Y)^, ScreenSize.X - Cursor.X, ' ');
  if usecolors then SetLineColors(Cursor.X,Cursor.Y,Screensize.X-1);
  ShowText(Cursor.X, ScreenSize.X);
end;

{ wm_Create message handler }

procedure WindowCreate;
begin
  Created := True;
  GetMem(ScreenBuffer, ScreenSize.X * ScreenSize.Y);
  if usecolors then makecolors;
  FillChar(ScreenBuffer^, ScreenSize.X * ScreenSize.Y, ' ');
  if usecolors then clearcolors;
  if not CheckBreak then
    EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close,
      mf_Disabled + mf_Grayed);
end;

{ wm_Paint message handler }

procedure WindowPaint;
var
  X1, X2, Y1, Y2: Integer;
begin
  Painting := True;
  InitDeviceContext;
  X1 := Max(0, PS.rcPaint.left div CharSize.X + Origin.X);
  X2 := Min(ScreenSize.X,
    (PS.rcPaint.right + CharSize.X - 1) div CharSize.X + Origin.X);
  Y1 := Max(0, PS.rcPaint.top div CharSize.Y + Origin.Y);
  Y2 := Min(ScreenSize.Y,
    (PS.rcPaint.bottom + CharSize.Y - 1) div CharSize.Y + Origin.Y);
  while Y1 < Y2 do
  begin
    if usecolors then
      LineOut(DC, X1, Y1, X2)
    else
      TextOut(DC, (X1 - Origin.X) * CharSize.X, (Y1 - Origin.Y) * CharSize.Y,
        ScreenPtr(X1, Y1), X2 - X1);
    Inc(Y1);
  end;
  DoneDeviceContext;
  Painting := False;
end;

{ wm_VScroll and wm_HScroll message handler }

procedure WindowScroll(Which, Action, Thumb: Integer);
var
  X, Y: Integer;

function GetNewPos(Pos, Page, Range: Integer): Integer;
begin
  case Action of
    sb_LineUp: GetNewPos := Pos - 1;
    sb_LineDown: GetNewPos := Pos + 1;
    sb_PageUp: GetNewPos := Pos - Page;
    sb_PageDown: GetNewPos := Pos + Page;
    sb_Top: GetNewPos := 0;
    sb_Bottom: GetNewPos := Range;
    sb_ThumbPosition: GetNewPos := Thumb;
{RWH}  sb_ThumbTrack: GetNewPos := Thumb;
  else
    GetNewPos := Pos;
  end;
end;

begin
  X := Origin.X;
  Y := Origin.Y;
  case Which of
    sb_Horz: X := GetNewPos(X, ClientSize.X div 2, Range.X);
    sb_Vert: Y := GetNewPos(Y, ClientSize.Y{RWH}-1, Range.Y);
  end;
  ScrollTo(X, Y);
end;

{ wm_Size message handler }

procedure WindowResize(X, Y: Integer);
begin
  if Focused and Reading then HideCursor;
  ClientSize.X := X div CharSize.X;
  ClientSize.Y := Y div CharSize.Y;
  Range.X := Max(0, ScreenSize.X - ClientSize.X);
  Range.Y := Max(0, ScreenSize.Y - ClientSize.Y);
  Origin.X := Min(Origin.X, Range.X);
  Origin.Y := Min(Origin.Y, Range.Y);
  SetScrollBars;
  if Focused and Reading then ShowCursor;
end;

{ wm_GetMinMaxInfo message handler }

procedure WindowMinMaxInfo(MinMaxInfo: PMinMaxInfo);
var
  X, Y: Integer;
  Metrics: TTextMetric;

begin
  InitDeviceContext;

  GetTextMetrics(DC, Metrics);
  CharSize.X := Metrics.tmMaxCharWidth;
  CharSize.Y := Metrics.tmHeight + Metrics.tmExternalLeading;
  CharAscent := Metrics.tmAscent;
  X := Min(ScreenSize.X * CharSize.X + ord(existscrollv)*GetSystemMetrics(sm_CXVScroll),
    GetSystemMetrics(sm_CXScreen)) + GetSystemMetrics(sm_CXFrame) * 2;
  Y := Min(ScreenSize.Y * CharSize.Y + ord(existscrollh)*GetSystemMetrics(sm_CYHScroll) +
    GetSystemMetrics(sm_CYCaption), GetSystemMetrics(sm_CYScreen)) +
    GetSystemMetrics(sm_CYFrame) * 2;
  {rwh}
  MinMaxInfo^[1].x := X;
  MinMaxInfo^[1].y := Y;
  if nazisize then
    begin
      MinMaxInfo^[3].x := CharSize.X * 16 + GetSystemMetrics(sm_CXVScroll) +
        GetSystemMetrics(sm_CXFrame) * 2;
      MinMaxInfo^[3].y := CharSize.Y * 4 + GetSystemMetrics(sm_CYHScroll) +
        GetSystemMetrics(sm_CYFrame) * 2 + GetSystemMetrics(sm_CYCaption);
      MinMaxInfo^[4].x := X;
      MinMaxInfo^[4].y := Y;
    end;
  DoneDeviceContext;
end;

{ wm_Char message handler }

procedure WindowChar(Ch: Char);
begin
  if CheckBreak and (Ch = #3) then Terminate;
  if KeyCount < SizeOf(KeyBuffer) then
  begin
    KeyBuffer[KeyCount] := Ch;
    Inc(KeyCount);
  end;
end;

{ wm_KeyDown message handler }

procedure WindowKeyDown(KeyDown: Byte);
var
  CtrlDown: Boolean;
  I: Integer;
begin
  if CheckBreak and (KeyDown = vk_Cancel) then Terminate;
  CtrlDown := GetKeyState(vk_Control) < 0;
  if enablescrollkeys then 
  for I := 1 to ScrollKeyCount do
    with ScrollKeys[I] do
      if (Key = KeyDown) and (Ctrl = CtrlDown) then
      begin
	WindowScroll(SBar, Action, 0);
	Exit;
      end;
end;

{ wm_SetFocus message handler }

procedure WindowSetFocus;
begin
  Focused := True;
  if Reading then ShowCursor;
end;

{ wm_KillFocus message handler }

procedure WindowKillFocus;
begin
  {rwh}
  ink := 0;
  if Reading then HideCursor;
  Focused := False;
end;

{ wm_Destroy message handler }

procedure WindowDestroy;
begin
{RWH} killbmp(CRT);
  if usecolors then killcolors;
  FreeMem(ScreenBuffer, ScreenSize.X * ScreenSize.Y);
  Longint(Cursor) := 0;
  Longint(Origin) := 0;
  PostQuitMessage(0);
  Created := False;
end;

{ CRT window procedure }

function CrtWinProc(Window: HWnd; Message, WParam: Word;
  LParam: Longint): Longint;
begin
  CrtWinProc := 0;
  CrtWindow := Window;

      case Message of
        wm_Create: WindowCreate;
        wm_Paint: WindowPaint;
        wm_VScroll: WindowScroll(sb_Vert, WParam, LongRec(LParam).Lo);
        wm_HScroll: WindowScroll(sb_Horz, WParam, LongRec(LParam).Lo);
        wm_Size: WindowResize(LongRec(LParam).Lo, LongRec(LParam).Hi);
        wm_GetMinMaxInfo: WindowMinMaxInfo(PMinMaxInfo(LParam));
        wm_Char: WindowChar(Char(WParam));
    {RWH}
        wm_KeyDown: begin ink:=wParam; WindowKeyDown(Byte(WParam)); end;
        wm_KeyUp: begin if ink=wParam then ink:=0; end;
        wm_SetFocus: WindowSetFocus;
        wm_KillFocus: WindowKillFocus;
  {RWH} wm_Close: donewincrt;
        wm_Destroy: WindowDestroy;
        wm_lButtonDown:
          begin
            ldown:=true;
            lastclick.x := LOWORD(lParam);
            lastclick.y := HIWORD(lParam);
            setcapture(CRTWindow);
          end;
        wm_lButtonUp:
          begin
            ldown:=false;
            releasecapture;
          end;
        wm_rButtonDown:
          begin
            rdown:=true;
            setcapture(CRTWindow);
          end;
        wm_rButtonUp:
          begin
            rdown:=false;
            releasecapture;
          end;
      else
        CrtWinProc := DefWindowProc(Window, Message, WParam, LParam);
      end;
end;

{ Text file device driver output function }

function CrtOutput(var F: TTextRec): Integer; far;
begin
  if F.BufPos <> 0 then
  begin
    WriteBuf(PChar(F.BufPtr), F.BufPos);
    F.BufPos := 0;
    KeyPressed;
  end;
  CrtOutput := 0;
end;

{ Text file device driver input function }

function CrtInput(var F: TTextRec): Integer; far;
begin
  F.BufEnd := ReadBuf(PChar(F.BufPtr), F.BufSize);
  F.BufPos := 0;
  CrtInput := 0;
end;

{ Text file device driver close function }

function CrtClose(var F: TTextRec): Integer; far;
begin
  CrtClose := 0;
end;

{ Text file device driver open function }

function CrtOpen(var F: TTextRec): Integer; far;
begin
  if F.Mode = fmInput then
  begin
    F.InOutFunc := @CrtInput;
    F.FlushFunc := nil;
  end else
  begin
    F.Mode := fmOutput;
    F.InOutFunc := @CrtOutput;
    F.FlushFunc := @CrtOutput;
  end;
  F.CloseFunc := @CrtClose;
  CrtOpen := 0;
end;

{ Assign text file to CRT device }

procedure AssignCrt(var F: Text);
begin
  with TTextRec(F) do
  begin
    Handle := $FFFF;
    Mode := fmClosed;
    BufSize := SizeOf(Buffer);
    BufPtr := @Buffer;
    OpenFunc := @CrtOpen;
    Name[0] := #0;
  end;
end;

{ Create CRT window if required }

procedure InitWinCrt;
begin
  if not Created then
  begin
    CrtWindow := CreateWindow(
      CrtClass.lpszClassName,
      WindowTitle,
      ws_OverlappedWindow or ws_HScroll or ws_VScroll,
      cw_UseDefault, cw_UseDefault,
      cw_UseDefault, cw_UseDefault,
      0,
      0,
      HInstance,
      nil);
    ShowWindow(CrtWindow,CmdShow);
    UpdateWindow(CrtWindow);
{RWH} CRT := makewindowBMP(crtwindow);
      CRT^.TheFont := @TheFont
  end;
end;


{ Destroy CRT window if required }

procedure DoneWinCrt;
begin
  if Created then DestroyWindow(CrtWindow);
  Halt(0);
end;

{ WinCrt unit exit procedure }

procedure ExitWinCrt; far;
var
  P: PChar;
  Message: TMsg;
  Title: array[0..127] of Char;
begin
  ExitProc := SaveExit;
  if Created and (ErrorAddr = nil) then
  begin
    P := WindowTitle;
    WVSPrintF(Title, InactiveTitle, P);
    SetWindowText(CrtWindow, Title);
    EnableMenuItem(GetSystemMenu(CrtWindow, True), sc_Close, mf_Enabled);
    CheckBreak := False;
    while GetMessage(Message, 0, 0, 0) do
    begin
      TranslateMessage(Message);
      DispatchMessage(Message);
    end;
  end;
end;

begin
  if HPrevInst = 0 then
  begin
    CrtClass.hInstance := HInstance;
{RWH CrtClass.hIcon := LoadIcon(0, idi_Application); }
     CrtClass.hIcon := LoadIcon(HInstance, pchar(easycrt_icon));

    CrtClass.hCursor := LoadCursor(0, idc_Arrow);
    CrtClass.hbrBackground := GetStockObject(White_Brush);
    RegisterClass(CrtClass);
  end;
  AssignCrt(Input);
  Reset(Input);
  AssignCrt(Output);
  Rewrite(Output);
  GetModuleFileName(HInstance, WindowTitle, SizeOf(WindowTitle));
  SaveExit := ExitProc;
  ExitProc := @ExitWinCrt;
  existscrollh := TRUE;
  existscrollv := TRUE;
  nazisize := TRUE;
  enablescrollkeys := FALSE;
  thumbtracking := TRUE;
  usecolors := true;
  foreground := color[0];
  background := color[15];
end.

{ Russnotes

Donewincrt - called from program, destroys window, puts up a halt(0)

Windowdestroy - WM_DESTROY Handler closes up the window, posts WM_QUIT to end message loop

Exitwincrt - part of big exit chain when Program runs out of code

}