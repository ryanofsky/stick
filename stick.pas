program whothehellcares;
uses wobjects, winprocs, wintypes,strings,commdlg, windos, mmsystem,wincrt;

{$R stick.res}

{--------------------------------------------------  Game Constants}

const fps = 20;
      gamespeed = 0.9;
      PinM = 100;
      path = 'C:\Russ\easycrt';
      resetscores = false;

{------------------------------------------------  Drawing Commands}

var  CrtWindow: Hwnd;

const
  color: array[-1..15] of longint = (
      -1                              ,   {color -1 Transparent   }
      0 + (256 *   0) + (65536 *   0) ,   {color 0  Black         }
      0 + (256 *   0) + (65536 * 170) ,   {color 1  Blue          }
      0 + (256 * 170) + (65536 *   0) ,   {color 2  Green         }
      0 + (256 * 170) + (65536 * 170) ,   {color 3  Cyan          }
    170 + (256 *   0) + (65536 *   0) ,   {color 4  Red           }
    170 + (256 *   0) + (65536 * 170) ,   {color 5  Magenta       }
    170 + (256 *  85) + (65536 *   0) ,   {color 6  Brown         }
    170 + (256 * 170) + (65536 * 170) ,   {color 7  White         }
     85 + (256 *  85) + (65536 *  85) ,   {color 8  Gray          }
     85 + (256 *  85) + (65536 * 255) ,   {color 9  Light Blue    }
     85 + (256 * 255) + (65536 *  85) ,   {color 10 Light Green   }  
     85 + (256 * 255) + (65536 * 255) ,   {color 11 Light Cyan    }
    255 + (256 *  85) + (65536 *  85) ,   {color 12 Light Red     }
    255 + (256 *  85) + (65536 * 255) ,   {color 13 Light Magenta }
    255 + (256 * 255) + (65536 *  85) ,   {color 14 Yellow        }
    255 + (256 * 255) + (65536 * 255) );  {color 15 Bright White  }

type SDC = ^StdDC;
     StdDC = record
       handle: HDC;
       ThePen, OldPen, NewPen: Hpen;
       TheBrush, OldBrush, NewBrush: HBrush;
       TheRegion, OldRegion, NewRegion: HRgn;
       TheBMP, OldBMP, NewBMP: HBitmap;
       TheFont, OldFont, NewFont: HFont;
       From: Thandle;
       Kind: Word;
       prpfont: tlogfont;
     end;

type HDC = THandle;
     BMP = THandle;
     Points = record
       x: Integer;
       y: Integer;
     end;

function makeDC(FromWhat:Thandle; Form:Word):SDC;
  var bob: sdc;
  begin
    bob:=new(SDC);
    with bob^ do
      begin
        if form=0 then handle:=getDC(fromwhat);
        if form=1 then handle:=createcompatibleDC(Fromwhat);
        Oldpen    :=  0;
        OldBrush  :=  0;
        OldRegion :=  0;
        OldBMP    :=  0;
        OldFont   :=  0;
        From      :=  Fromwhat;
        Kind      :=  Form;
      end;
    makeDC:=bob;
  end;

procedure killDC(var it: SDC);
  begin
    if it <> nil then
    with it^ do
      begin
        thepen:=selectobject(handle,oldpen);
        deleteobject(ThePen);
        thebrush:=selectobject(handle,oldbrush);
        deleteobject(TheBrush);
        thefont:=selectobject(handle,oldfont);
        deleteobject(Thefont);
        thebmp:=selectobject(handle,oldbmp);
        deleteobject(thebmp);
        if kind=0 then releaseDC(from,handle);
        if kind=1 then deleteDC(handle);
      end;
    if it<>nil then dispose(it);
    it := nil;
  end;

procedure setbmp(DC: SDC; Picture: BMP);
  begin
    if (DC <> nil) and (picture>0) then
    with DC^ do begin
      thebmp:=selectobject(handle,picture);
      if oldbmp=0 then oldbmp:=thebmp else deleteobject(thebmp);
    end;
  end;

procedure setpen(DC:SDC; color: longint; linestyle, width: integer);
  begin
    if DC<>nil then
    with DC^ do
      begin
        if color <> -1 then
          NewPen := CreatePen(linestyle, width, color)
        else
          NewPen := CreatePen(PS_NULL,width,0);
        thepen:=selectobject(handle,NewPen);
        if oldpen=0 then oldpen:=thepen else deleteobject(thepen);
        end;
  end;

procedure setbrush(DC:SDC; color,bcolor:longint; style: integer);
var brushstyle: tlogbrush;
  begin
    if DC<> nil then
    with DC^ do
      begin
        if bcolor < 0 then
          setbkmode(handle,1)
        else 
          begin
            setbkmode(handle,2);
            setbkcolor(handle,bcolor);
          end;

        if color < 0 then
          begin
            brushstyle.lbstyle:=BS_HOLLOW;
            newbrush:=CreateBrushIndirect(brushstyle);
          end
        else
          if style=0 then
            begin
              brushstyle.lbstyle:=BS_SOLID;
              brushstyle.lbcolor:=color;
              newbrush:=CreateBrushIndirect(brushstyle);
            end
          else
            newbrush:=createhatchbrush(style-1,color);;;
        thebrush:=selectobject(handle,NewBrush);
        if oldbrush=0 then oldbrush:=thebrush else deleteobject(thebrush);
      end;
  end;

function pc(st: string): pchar;
  var p: array[0..1024] of char;
  begin
    strpcopy(p,st);
    pc := @p;
  end;  

procedure setfont(DC:SDC; fontface:string; size,weight,italic,underline,strikeout:integer;angle:real );
  begin
    if DC<>nil then
    with DC^.prpfont do
      begin
        lfHeight         := -1*size;
        lfWidth          := 0;
        lfEscapement     := round(angle*10);
        lfWeight         := weight*100;
        lfItalic         := byte(italic);
        lfUnderline      := byte(underline);
        lfStrikeout      := byte(strikeout);
{       lfcharset }
{       lfOutprecision   := OUT_TT_PRECIS; }
        lfQuality        := PROOF_QUALITY;
        lfPitchAndFamily := DEFAULT_PITCH or FF_DONTCARE;
        StrCopy(lfFaceName,pc(fontface));
      end;
  end;

function getlng(DC:SDC; text:string):longint;
  var p:pchar;
  begin
    if dc<>nil then
    with DC^ do
      begin
        newfont:=createfontindirect(prpfont);
        thefont:=selectobject(handle,Newfont);
        if oldfont=0 then oldfont:=thefont else deleteobject(thefont);
        p:=pc(text);
        getlng:=loword(GetTextExtent(handle,p,strlen(p)));
      end;
  end;

procedure txt(DC: SDC; x,y,align:integer; color:longint; text:string);
var aln,lng:integer;
    p: pchar;
  begin
    if dc<>nil then
    with DC^ do
      begin
        newfont:=createfontindirect(prpfont);
        thefont:=selectobject(handle,Newfont);
        if oldfont=0 then oldfont:=thefont else deleteobject(thefont);
      end;
    if dc<>nil then
    with DC^ do
      begin
        case align of
          1: aln:=TA_LEFT;
          2: aln:=TA_RIGHT;
          3: aln:=TA_CENTER;
        end;
        settextalign(handle,aln);
        settextcolor(handle,color);
        lng:=setbkmode(handle,1);
        p:=pc(text);
        textout(handle,x,y,p,strlen(p));
        setbkmode(handle,lng);
      end;
  end;

procedure box(DC:SDC; x1,y1,x2,y2,x3,y3:integer);
  begin
    if dc<>nil then
    roundrect(DC^.handle,x1,y1,x2,y2,x3,y3);
  end;

procedure qcircle(DC:SDC; xpos,ypos,radiusw,radiush:integer);
var x1,y1,x2,y2,c,d:integer;
  begin
    x1:=xpos-radiusw;  y1:=ypos-radiush;  x2:=xpos+radiusw;  y2:=ypos+radiush;
    if dc<>nil then
    Ellipse(DC^.handle, X1,Y1,X2,Y2);
  end;

procedure qline(DC: SDC; x1,y1,x2,y2:integer);
var ends:array[1..2] of tpoint;
  begin
    ends[1].x:=x1;  ends[1].y:=y1;  ends[2].x:=x2;  ends[2].y:=y2;
    if dc<>nil then
    polyline(DC^.handle,ends,2);
  end;

procedure Qarc(DC: SDC; xpos,ypos,radiusw,radiush,angle1,angle2,way:integer);
var x1,y1,x2,y2,x3,y3,x4,y4,c,d:integer;
  begin
    x1:=xpos-radiusw;  y1:=ypos-radiush;  x2:=xpos+radiusw;  y2:=ypos+radiush;
    x3:=xpos+round(radiusw*(cos(angle1/180*pi))); y3:=ypos-round(radiush*(sin(angle1/180*pi)));
    x4:=xpos+round(radiusw*(cos(angle2/180*pi))); y4:=ypos-round(radiush*(sin(angle2/180*pi)));
    if dc<>nil then
    case way of
      0: arc(DC^.handle, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
      1: chord(DC^.handle, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
      2: pie(DC^.handle, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
    end;
  end;

function getred(color:longint):integer;
var red,green,blue: integer;
  begin
    blue:=color div 65536;
    green:=(color-blue*65536) div 256;
    red:=color-65536*blue-256*green;
    getred:=red;       
  end;

function getgreen(color:longint):integer;
var red,green,blue: integer;
  begin
    blue:=color div 65536;
    green:=(color-blue*65536) div 256;
    red:=color-65536*blue-256*green;
    getgreen:=green;       
  end;

function getblue(color:longint):integer;
var red,green,blue: integer;
  begin
    blue:=color div 65536;
    green:=(color-blue*65536) div 256;
    red:=color-65536*blue-256*green; 
    getblue:=blue;       
  end;

function gradient(color1,color2:longint; stepno,steps:integer):longint;
var red,green,blue: integer;
  begin
    red   := round(stepno/steps*(  getred(color2) -   getred(color1)) +   getred(color1));
    green := round(stepno/steps*(getgreen(color2) - getgreen(color1)) + getgreen(color1));
    blue  := round(stepno/steps*( getblue(color2) -  getblue(color1)) +  getblue(color1));
    gradient:=rgb(red,green,blue);
  end;

(* ------------     Bitmap Routines    -------------- *)


  var BitMapHandle: HBitmap;
    IconizedBits: HBitmap;
    IconImageValid: Boolean;
    Stretch: Boolean;
    Width, Height: LongInt;
procedure AHIncr; far; external 'KERNEL' index 114;
procedure GetBitmapData(var TheFile: File;
  BitsHandle: THandle; BitsByteSize: Longint);
type
  LongType = record
    case Word of
      0: (Ptr: Pointer);
      1: (Long: Longint);
      2: (Lo: Word;
	  Hi: Word);
  end;
var
  Count: Longint;
  Start, ToAddr, Bits: LongType;
begin
  Start.Long := 0;
  Bits.Ptr := GlobalLock(BitsHandle);
  Count := BitsByteSize - Start.Long;
  while Count > 0 do
  begin
    ToAddr.Hi := Bits.Hi + (Start.Hi * Ofs(AHIncr));
    ToAddr.Lo := Start.Lo;
    if Count > $4000 then Count := $4000;
    BlockRead(TheFile, ToAddr.Ptr^, Count);
    Start.Long := Start.Long + Count;
    Count := BitsByteSize - Start.Long;
  end;
  GlobalUnlock(BitsHandle);
end;
function OpenDIB(var TheFile: File): Boolean;
var
  bitCount: Word;
  size: Word;
  longWidth: Longint;
  DCHandle: HDC;
  BitsPtr: Pointer;
  BitmapInfo: PBitmapInfo;
  BitsHandle, NewBitmapHandle: THandle;
  NewPixelWidth, NewPixelHeight: Word;
begin
  OpenDIB := True;
  Seek(TheFile, 28);
  BlockRead(TheFile, bitCount, SizeOf(bitCount));
  if bitCount <= 8 then
  begin
    size := SizeOf(TBitmapInfoHeader) + ((1 shl bitCount) * SizeOf(TRGBQuad));
    BitmapInfo := MemAlloc(size);
    Seek(TheFile, SizeOf(TBitmapFileHeader));
    BlockRead(TheFile, BitmapInfo^, size);
    NewPixelWidth := BitmapInfo^.bmiHeader.biWidth;
    NewPixelHeight := BitmapInfo^.bmiHeader.biHeight;
    longWidth := (((NewPixelWidth * bitCount) + 31) div 32) * 4;
    BitmapInfo^.bmiHeader.biSizeImage := longWidth * NewPixelHeight;
    GlobalCompact(-1);
    BitsHandle := GlobalAlloc(gmem_Moveable or gmem_Zeroinit,
      BitmapInfo^.bmiHeader.biSizeImage);
    GetBitmapData(TheFile, BitsHandle, BitmapInfo^.bmiHeader.biSizeImage);
    DCHandle := CreateDC('Display', nil, nil, nil);
    BitsPtr := GlobalLock(BitsHandle);
    NewBitmapHandle :=
      CreateDIBitmap(DCHandle, BitmapInfo^.bmiHeader, cbm_Init, BitsPtr,
      BitmapInfo^, 0);
    DeleteDC(DCHandle);
    GlobalUnlock(BitsHandle);
    GlobalFree(BitsHandle);
    FreeMem(BitmapInfo, size);
    if NewBitmapHandle <> 0 then
    begin
      if BitmapHandle <> 0 then DeleteObject(BitmapHandle);
      BitmapHandle := NewBitmapHandle;
      Width := NewPixelWidth;
      Height := NewPixelHeight;
    end
    else
      OpenDIB := False;
  end
  else
    OpenDIB := False;
end;

function LoadBitmapFile(Name: PChar): Boolean;
var
  TheFile: File;
  TestWin30Bitmap: Longint;
  MemDC: HDC;
begin
  LoadBitmapFile := False;
  Assign(TheFile, Name);
  Reset(TheFile, 1);
  Seek(TheFile, 14);
  BlockRead(TheFile, TestWin30Bitmap, SizeOf(TestWin30Bitmap));
  if TestWin30Bitmap = 40 then
    if OpenDIB(TheFile) then
    begin
      LoadBitmapFile := True;
      IconImageValid := False;
    end
    else
      MessageBox(0, 'EASYCRT:  Unable to create Windows 3.0 bitmap from file.',
	Name, mb_Ok)
  else
      MessageBox(0, 'EASYCRT:  Not a Windows 3.0 bitmap file.  Convert using Paintbrush.', Name, mb_Ok);
  Close(TheFile);
end;

function loadbmp(filename:string):BMP;
begin
  bitmaphandle:=0;
  IconImageValid := False;
  Stretch := False;
  loadbitmapfile(pc(filename));
  loadbmp:=BitMapHandle;  
  bitmaphandle:=0;
end;

procedure Paint(PaintDC:HDC;  xpos,ypos,wth,ht:integer; Rop:longint; var PaintInfo: TPaintStruct);
var
  MemDC: HDC;
  OldBitmap: HBitmap;
  R: TRect;
  Info:tbitmap;
begin
  getobject(BitMapHandle,10,@info);
  width:=info.bmwidth;
  height:=info.bmheight;
  if BitMapHandle <> 0 then
  begin
    MemDC := CreateCompatibleDC(PaintDC);
      SelectObject(MemDC, BitMapHandle);
      if Stretch then
        begin
          GetClientRect(CrtWindow, R);
   	  SetCursor(LoadCursor(0, idc_Wait));
          SetStretchBltMode(PaintDC,3);
          StretchBlt(PaintDC, xpos, ypos, wth, ht, MemDC, 0, 0,
	    width, Height, Rop);  
	  SetCursor(LoadCursor(0, idc_Arrow));
        end
      else
        begin
          if wth <> 0 then width  := wth;
          if ht  <> 0 then height := ht;
	  BitBlt(PaintDC, xpos, ypos, Width, Height, MemDC, 0, 0, Rop);
        end;
    DeleteDC(MemDC);
  end;
end;

procedure drawbmp(DC: SDC; x,y: integer;  bmpname: bmp;  stretched,width,height:integer);
var info:tpaintstruct;
  begin
    IconImageValid := False;
    if stretched=0 then Stretch := False else stretch:=True;
    bitmaphandle:=bmpname;
    if dc<>nil then
    Paint(DC^.handle,x,y,width,height,srccopy,info);
  end;

procedure deletebmp(var thebmp:bmp);
begin
  deleteobject(thebmp);
  deleteobject(BitMapHandle);
end;

procedure maskbmp(DvC:SDC; x,y: integer;  themask,thepic: bmp;  stretched,wth,ht:integer);
var memdc,tempdc: HDC;
    Infob:tbitmap;
    info:tpaintstruct;
    dwidth,dheight,rwidth,rheight:integer;
    DC:HDC;
  begin
    DC:=DvC^.handle;
    IconImageValid := False;
    if stretched=0 then Stretch := False else stretch:=True;
    getobject(thepic,10,@infob); rwidth:=infob.bmwidth; rheight:=infob.bmheight;
    if wth <> 0 then dwidth  := wth else dwidth  :=rwidth;
    if ht  <> 0 then dheight := ht  else dheight :=rheight;;
    bitmaphandle:=themask; paint(DC,x,y,dwidth,dheight,dstinvert,info);   
    bitmaphandle:=themask; paint(DC,x,y,dwidth,dheight,srcpaint,info);  
    bitmaphandle:=themask; paint(DC,x,y,dwidth,dheight,dstinvert,info);  
    tempdc:=createcompatibledc(DC);    Selectobject(tempdc, thepic);
    memdc:=createcompatibledc(tempDC); SelectObject(memdc, thepic);
    BitBlt(tempDC,0,0,rWidth,rHeight, MemDC, 0, 0, srccopy);
    deletedc(memdc);
    memdc:=createcompatibledc(tempDC); SelectObject(memdc, themask);
    BitBlt(tempDC,0,0,rWidth,rHeight, MemDC, 0, 0, srcand);
    deletedc(memdc);
    StretchBlt(DC,X,Y,DWidth,DHeight,tempDC,0,0,RWidth,RHeight,srcpaint);
    deletedc(tempdc); 
  end;

procedure drawpicture(DC:HDC; x,y:integer; filename:string);
var info:tpaintstruct;
begin
  IconImageValid := False;
  Stretch := False;
  loadbitmapfile(pc(filename));
  Paint(DC,x,y,0,0,srccopy,info);
  deleteobject(BitMapHandle);
end;

function getwidth(thebmp:bmp):integer;
var Infob:tbitmap;
  begin
    getobject(thebmp,10,@infob);
    getwidth:=infob.bmwidth;
  end;

function getheight(thebmp:bmp):integer;
var Infob:tbitmap;
  begin
    getobject(thebmp,10,@infob);
    getheight:=infob.bmheight;
  end;

procedure unfreeze(Wnd: Hwnd);
var Msg: TMsg;
  begin  
    while PeekMessage(Msg, Wnd, 0, 0, pm_Remove) do
    begin
(*  Experimental--                                                       *)
      if Msg.Message = WM_QUIT then begin Application^.Done; halt; end;
      TranslateMessage(Msg);
(*  --Experimental                                                       *)
      DispatchMessage(Msg);
    end;
  end;

procedure defreeze;
var msg: TMsg;
  begin
    while PeekMessage(Msg,0,0,0,PM_REMOVE) do
    begin
      if Msg.Message = WM_QUIT then begin Application^.Done; halt; end;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  end;
 
procedure startdelay(var t: longint);
  begin
    t := gettickcount;
  end;

procedure finishdelay(milliseconds,t:longint; wnd:hwnd);
  begin
    repeat
      unfreeze(Wnd);
    until gettickcount-t>=milliseconds;
  end;

procedure delay(milliseconds:longint; Wnd:Hwnd);
var t: longint;
  begin
    t:=gettickcount;
    repeat
    unfreeze(Wnd);
    until gettickcount-t>=milliseconds;
  end;

function atan(x,y:real): real;
  begin                                 
    if y <> 0 then
      if x <> 0 then                  
        if x > 0 then                 
          atan := arctan(y/x)
        else
          if y > 0 then               
            atan := pi + arctan(y/x)
          else
            atan := arctan(y/x) - pi
      else                              
        if y >= 0 then
          atan := pi/2             
         else
          atan := -pi/2           
     else                               
      if x >= 0 then
        atan := 0                  
       else
        atan := - Pi                 
  end;                                

function asin(x: real): real;
  begin
    if x = 1 then
      asin := pi / 2
    else
      if x = - 1 then
        asin := pi / -2
      else
        asin := arctan(x / sqrt(1 - sqr(x)));
  end;

function acos(x: real): real;
  begin

   (* not mathematically correct, but painless way to fix program *)
      if abs(x) > 1 then acos:=pi else
   (* done *)
    if x = 0 then
      acos := pi / 2
    else
      if x < 0 then
        acos := pi - arctan(sqrt(1 - sqr(X)) / abs(X))
      else
        acos := arctan(sqrt(1 - sqr(X)) / abs(X))
   end;

function min(x,y: real): real;
  begin
    if x<y then min:=x else min:=y;
  end;

function max(x,y: real): real;
  begin
    if x>y then max:=x else max:=y;
  end;

function badtri(A,B,C:real): bool;
  begin
    A:=abs(a); B:=abs(b); c:=abs(c);
    if (a+b<c) or (b+c<a) or (a+c<b) then badtri:=true
    else badtri:=false;
  end;

function abovezero(number: integer):integer;
  begin
    if number < 0 then abovezero := 0
    else abovezero := number;
  end;

type TFilename = array [0..255] of Char;

function FileOpen(HWindow:hwnd):string;
const
  DefExt = 'sav';
var
  OpenFN      : TOpenFileName;
  Filter      : array [0..100] of Char;
  FullFileName: TFilename;
  WinDir      : array [0..145] of Char;
  filename    : pchar;
begin
  SetCurDir(path);
  StrCopy(FullFileName, '');
  FillChar(Filter, SizeOf(Filter), #0);  { Set up for double null at end }
  StrCopy(Filter, 'Game Files');
  StrCopy(@Filter[StrLen(Filter)+1], '*.sav');
  FillChar(OpenFN, SizeOf(TOpenFileName), #0);
  with OpenFN do
  begin
    hInstance     := HInstance;
    hwndOwner     := HWindow;
    lpstrDefExt   := DefExt;
    lpstrFile     := FullFileName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= FileName;
    flags         := ofn_FileMustExist;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FullFileName);
  end;
  if GetOpenFileName(OpenFN) then fileopen := strpas(fullfilename);
  {SndPlaySound(FileName, 1);   {Second parameter must be 1} 
end;

function FileSave(HWindow:hwnd):string;
const
  DefExt = 'sav';
var
  OpenFN      : TOpenFileName;
  Filter      : array [0..100] of Char;
  FullFileName: TFilename;
  WinDir      : array [0..145] of Char;
  filename    : pchar;
begin
  SetCurDir(path);
  StrCopy(FullFileName, '');
  FillChar(Filter, SizeOf(Filter), #0);  { Set up for double null at end }
  StrCopy(Filter, 'Game Files');
  StrCopy(@Filter[StrLen(Filter)+1], '*.sav');
  FillChar(OpenFN, SizeOf(TOpenFileName), #0);
  with OpenFN do
  begin
    hInstance     := HInstance;
    hwndOwner     := HWindow;
    lpstrDefExt   := DefExt;
    lpstrFile     := FullFileName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= FileName;
    flags         := ofn_FileMustExist;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FullFileName);
  end;
  if GetSaveFileName(OpenFN) then filesave := strpas(fullfilename);
  {SndPlaySound(FileName, 1);   {Second parameter must be 1} 
end;

{------------------------------------------------   Fighter Objects}

const fframes = round(5*fps/gamespeed+1);

type tkeys = record
       left,right,up,down,punch,kick:word;
       computer: boolean;
     end;

type pfprops = ^tfprops;
     tfprops = record
       l1x,l1y,l2x,l2y,cx,cy,a1x,a2x,head,size,duck,direction: real;
       x,y: integer;
       jump,walkf,walkb,punch,kick,ducked,dying,alive: boolean;
     end;

type pfdata = ^tfdata;
     tfdata = record
       pos: array [1..fframes] of tfprops;
       keycodes: tkeys;
       color: longint;
       hits,score:real;
       maxhits: integer;
       name,ftype: string;
       lastkill :bool;
     end;

type pgenf = ^tgenf;
     tgenf = object(Tobject)
       data: tfdata;
       steplit: integer;
       closedist:integer;
       closest: pgenf;
       DC: SDC;
       HWindow: Hwnd;
       constructor init(TheDC:SDC; xpos,ypos,
         dir:integer; sze: real; c:longint; mhits: integer;
         lk:bool; nme: string);
       destructor done; virtual;
       procedure draw; virtual;
       procedure subinit; virtual;
       procedure resize; virtual;
       procedure advanceframe; virtual;
       procedure walkr; virtual;
       procedure walkl; virtual;
       procedure walkf; virtual;
       procedure walkb; virtual;
       procedure kick; virtual;
       procedure punch; virtual;
       procedure jump; virtual;
       procedure duck; virtual;
       procedure die; virtual;
       procedure stopduck; virtual;
       procedure setpoints; virtual;
       procedure setkeys1; virtual;
       procedure setkeys2; virtual;
       procedure setcomp; virtual;
       procedure setkeyscust(l,u,r,d,p,k: word);
       procedure setdc(TheDC: SDC); virtual;
       procedure setclose(dist:integer; who:pgenf);
       procedure hit(ouch:real); virtual;
       procedure look(d:real);
     end;

constructor tgenf.init(TheDC:SDC; xpos,ypos,
         dir:integer; sze: real; c:longint; mhits: integer;
         lk:bool; nme: string);
  var x: integer;
  begin
    DC:=TheDC;
    for x := 1 to fframes do
      with data.pos[x] do
        begin
          l1x  := 0.5;
          l1y  :=  -1;
          l2x  := 0.5;
          l2y  :=  -1;
          cx   :=   0;
          cy   :=   0;
          a1x  := 0.5;
          a2x  := 0.5;
          head := 0.5;
          duck := 0.8;
          size := sze;
          x    := xpos;
          y    := ypos;
          direction := dir;
          jump := false;
          walkf:= false;
          walkb:= false;
          punch:= false;
          kick := false;
          ducked := false;
          alive:= true;
          dying := false;
        end;
    data.name  := nme;
    data.maxhits := mhits;
    data.hits  := 0;
    data.score := 0;
    data.color := c;
    data.lastkill := lk;
    closest := nil;
  end;

destructor tgenf.done;
  begin
  end;

procedure tgenf.setdc(TheDC: SDC);
  begin
    DC:=TheDC;
  end;

procedure tgenf.subinit;
  begin
    messagebox(0,'TGENF.SUBINIT has been called','StickFighter Error',0);
  end;

procedure tgenf.setpoints;
  begin
    messagebox(0,'TGENF.SETPOINTS has been called','StickFighter Error',0);
  end;

procedure tgenf.draw;
  begin
    messagebox(0,'TGENF.DRAW has been called','StickFighter Error',0);
  end;

procedure tgenf.resize;
  begin
    messagebox(0,'TGENF.RESIZE has been called','StickFighter Error',0);
  end;

procedure tgenf.advanceframe;
  var i: integer;
  begin
    for i:=1 to fframes do
      with data.pos[i] do
          begin
            if x > 640 then x:=x-640;
            if x < 0 then x:=x+640;
          end;
    for i:=1 to fframes-1 do
      data.pos[i]:=data.pos[i+1]
  end;

procedure tgenf.walkr;
  begin
    if closest = nil then look(1);
    if data.pos[1].direction > 0 then walkf else walkb;
  end;

procedure tgenf.walkl;
  begin
    if closest = nil then look(-1);
    if data.pos[1].direction < 0 then walkf else walkb;
  end;

procedure tgenf.walkb;
  var x: integer;
      ducko,t,pos,f: real;

  begin
    t:=0; pos:=0;
    if data.pos[1].jump then f:=1.5 else f:=1;
    if not data.pos[1].walkf then
    for x:= 1 to fframes do
      with data.pos[x] do
        begin
          t:=t+1/fps*gamespeed;
          if t < 0.3 then
            begin
              walkf:=true;
              if t<=0.15 then l1x:=l1x+t*f;
              if t>0.15 then
                begin
                  l1x:=l1x+(0.3-t)*f;
                  pos:=steplit*t*f;
                end;
            end;
          x:=x-round(pos*direction);
        end;
  end;

procedure tgenf.walkf;
  var x: integer;
      ducko,t,pos,f: real;
  begin
    t:=0; pos:=0;
    if data.pos[1].jump then f:=1.5 else f:=1;
    if not data.pos[1].walkf then
    for x:= 1 to fframes do
      with data.pos[x] do
        begin
          t:=t+1/fps*gamespeed;
          if t < 0.3 then
            begin
              walkf:=true;
              if t<=0.15 then l2x:=l2x+t*f;
              if t>0.15 then
                begin
                  l2x:=l2x+(0.3-t)*f;
                  pos:=steplit*t*f;
                end;
            end;
          x:=x+round(direction*pos);
        end;
  end;

procedure tgenf.die;
  var x: integer;
      t: real;
  begin
    t:=0;
    if (not data.pos[1].dying) and (data.pos[1].alive) then
    for x:= 1 to fframes do
      with data.pos[x] do
        begin
          t:=t+1/fps*gamespeed;
          if t < 1.5 then
            begin
              dying := true;
              alive := true; 
            end;
          if t >= 1.5 then
            begin
              alive := false;
              dying := false;
            end;
        end;
  end;

procedure tgenf.hit(ouch: real);
  begin
  if data.pos[1].ducked then ouch := ouch / 2;
  if data.maxhits <> 0 then data.hits := data.hits + ouch;
  end;

procedure tgenf.kick;
  var x: integer;
      t: real;
      power: real;
  begin
    t:=0;
    power := 1.1;
    if data.pos[1].jump then power := power * 2;
    if not data.pos[1].kick then
    begin
      for x:= 1 to fframes do
        with data.pos[x] do
          begin
            t:=t+1/fps*gamespeed;
            if t < 0.3 then
              begin
                if t<=0.15 then begin l2y:=l2y+t*20; l2x:=l2x+t*3; end;
                if t>0.15 then begin l2y:=l2y+(0.3-t)*20; l2x:=l2x+(0.3-t)*3; end;
                kick:=true;
              end;
          end;
      with data.pos[1] do
        if (abs(closedist) < abs(1.3*size*direction*PinM))
          and (closest <> nil) then begin closest^.hit(power); data.score:=data.score+10; end;
    end;
  end;

procedure tgenf.punch;
  var x: integer;
      t: real;
      power: real;
  begin
    t:=0;
    power := 1;
    if data.pos[1].jump then power := power * 2;
    if not data.pos[1].punch then
      begin
        for x:= 1 to fframes do
          with data.pos[x] do
            begin
              t:=t+1/fps*gamespeed;
              if t < 0.3 then
                begin
                  if t<=0.15 then a2x:=a2x+t*7;
                  if t>0.15 then a2x:=a2x+(0.3-t)*7;
                  punch:=true;
                end;
            end;
        with data.pos[1] do
          if (abs(closedist) < abs(1.2*size*direction*PinM))
            and (closest <> nil) then begin closest^.hit(power); data.score:=data.score+10; end;
      end;
  end;

procedure tgenf.jump;
  var x,s: integer;
      t: real;
  begin
    t:=0; s:=0;
    if not data.pos[1].jump then
    for x:= 1 to fframes do
      with data.pos[x] do
        begin
          t:=t+1/fps*gamespeed;
          if (t<= 0.5) then duck:=duck - 0.2*sin(2*pi/0.5*t);
          if (t>=0.25) then s:=round(PinM*(4*t - 4.9*sqr(t)))
            else s:=0;
          if s>0 then y:=y-round(s);
          if s<0 then jump:=false else jump:=true;
        end;
  end;

procedure tgenf.duck;
  var x: integer;
      t: real;
  begin
    t:=0;
    if not data.pos[1].ducked then
    for x:= 1 to fframes do
      with data.pos[x] do
        begin
          ducked:=true;
          t:=t+1/fps*gamespeed;
          if (t<0.3) then duck:=duck-t else duck:= duck-0.3;
        end;
  end;

procedure tgenf.stopduck;
  var x: integer;
      t: real;
  begin
    t:=0;
    if data.pos[1].ducked then
    for x:= 1 to fframes do
      with data.pos[x] do
        begin
          ducked:=false;
          t:=t+1/fps*gamespeed;
          if (t<0.3) then duck:=duck+t else duck:= duck+0.3;
        end;
  end;

procedure tgenf.setkeys1;
  begin
    with data.keycodes do
      begin
        up    :=  38; {up arrow    }
        down  :=  40; {down arrow  }
        left  :=  37; {left arrow  }
        right :=  39; {right arrow }
        punch :=  16; {shift       }
        kick  :=  17; {control     }
        computer := false;
      end;
  end;

procedure tgenf.setkeys2;
  begin
    with data.keycodes do
      begin
        up    :=  87; {letter 'W'  }
        down  :=  83; {letter 'S'  }
        left  :=  65; {letter 'A'  }
        right :=  68; {letter 'D'  }
        punch :=  74; {letter 'J'  }
        kick  :=  75; {letter 'K'  }
        computer := false;
      end;
  end;

procedure tgenf.setcomp;
  begin
    with data.keycodes do
      begin
        computer := true;
      end;
  end;

procedure tgenf.setkeyscust(l,u,r,d,p,k: word);
  begin
    with data.keycodes do
      begin
        up    :=  l;
        down  :=  d;
        left  :=  l;
        right :=  r;
        punch :=  p;
        kick  :=  k;
        computer := false;
      end;
  end;

procedure tgenf.setclose(dist:integer; who:pgenf);
  begin
    closedist := dist;
    closest   := who;
  end;

procedure tgenf.look(d: real);
  var x: integer;
  begin
    for x := 1 to fframes do
      with data.pos[x] do
        direction := d;
  end;


type stickpos = record
       shape,x1,y1,x2,y2,angle1,angle2,way: word;
       vx1,vy1,vx2,vy2: integer;
       color1,color2,color3: longint;
       lstyle,lthick,fillmode:word;
       plot: bool;
     end;

type pstickman = ^tstickman;
     tstickman = object(tgenf)
       pt: array[0..30] of stickpos;
       defl1,defl2,defa1,defa2,headW,headH,deftorso: integer;
{      K1x,K1y,K2x,K2y,F1x,F1y,F2x,F2y,Ctx,Cty,E1x,E1y,E2x,E2y,H1x,H1y,H2x,H2y,Hdx,Hdy,
       Sx,Sy: integer; }
       nose: real;
       procedure subinit; virtual;
       procedure resize; virtual;
       procedure setpoints; virtual;
       procedure draw; virtual;
     end;

procedure tstickman.draw;
  var x: integer;
  begin
    if data.pos[1].dying then
      begin
        setfont(DC,'Comic Sans MS',30,0,0,0,0,0);
        txt(DC,320,60,3,color[15],data.name+' is dead!!');
      end
    else
    for x:= 0 to 30 do
      with pt[x] do
        if plot then
          begin
            setpen(DC,color1,lstyle,lthick);
             setbrush(DC,color2,color3,fillmode);
             case shape of
            0: qline(DC,x1,y1,x2,y2);
            1: qcircle(DC,x1,y1,x2,y2);
            2: qarc(DC,x1,y1,x2,y2,angle1,angle2,way);
            end;
          end;
  end;
{-----------------------------------------------------------------------------}

procedure tstickman.resize;
  var x: integer;
  begin
    for x:= 1 to fframes do
    with data.pos[x] do
      begin
        defl1     := round(0.5  * PinM  * size);
        defl2     := round(0.4  * PinM  * size); 
        defa1     := round(0.3  * PinM  * size);
        defa2     := round(0.3  * PinM  * size);
        deftorso  := round(0.4  * PinM  * size);
        headw     := round(0.25 * PinM  * size);
        headh     := round(0.25 * PinM  * size);
      end;
  end;

procedure tstickman.subinit;
  var x: integer;
  begin
    resize;
    with data.pos[1] do
      begin
        nose      := 1.4;
        steplit   := defl1+defl2;
      end;
      data.ftype   := 'STICK1';
    for x:= 0 to 30 do
      with pt[x] do
        begin
          plot := false;
          color1 := 0;
          color2 := 0;
          color3 := 0;
          lstyle := 0;
          lthick := 0;
          fillmode := 0;
        end;
  end;

procedure tstickman.setpoints;
  var duckby,ang,a2,a3,t1x,t1y,t2x,t2y: real;
      ctx,cty: integer;
  begin
    subinit;
    with data.pos[1] do
      begin
        duckby := duck*(defl1+defl2);
        cty    := round(y-duckby);
        ctx    := round(x);

{-----------------------------------------------------------------------------}

        with pt[0] do                                 {control}
          begin
            shape := 0; x1 := x; y1 := y; plot := false;
          end;

{-----------------------------------------------------------------------------}

t1x := -l1x*direction*(defl1+defl2);
t1y := l1y*duckby;
ang := atan(t1x,t1y)+pi+direction/abs(direction)*
       acos((sqr(defl2)-sqr(defl1)-(sqr(t1x)+sqr(t1y)))/
      (2*defl1*sqrt(sqr(t1x)+sqr(t1y))));
        
{-----------------------------------------------------------------------------}

        with pt[1] do                         {Leg 1 Knee-Foot}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(x+t1x);            {f1x}
            y1 := round(y-duckby-t1y);               {f1y}
            x2 := round(x+defl1*cos(ang));           {k1x}
            y2 := round(y-duckby-defl1*sin(ang));    {k1y}
          end;
        with pt[2] do                          {Leg 1 Knee-Mid}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;
            y1 := cty;
            x2 := round(x+defl1*cos(ang));           {k1x}
            y2 := round(y-duckby-defl1*sin(ang));    {k1y}
          end;

{-----------------------------------------------------------------------------}

t2x := l2x*direction*(defl1+defl2);
t2y := l2y*duckby;
ang := atan(t2x,t2y)+pi-t2x/abs(t2x)*
       acos((sqr(defl2)-sqr(defl1)-(sqr(t2x)+sqr(t2y)))/
       (2*defl1*sqrt(sqr(t2x)+sqr(t2y))))
          ;
{-----------------------------------------------------------------------------}
        with pt[3] do                         {Leg 2 Knee-Foot}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(x+t2x);            {f2x}
            y1 := round(y-duckby-t2y);               {f2y}
            x2 := round(ctx+defl1*cos(ang));         {k2x}
            y2 := round(y-duckby-defl1*sin(ang));    {k2y}
          end;
        with pt[4] do                           {Leg2 Knee-Mid}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;
            y1 := cty;
            x2 := round(ctx+defl1*cos(ang));         {k2x}
            y2 := round(y-duckby-defl1*sin(ang));    {k2y}
          end;
        with pt[5] do                                  {Mid-Sh}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;
            y1 := cty;
            x2 := ctx;                               {Sx}
            y2 := cty-deftorso;                      {Sy}
          end;

{-----------------------------------------------------------------------------}

t1x := direction*a1x*(defa1+defa2);
t2x := direction*a2x*(defa1+defa2);
t1y := 0;
t2y := 0;
ang := -acos((sqr(defa2)-sqr(defa1)-(sqr(t1x)+sqr(t1y)))/(2*defa1*sqrt(sqr(t1x)+sqr(t1y))));

{-----------------------------------------------------------------------------}

        with pt[6] do                                  {Sh-El1}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx+direction*defa1*cos(ang)); {e1x}
            y1 := round(cty-deftorso-defa1*sin(ang));  {e1y}
            x2 := ctx;                                 {Sx}
            y2 := cty-deftorso;                        {Sy}
          end;
        with pt[7] do                                  {El1-H1}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx+direction*defa1*cos(ang)); {e1x}
            y1 := round(cty-deftorso-defa1*sin(ang));  {e1y}
            x2 := round(x-t1x);                        {H1x}
            y2 := cty-deftorso;                        {H1y}
          end;

{-----------------------------------------------------------------------------}

ang := -acos((sqr(defa2)-sqr(defa1)-(sqr(t2x)+sqr(t2y)))/(2*defa1*sqrt(sqr(t2x)+sqr(t2y))));

{-----------------------------------------------------------------------------}

        with pt[8] do                                  {Sh-El2}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx-direction*defa1*cos(ang));  {e2x}
            y1 := round(cty-deftorso-defa1*sin(ang));   {e2y}
            x2 := ctx;                               {Sx}
            y2 := cty-deftorso;                      {Sy}
          end;
        with pt[9] do                                  {El2-H2}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx-direction*defa1*cos(ang));  {e2x}
            y1 := round(cty-deftorso-defa1*sin(ang));   {e2y}
            x2 := round(x+t2x);                         {H2x}
            y2 := cty-deftorso;                         {H2y}
          end;

t1x := x;                                    {Hdx}
t1y := cty-deftorso-head*PinM*size/2;        {Hdy}

{-----------------------------------------------------------------------------}

        with pt[10] do                                 {Sh-Head}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;                                   {Sx}
            y1 := cty-deftorso;                          {Sy}
            x2 := round(t1x);                            {Hdx}
            y2 := round(t1y);                            {Hdy}
          end;

        with pt[11] do                                 {Head}
          begin
            shape:=1; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            color2:=0;
            x1 := round(t1x);                            {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := round(direction*headw);
            y2 := round(headh);
          end;
        with pt[12] do                                 {NoseTop}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(t1x+direction*headw*nose);       {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := round(t1x+direction*headw*cos(20/180*pi));
            y2 := round(t1y-headh*sin(20/180*pi));
          end;
        with pt[13] do                                 {NoseBot}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(t1x+direction*headw*nose);       {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := round(t1x+direction*headw*cos(20/180*pi));
            y2 := round(t1y);
          end;
        with pt[14] do                                 {Smiley}
          begin
            shape:=2; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(t1x+direction*headw);            {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := abs(round(direction*headw));
            y2 := abs(round(headh*2/3));
            way:=0;
            if direction > 0 then angle1:=200 else angle1:=285;
            if direction > 0 then angle2:=255 else angle2:=360;
          end;
        with pt[16] do                                 {Smiley}
          begin
            shape:=1; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            color2:=-1;
            x1 := round(t1x+direction*headw/2);           {EyeX}
            y1 := round(t1y-headh/2);           {EyeY}
            x2 := abs(round(direction*headw/3.9));
            y2 := abs(round(headh/3.9));
            way:=0;
            angle1:=180;
            angle2:=260;
          end;
        with pt[15] do                                 {Smiley}
          begin
            shape:=1; color1:=data.color; lstyle:=0; lthick:=2; plot := true;
            color2:=data.color;
            x1 := round(t1x+direction*headw/2+direction*headw/10);           {EyeX}
            y1 := round(t1y-headh/2);           {EyeY}
            x2 := abs(round(direction*headw/7));
            y2 := abs(round(headh/7));
            way:=0;
            angle1:=180;
            angle2:=260;
          end;

{ qarc(DC,x1,y1,x2,y2,angle1,angle2,way); }

{-----------------------------------------------------------------------------}
{    qline(DC,HDx+round(direction*headw*nose),HDy,
          HDx+round(direction*headw),HDy);
    

    qarc(DC,HDx+round(direction*headw*0.75),HDy-round(headh*0.3),
           25,20,160,190,2);


    qarc(DC,HDX+round(direction*headw),HDy,
            round(direction*headw*1),10,190,260,0);
     }




      end;
  end;

type pfpool = ^tfpool;
     tfpool = object(tcollection)
       alive: bool;
       constructor Init(ALimit, ADelta: Integer);
       destructor done; virtual;
       procedure Error(Code, Info: Integer); virtual;
     end;

constructor tfpool.Init(ALimit, ADelta: Integer);
  begin
    tcollection.Init(ALimit, ADelta);
    alive:=true;
  end;

destructor tfpool.done;
  var x: integer;
      f: pgenf; 
  begin
    alive := false;
    count := 0;
    for x := 0 to count-1 do
      begin
        f := at(x);
        dispose(f,done)
      end;
    tcollection.done;
  end;

procedure tfpool.Error(Code, Info: Integer);
  begin
  end;



type tscoredata = record
       name: string;
       score: longint;
       alive: bool;
     end;

type tscores = object
       data: array[1..10] of tscoredata;
       procedure add(who:string; what: longint);
       procedure sort;
       procedure save(filename: string);
       procedure load(filename: string);
       procedure clr;
     end;

procedure tscores.add(who:string; what: longint);
  var i: integer;
      beenthere: bool;
  begin
    beenthere := false;
    sort;
   for i := 1 to 10 do
      begin
        beenthere := beenthere or (data[i].name=who);
        if data[i].name = who then
           if data[i].score < what then data[i].score := what;
      end;
    if not beenthere then
      begin
        sort;
        if (what > data[10].score) or not data[10].alive then
        begin
          data[10].name  := who;
          data[10].score := what;
          data[10].alive := true;
        end;
      end;
    sort;
  end;

procedure tscores.sort;
  var i,j,k: integer;
      swap: tscoredata;
  begin
    for i := 1 to 9 do
      for j := i to 10 do
        begin
          if (data[i].score < data[j].score) or not data[i].alive then
            begin
              swap    := data[i];
              data[i] := data[j];
              data[j] := swap;
            end;
        end;
  end;

procedure tscores.save(filename: string);
  var f: file of tscoredata;
      i: integer;
  begin
    assign(f,filename);
    rewrite(f);
    for i := 1 to 10 do
      write(f,data[i]); 
    close(f);
  end;

procedure tscores.load(filename: string);
  var f: file of tscoredata;
      i: integer;
  begin
    assign(f,filename);
    reset(f);
    for i := 1 to 10 do
      read(f,data[i]); 
    close(f);
  end;

procedure tscores.clr;
  var i: integer;
  begin
    for i:= 1 to 10 do
      with data[i] do
        begin
          alive := false;
          score := 0;
          name  := '';
        end;
  end;




type pwind = ^twind;
     twind = object(twindow)
       winddc,usedc,MemDC: SDC;
       mode: string;
       first, paused: boolean;
       fpool: pfpool;
       pressesc: bool;
       pressany: bool;
       fighting: bool;
       curfighter: pgenf;
       blank: BMP;
       selected,activated: integer;
       vlast: word;
       keycount: integer;
       keybuffer: array[0..63] of char;
       scores: tscores;
       constructor init(AParent: PWindowsObject; ATitle: PChar);
       procedure  wmchar(var Msg: TMessage);  virtual wm_First + wm_char;
       procedure WMLButtonDown(var Msg: TMessage);  virtual wm_First + wm_LButtonDown;
       procedure WMRButtonDown(var Msg: TMessage);  virtual wm_First + wm_RButtonDown;
       procedure WMLButtonUp(var Msg: TMessage);  virtual wm_First + wm_LButtonUp;
       procedure WMRButtonUp(var Msg: TMessage);  virtual wm_First + wm_RButtonUp;
       procedure WMKeyDown(var Msg:Tmessage); virtual wm_First + wm_Keydown;
       procedure WMKeyUp(var Msg:Tmessage); virtual wm_First + wm_KeyUp;
       procedure WMPaint(var Msg: Tmessage);        virtual wm_First + wm_Paint;
       procedure WMMouseMove(var Msg: Tmessage); virtual wm_First + wm_MouseMove;
       procedure GetWindowClass( var WC: TWndClass); virtual;
       procedure wmsetfocus(var Msg: Tmessage); virtual wm_First + wm_setfocus;
       procedure wmkillfocus(var Msg: Tmessage); virtual wm_First + wm_killfocus;
       procedure givedc(TheDC: SDC); virtual;
       function readkey: char; 
       destructor Done; virtual;
     end;

function twind.ReadKey: Char;
begin
  if KeyCount > 0 then
    begin
      ReadKey := KeyBuffer[0];
      Dec(KeyCount);
      Move(KeyBuffer[1], KeyBuffer[0], KeyCount);
    end
  else readkey:=chr(0);
end;

procedure twind.wmchar(var Msg: TMessage);  
  var ch: char;
  begin
    defwndproc(msg);
    ch:=Char(msg.wparam);
    if KeyCount < SizeOf(KeyBuffer) then
      begin
        KeyBuffer[KeyCount] := Ch;
        Inc(KeyCount);
      end;
    end;

constructor twind.Init(AParent: PWindowsObject; ATitle: PChar);
  var wc: twndclass;
      sw,sh: integer;
  begin
    twindow.init(AParent,ATitle);
    with attr do
      begin
        style:= WS_POPUPwindow;
        exstyle:=exstyle or $00000008;
        sw:=GetSystemMetrics(SM_CXSCREEN);
        sh:=GetSystemMetrics(SM_CySCREEN);
        x:=(sw-640) div 2;                                   
        y:=(sh-480) div 2;
        w:=640;
        h:=480;
        first:=TRUE;
        MemDC:=makeDC(0,1);
        blank := loadbmp(path+'\blank.bmp'); 
        setbmp(memdc,blank);
        fpool:=new(pfpool,init(1,1));
        fighting:=false;
        keycount:=0;
        scores.load(path+'\scores.dat');
        if resetscores then scores.clr;
      end;
  end;

destructor twind.done;
  begin
    scores.save(path+'\scores.dat');
    releasecapture;
    dispose(fpool,done);
    killDC(winddc);
    killDC(memDC);
    twindow.done;
  end;

procedure twind.wmsetfocus(var Msg: Tmessage);
  begin
    defwndproc(msg);
    pressany:=false;
    WindDC:=makeDC(HWindow,0);
    GiveDC(MemDC);
    paused:=false;
    setbrush(WindDC,color[0],color[0],0);
    setpen(WindDC,color[0],0,2);
    box(WindDC,0,0,640,480,0,0);
  end;

procedure twind.wmkillfocus(var Msg: Tmessage);
  var t: tmessage;
  begin
    paused:=true;
    wmpaint(t);
    killDC(WindDC);
    defwndproc(msg);
  end;

procedure twind.wmpaint(var msg: tmessage);

  procedure intro;
    var f:pstickman;
        fin: integer;
        timer: longint;
        i,j,k,l: integer;
        title: bmp;
     begin
       randomize;
       fin:=0;
       mode:='intro';
       f:=new(pstickman,init(usedc,320,300,1,1.5,color[9],0,True,'Russ'));
       f^.setpoints;
       for i:=0 to 30 do
         begin
           f^.pt[i].vx1:=random(23)-11;
           f^.pt[i].vy1:=random(23)-11;
           f^.pt[i].vx2:=random(23)-11;
           f^.pt[i].vy2:=random(23)-11;
         end;
       f^.pt[15].vy2:=0;
       f^.pt[15].vx2:=0;
       for i:=0 to 30 do
         with f^.pt[i] do
           begin
             for j:= 0 to 150 do
               begin
                 x1 := x1 + vx1;
                 y1 := y1 + vy1;
                 x2 := x2 + vx2;
                 y2 := y2 + vy2;
                 if (x1 < 0) or (x1 > 640) then vx1:=vx1*-1;
                 if (x2 < 0) or (x2 > 640) then vx2:=vx2*-1;
                 if (y1 < 0) or (y1 > 480) then vy1:=vy1*-1;
                 if (y2 < 0) or (y2 > 480) then vy2:=vy2*-1;
               end;
               vx1:=vx1*-1; vy1:=vy1*-1; vx2:=vx2*-1; vy2:=vy2*-1;
           end;
       for j:=0 to 150 do
         begin
           for i:=0 to 30 do
           with f^.pt[i] do
           begin
             startdelay(timer);
             x1 := x1 + vx1;
             y1 := y1 + vy1;
             x2 := x2 + vx2;
             y2 := y2 + vy2;
             if (x1 < 0) or (x1 > 640) then vx1:=vx1*-1;
             if (x2 < 0) or (x2 > 640) then vx2:=vx2*-1;
             if (y1 < 0) or (y1 > 480) then vy1:=vy1*-1;
             if (y2 < 0) or (y2 > 480) then vy2:=vy2*-1;
           end;
           setpen(UseDC,0,0,0); setbrush(usedc,0,0,0); box(usedc,0,0,640,480,0,0);
           f^.draw;
           if (not paused) and (UseDC=MemDC) then
             bitblt(WindDC^.handle,0,0,640,480,MemDC^.handle,0,0,Srccopy);
           unfreeze(hwindow);
           finishdelay(1000 div fps,timer, Hwindow);
           repeat unfreeze(HWindow); until not paused;
           if pressany then j:=150;
         end;
       pressany:=false;
       setpen(UseDC,0,0,0); setbrush(usedc,0,0,0); box(usedc,0,0,640,480,0,0);
       f^.setpoints;
       f^.draw;
       title:=loadbmp(path+'\stick.bmp');
       drawbmp(memdc,32,320,title,0,0,0);
       deletebmp(title);

       if (not paused) and (UseDC=MemDC) then
         bitblt(WindDC^.handle,0,0,640,480,MemDC^.handle,0,0,Srccopy);

       repeat
         startdelay(timer);
         setpen(UseDC,0,0,0); setbrush(usedc,0,0,0); box(usedc,0,0,640,310,0,0);
         i:=random(6);
         j:=j+1;
         j:=j mod 17;
         if j=0 then 
         case i of
         0: f^.walkl;
         1: f^.walkr;
         2: f^.jump;
         3: begin f^.duck; f^.stopduck; end;
         4: f^.kick;
         5: f^.punch;
         end;
         f^.setpoints;
         f^.draw;
         f^.advanceframe;
         if (not paused) and (UseDC=MemDC) then
           bitblt(WindDC^.handle,0,0,640,480,MemDC^.handle,0,0,Srccopy);
         unfreeze(Hwindow);
         finishdelay(1000 div fps,timer, Hwindow);
         repeat unfreeze(HWindow) until not paused;
       until pressany;
       dispose(f,done);
    end;

   procedure fight; forward;
   procedure players; forward;

   procedure newg;
     var i,j: integer;
         f: pgenf;
     begin
       mode:='newg';
       setpen(WindDC,color[0],0,0);
       setbrush(WindDC,0,0,0);
       box(WindDC,0,0,640,480,0,0);
       i := getlng(UseDC,mode);
       setpen(WindDC,color[9],0,2);
       qline(WindDC,320-i div 2,110,320+i div 2,110);

       dispose(fpool,done);
       fpool:=new(pfpool,init(1,1));

       fpool^.insert(new(pstickman,init(usedc,200,350,1,1,color[12],50,True,
         'Computer')));
       curfighter:=fpool^.at(fpool^.count-1);
       curfighter^.setcomp;

       fpool^.insert(new(pstickman,init(usedc,200,350,1,1,color[9],50,True,
         'Bob')));
       curfighter:=fpool^.at(fpool^.count-1);
       curfighter^.setkeys1;

       fpool^.insert(new(pstickman,init(usedc,200,350,1,1,color[10],50,True,
         'Bob 2')));
       curfighter:=fpool^.at(fpool^.count-1);
       curfighter^.setkeys1;

       fpool^.insert(new(pstickman,init(usedc,200,350,1,1,color[0],0,True,
         'Death')));
       curfighter:=fpool^.at(fpool^.count-1);
       curfighter^.setcomp;



       players;

       for i := 0 to fpool^.count-1 do
         begin
           f := fpool^.at(i);
           for j := 1 to fframes do
             with f^.data.pos[j] do
               x:=round(640*(i+1)/(fpool^.count+1));
         end;
              setpen(WindDC,color[0],0,0);
       setbrush(WindDC,0,0,0);
       box(WindDC,0,0,640,480,0,0);
       fight;
     end;

   procedure loadg;
     var i,j: integer;
         f: pgenf;
         q: file of tfdata;
         name:string; 
     begin
       name:=fileopen(Hwindow);
       if name <> '' then
         begin
           assign(q,name);
           reset(q);
           dispose(fpool,done);
           fpool:=new(pfpool,init(1,1));
           while not eof(q) do
             begin
               fpool^.insert(new(pstickman,init(usedc,200,350,1,1,color[12],50,false,'O')));
               f:=fpool^.at(fpool^.count-1);
               read(Q,f^.data);
             end; 
           close(q);
           fighting := true;
         end;
     end;

   procedure saveg;
     var i: integer;
         f: pgenf;
         q: file of tfdata;
         name:string;
     begin
       name:=filesave(Hwindow);
       if name <> '' then
         begin
           assign(q,name);
           rewrite(q);
           for i := 0 to fpool^.count-1 do
             begin
               f := fpool^.at(i);
               write(q,f^.data);
             end;
           close(q);
         end;
     end;

   procedure modify(who: integer);
     var i,j,k,l: integer;
         temp: string;
         fin,click: integer;
         timer,cl:longint;
         menuoption: array[1..4] of string;
         del,md,blink: bool;
         kname:pchar;
         a: char;
         realhits,t1: real;

     begin
       del:=false; md:= false;
       mode:='mod';
       pressany:=false;
       pressesc:=false;
       fin := 0;
       selected := 1;
       activated :=0;
       curfighter:=fpool^.at(who);
       new(kname);
       keycount:=0;
       realhits:=curfighter^.data.maxhits;
       vlast:=0;
       repeat
         startdelay(timer);

         setpen(UseDC,0,0,0); setbrush(UseDC,0,0,0); box(UseDC,0,0,640,480,0,0);

         setfont(UseDC,'Comic Sans MS',40,5,0,0,0,0); txt(UseDC,320,15,3,color[15],'Modify Player');

         setfont(UseDC,'Comic Sans MS',20,0,0,0,0,0);
         txt(UseDC,30,80,1,color[15],'Name:');
         txt(UseDC,130,80,1,color[15],curfighter^.data.name);

         if click=1 then
           begin
             setpen(UseDC,color[14],0,0);
             setbrush(UseDC,-1,-1,0);
             box(UseDC,25,80,125,110,0,0);
             i := ord(readkey);
             with curfighter^.data do
             if (i=32) or ((i>=65) and (i<=90)) or ((i>=97) and (i<=122)) or ((i>=48) and (i<=57)) then
               name:=name+chr(i);
             with curfighter^.data do
             if (i=8) and (length(name)>0) then name := copy(name,1,length(name)-1);
           end;

         if (click>=2) and (click<=17) then
           begin
             setpen(UseDC,color[14],0,0);
             setbrush(UseDC,-1,-1,0);
             box(UseDC,25,120,125,150,0,0);
             curfighter^.data.color:=color[click-2];
           end;

         txt(UseDC,30,120,1,color[15],'Color:');

         for i:=0 to 15 do
           begin
             if color[i]=curfighter^.data.color then
               setpen(UseDC,color[14],0,0)
             else
               setpen(UseDC,color[0],0,0);
             setbrush(UseDC,color[i],-1,0);
             box(UseDC,130+24*i,125,150+24*i,145,0,0);
           end;

         txt(UseDC,30,160,1,color[15],'Strength:');
         str(realhits*2:0:0,temp);
         txt(UseDC,130,160,1,color[15],temp+'%');
         if click=18 then
           begin
             setpen(UseDC,color[14],0,0); setbrush(UseDC,-1,-1,0); box(UseDC,25,160,125,190,0,0);
             i := ord(readkey);
             with curfighter^.data do
             if ((i>=48) and (i<=57)) then
               temp:=temp+chr(i);
             with curfighter^.data do
             if (i=8) and (length(temp)>0) then temp := copy(temp,1,length(temp)-1);
             val(temp,t1,i);
             realhits:=t1/2;
           end;
         if click=19 then
           begin
             curfighter^.data.lastkill:=not curfighter^.data.lastkill;
             activated:=0; click:=0;
           end;
         setfont(UseDC,'Comic Sans MS',15,0,0,0,0,0);
         txt(UseDC,50,210,1,color[15],'End Fight if last remaining player');
         setpen(UseDC,color[9],0,4);
         if curfighter^.data.lastkill then
           setbrush(UseDC,color[12],0,0)
         else
           setbrush(UseDC,0,0,0);
         qcircle(UseDC,35,220,10,6);

         setfont(UseDC,'Comic Sans MS',20,0,0,0,0,0);
         txt(UseDC,30,260,1,color[15],'Keys:');
         setfont(UseDC,'Comic Sans MS',15,0,0,0,0,0);

         txt(UseDC,100,265,1,color[15],'Default Keys 1');
         txt(UseDC,230,265,1,color[15],'Default Keys 2');
         setbrush(UseDC,-1,-1,0);
         if click=20 then
           begin
             click:=0; activated:=0;
             setpen(UseDC,color[14],0,0);  box(UseDC,95,260,205,290,0,0);
             curfighter^.setkeys1;
           end;
         if click=21 then
           begin
             click:=0; activated:=0;
             setpen(UseDC,color[14],0,0);  box(UseDC,225,260,340,290,0,0);
             curfighter^.setkeys2;
           end;
         if click=22 then
           begin
             click:=0; activated:=0;
             curfighter^.data.keycodes.computer:=false;
           end;
         if click=23 then
           begin
             click:=0; activated:=0;
             curfighter^.setcomp;
           end;

         setpen(UseDC,color[14],0,0);
         if curfighter^.data.keycodes.computer then
           box(UseDC,450,260,603,290,0,0)
         else
           begin
             box(UseDC,360,260,420,290,0,0);

             setfont(UseDC,'Comic Sans MS',15,7,0,0,0,0);
             txt(UseDC,30,305,1,color[15],'Key Values:');
             setfont(UseDC,'Comic Sans MS',15,0,0,0,0,0);

             txt(UseDC,95+1*(640-95) div 7,305,3,color[15],'Up');
             txt(UseDC,95+2*(640-95) div 7,305,3,color[15],'Down');
             txt(UseDC,95+3*(640-95) div 7,305,3,color[15],'Left');
             txt(UseDC,95+4*(640-95) div 7,305,3,color[15],'Right');
             txt(UseDC,95+5*(640-95) div 7,305,3,color[15],'Kick');
             txt(UseDC,95+6*(640-95) div 7,305,3,color[15],'Punch');

             GetKeyNameText(makelong(0,curfighter^.data.keycodes.up),kname,20);
             txt(UseDC,95+1*(640-95) div 7,345,3,color[15],strpas(kname));
             str(curfighter^.data.keycodes.up,temp);
             txt(UseDC,95+1*(640-95) div 7,325,3,color[15],temp);

             GetKeyNameText(makelong(0,curfighter^.data.keycodes.down),kname,20);
             txt(UseDC,95+2*(640-95) div 7,345,3,color[15],strpas(kname));
             str(curfighter^.data.keycodes.down,temp);
             txt(UseDC,95+2*(640-95) div 7,325,3,color[15],temp);

             GetKeyNameText(makelong(0,curfighter^.data.keycodes.left),kname,20);
             txt(UseDC,95+3*(640-95) div 7,345,3,color[15],strpas(kname));
             str(curfighter^.data.keycodes.left,temp);
             txt(UseDC,95+3*(640-95) div 7,325,3,color[15],temp);

             GetKeyNameText(makelong(0,curfighter^.data.keycodes.right),kname,20);
             txt(UseDC,95+4*(640-95) div 7,345,3,color[15],strpas(kname));
             str(curfighter^.data.keycodes.right,temp);
             txt(UseDC,95+4*(640-95) div 7,325,3,color[15],temp);

             GetKeyNameText(makelong(0,curfighter^.data.keycodes.kick),kname,20);
             txt(UseDC,95+5*(640-95) div 7,345,3,color[15],strpas(kname));
             str(curfighter^.data.keycodes.kick,temp);
             txt(UseDC,95+5*(640-95) div 7,325,3,color[15],temp);

             GetKeyNameText(makelong(0,curfighter^.data.keycodes.punch),kname,20);
             txt(UseDC,95+6*(640-95) div 7,345,3,color[15],strpas(kname));
             str(curfighter^.data.keycodes.punch,temp);
             txt(UseDC,95+6*(640-95) div 7,325,3,color[15],temp);

             if vlast<>0 then
               begin
                 if click=24 then curfighter^.data.keycodes.up    :=vlast;
                 if click=25 then curfighter^.data.keycodes.down  :=vlast;
                 if click=26 then curfighter^.data.keycodes.left  :=vlast;
                 if click=27 then curfighter^.data.keycodes.right :=vlast;
                 if click=28 then curfighter^.data.keycodes.kick  :=vlast;
                 if click=29 then curfighter^.data.keycodes.punch :=vlast;
                 vlast:=0;
               end;

             j:=95+(click-23)*(640-95) div 7;
             setpen(UseDC,color[14],2,0);

             box(usedc,j-30,303,j+30,368,0,0);
          end;

             txt(UseDC,365,265,1,color[15],'Custom');
             txt(UseDC,455,265,1,color[15],'Computer Controlled');

             setfont(UseDC,'Comic Sans MS',20,9,0,0,0,0);
             txt(UseDC,600,400,2,color[15],'Done');

         if (not paused) and (UseDC=MemDC) then
           bitblt(WindDC^.handle,0,0,640,480,MemDC^.handle,0,0,Srccopy);
         finishdelay(1000 div fps,timer, Hwindow);
         click := activated;
         if (pressesc) or (click=30) then fin:=1;
         if fpool=nil then fin:=1 else
         if not fpool^.alive then fin:=1;
       until fin=1;
       curfighter^.data.maxhits:=round(realhits);
       dispose(kname);
     end;

   procedure players;
     var i,j,k,l: integer;
         temp: string;
         fin,click: integer;
         timer,cl:longint;
         menuoption: array[1..4] of string;
         del,md,blink: bool;
     begin
       del:=false; md:= false;
       mode:='players';
       pressany:=false;
       fin := 0;
       selected := 1;
       activated :=-1;
       menuoption[1] := 'Add New Player';
       menuoption[2] := 'Modify Player';
       menuoption[3] := 'Delete Player';
       menuoption[4] := 'Done';

       repeat 
         startdelay(timer);

         setpen(UseDC,0,0,0); setbrush(UseDC,0,0,0); box(UseDC,0,0,640,480,0,0);

         if (click=10) and (fpool^.count<10) then
           begin
             fpool^.insert(new(pstickman,init(usedc,200,350,1,1,color[0],50,True,
               'New Player - Click Below to Modify')));
             curfighter:=fpool^.at(fpool^.count-1);
             curfighter^.setcomp;
           end;

         if click=11 then
           begin
             del := false;
             md  := not md;
           end;
         if click=12 then
           begin
             md  := false;
             del := not del;
           end;
         if del and (click>=0) and (click<=9) then
           begin
             curfighter:=fpool^.at(click);
             curfighter^.done;
             fpool^.atdelete(click);
             del := false;
           end;

         if md and (click>=0) and (click<=9) then
           begin
             modify(click);
             vlast:=0;
             click:=-1;
             md:=false;
             mode:='players';
           end;

         if click=13 then fin:=1;

         setfont(UseDC,'Comic Sans MS',40,5,0,0,0,0);
         txt(UseDC,320,30,3,color[15],'Choose a Player');
         setfont(UseDC,'Comic Sans MS',20,0,1,0,0,0);
         txt(UseDC,20,90,1,color[15],'#');
         txt(UseDC,50,90,1,color[15],'Name');
         txt(UseDC,390,90,1,color[15],'Color');
         txt(UseDC,460,90,1,color[15],'Type');
         txt(UseDC,560,90,1,color[15],'Score');
         setpen(UseDC,rgb(255,0,0),0,0);
         qline(UseDC,20,115,620,115);
         qline(UseDC,20,130+10*20,620,130+10*20);
         setfont(UseDC,'Comic Sans MS',18,0,0,0,0,0);
         for i:= 0 to fpool^.count-1 do
           begin
             if i=selected then
               begin
                 if del or md then
                   begin
                     blink := not blink;
                     if blink then cl:=color[15] else cl:=rgb(255,0,0);
                   end
                 else
                   begin
                     cl:=color[15];
                   end;
               end
             else
               cl:=color[7];
             curfighter:=fpool^.at(i);
             str(i,temp);
             txt(UseDC,20,120+20*i,1,cl,temp);
             txt(UseDC,50,120+20*i,1,cl,curfighter^.data.name);
             setpen(UseDC,color[14],0,0);
             setbrush(UseDC,curfighter^.data.color,0,0);
             box(UseDC,390,120+20*i,410,138+20*i,0,0);
             if curfighter^.data.keycodes.computer then temp:='Computer'
               else temp:='Human';
             txt(UseDC,460,120+20*i,1,cl,temp);
             str(curfighter^.data.score:0:0,temp);
             txt(UseDC,560,120+20*i,1,cl,temp);
           end;

         for i := 1 to 4 do
           begin
             if i+9=selected then cl:=color[15] else cl:=color[7];
             if ((i+9=11) and md) or ((i+9=12) and del) then cl:=rgb(255,0,0);
             txt(UseDC,320,340+i*20,3,cl,menuoption[i]);
           end;

         if (not paused) and (UseDC=MemDC) then
           bitblt(WindDC^.handle,0,0,640,480,MemDC^.handle,0,0,Srccopy);
         finishdelay(1000 div fps,timer, Hwindow);
         click := activated; activated:=-1; 

         if vlast=38 then selected:=selected-1;
         if vlast=40 then selected:=selected+1;
         if vlast=13 then click:=selected;
         vlast:=0;

       until fin=1;
     end;

   procedure highs;
     var i,j,k: integer;
         mx: longint;
         temp: string;
         f: pgenf;
     begin
       mx:=0;
       mode:='highs';
       setpen(WindDC,color[0],0,0);
       setbrush(WindDC,0,0,0);
       box(WindDC,0,0,640,480,0,0);
       setfont(WindDC,'Comic Sans MS',40,5,0,0,0,0);
       txt(WindDC,320,30,3,color[15],'High Scores');
       setpen(WindDC,color[9],0,2);
       pressany:=false;
       scores.sort;
       mx:=scores.data[1].score + 1;
       for i := 1 to 10 do
         with scores.data[i] do
           if alive then  
             begin
               for j := 20 to round(530*score/mx)+20 do
                 begin
                  { gradient( }
                   setpen(WindDC,gradient(rgb(226,45,0),rgb(251,195,67),j,621),0,1);
                   qline(WindDC,j,75+i*35,j,95+i*35)
                 end;
               setfont(WindDC,'Comic Sans MS',20,0,0,0,0,0);
               txt(WindDC,30,69+i*35,1,color[15],name);
               str(score,temp);
               txt(WindDC,610,69+i*35,2,color[15],temp);
              end;  
       repeat
         unfreeze(hwindow);
       until pressany;
     end;

   procedure about;
     var i: integer;
     begin
       mode:='about';
       setpen(WindDC,color[0],0,0);
       setbrush(WindDC,0,0,0);
       box(WindDC,0,0,640,480,0,0);
       setfont(WindDC,'Comic Sans MS',40,5,0,0,0,0);
       txt(WindDC,320,30,3,color[15],'About The Game');
       i := getlng(UseDC,'About The Game');
       setpen(WindDC,color[9],0,2);
       qline(WindDC,320-i div 2,80,320+i div 2,80);

       pressany:=false;
       repeat
         unfreeze(hwindow);
       until pressany;
     end;

   procedure menu;
    var f:pstickman;
        fin: integer;
        timer: longint;
        i,j,k,l: integer;
        title: bmp;
        menuitem: array[1..7] of string;
     begin
       selected := 2;
       activated :=0;
       vlast:=0;
       menuitem[1] := 'New Game';
       menuitem[2] := 'Load Game';
       menuitem[3] := 'Save Game';
       menuitem[4] := 'Players';
       menuitem[5] := 'High Scores';
       menuitem[6] := 'About the Game';
       menuitem[7] := 'Exit';
       fin:=0;
       mode:='menu';
       f:=new(pstickman,init(usedc,320,300,1,1.5,color[9],0,True,'Russ'));
       f^.setpoints;
       for i:=0 to 30 do
         begin
           f^.pt[i].vx1:=random(23)-11;
           f^.pt[i].vy1:=random(23)-11;
           f^.pt[i].vx2:=random(23)-11;
           f^.pt[i].vy2:=random(23)-11;
         end;
       f^.pt[15].vy2:=0;
       f^.pt[15].vx2:=0;
       pressany:=false;
       repeat
         startdelay(timer);
         for i:=0 to 30 do
           with f^.pt[i] do
           begin
             x1 := x1 + vx1;
             y1 := y1 + vy1;
             x2 := x2 + vx2;
             y2 := y2 + vy2;
             if (x1 < 0) or (x1 > 640) then vx1:=vx1*-1;
             if (x2 < 0) or (x2 > 640) then vx2:=vx2*-1;
             if (y1 < 0) or (y1 > 480) then vy1:=vy1*-1;
             if (y2 < 0) or (y2 > 480) then vy2:=vy2*-1;
           end;
         setpen(UseDC,0,0,0); setbrush(usedc,0,0,0); box(usedc,0,0,640,480,0,0);
         f^.draw;                     
         setpen(UseDC,color[7],0,0); setbrush(usedc,0,0,0); box(usedc,150,50,490,430,0,0);
         setfont(UseDC,'Comic Sans MS',40,5,0,0,0,0);
         txt(UseDC,320,60,3,color[15],'Main Menu');
         i := getlng(UseDC,'Main Menu');
         setpen(UseDC,color[9],0,2);
         qline(UseDC,320-i div 2,110,320+i div 2,110);
         if vlast=38 then selected:=selected-1;
         if vlast=40 then selected:=selected+1;
         if vlast=13 then activated:=selected;
         if (vlast=27) and fighting then begin fight; mode:='menu'; end;
         vlast:=0;
         if selected<1 then selected:=7;
         if selected>7 then selected:=1;
         for i:= 1 to 7 do
           begin
             if (i<>selected) and (i<>activated) then
               begin
                 setfont(UseDC,'Comic Sans MS',30,0,0,0,0,0);
                 txt(UseDC,320,80+i*40,3,color[7],menuitem[i]);
               end;
             if (i=selected) and (i<>activated) then
               begin
                 setfont(UseDC,'Comic Sans MS',34,0,0,0,0,0);
                 txt(UseDC,320,80+i*40-4,3,color[15],menuitem[i]);
               end;
             if (i=activated) then
               begin
                 setfont(UseDC,'Comic Sans MS',34,0,0,0,0,0);
                 txt(UseDC,320,80+i*40-4,3,rgb(255,0,0),menuitem[i]);
               end;
           end;
         case activated of
         1: begin newg; mode:='menu'; activated:=0; vlast:=0; end;
         2: begin loadg; mode:='menu'; activated:=0; vlast:=0; end;
         3: begin saveg; mode:='menu'; activated:=0; vlast:=0; end;
         4: begin players; mode:='menu'; activated:=0; vlast:=0; end;
         5: begin highs; mode:='menu'; activated:=0; vlast:=0; end;
         6: begin about; mode:='menu'; activated:=0; vlast:=0; end;
         7: begin fin:=1 end;
         else activated:=0;
         end;

         if (not paused) and (UseDC=MemDC) then
           bitblt(WindDC^.handle,0,0,640,480,MemDC^.handle,0,0,Srccopy);
         unfreeze(hwindow);
         finishdelay(1000 div fps,timer, Hwindow);
         repeat unfreeze(HWindow); until not paused;
       until fin=1;
       dispose(f,done);
     end;

   procedure proximity(who:integer);
     var f,c: pgenf;
         x,dist,pos,posn: integer;
     begin
       c:=nil;
       dist:=10000;
       f:=fpool^.at(who);
       pos:=f^.data.pos[1].x;
       for x:=0 to fpool^.count-1 do
          begin
            if not fpool^.alive then exit;
            if x<>who then
              begin
                f:=fpool^.at(x);
                posn := f^.data.pos[1].x-pos;
                if (abs(posn) < dist) and (not f^.data.pos[1].dying) then
                  begin
                    dist := posn;
                    c    := f;
                  end;
              end;
          end;
       f:=fpool^.at(who);
       if fpool^.count = 1 then c:=nil;
       f^.setclose(dist,c);
       if c <> nil then if dist<0 then f^.look(-1) else f^.look(1);
     end;

   procedure fight;
     var x,fin,col,i1,p1x,p1y:integer;
         f: pgenf;
         timer: longint;
         flip: bool;
         scx,scy: integer;
         temp,t1: string;
         
     begin
       fighting:=true;
       pressesc:= false;
       fin:=0;
       mode:='fight';
       col:=0;
       repeat
         startdelay(timer);
         setpen(UseDC,0,0,0); setbrush(usedc,0,0,0);  box(usedc,0,0,640,480,0,0);
         for x:=0 to fpool^.count-1 do
           begin
             if not fpool^.alive then exit;
             f:=fpool^.at(x);
             if f<> nil then
             with f^ do
               begin
                 scores.add(data.name,round(data.score)); 
                 unfreeze(HWindow);

                 scx:=320*(x mod 2);
                 scy:=40*(x div 2);

                 setfont(UseDC,'Comic Sans MS',20,0,0,0,0,0);
                 txt(UseDC,scx,scy,1,color[15],data.name);

                 setpen(UseDC,rgb(255,0,0),0,1);
                 qline(UseDC,scx,scy+25,scx+getlng(UseDC,data.name),scy+25);

                 setfont(UseDC,'Times New Roman',12,7,0,0,0,0);
                 str(data.score:0:0,temp);
                 txt(UseDC,scx,scy+25,1,color[15],'Score: '+temp);

                 str(data.hits:0:0,temp);
                 str(data.maxhits,t1);

                 p1x:=scx+305; p1y:=scy+7;
                 if data.maxhits <> 0 then
                   begin
                     i1:=100-round(data.hits/50*100);
                     str(i1,temp);
                     txt(UseDC,p1x,p1y,2,color[15],'Strength: '+temp+'%');
                   end
                 else  
                   begin
                     txt(UseDC,p1x-18,p1y,2,color[15],'Strength: ');
                     setfont(UseDC,'Symbol',12,7,0,0,0,0);
                     txt(UseDC,p1x,p1y,2,rgb(255,0,0),chr(165));
                   end;

                 setpen(UseDC,-1,0,0);
                 if (data.maxhits=0) then i1:=0 else i1:=round(data.hits/50*90);
                 if (i1>90) then i1:=90;
                 if (i1<0) then  i1:= 0;

                 setbrush(UseDC,data.color,-1,0);
                 box(UseDC,p1x-90,p1y+19,p1x-i1,p1y+29,0,0);

                 setpen(UseDC,color[14],0,0);
                 setbrush(UseDC,-1,-1,0);
                 box(UseDC,p1x-90,p1y+19,p1x,p1y+29,0,0);

                 proximity(x);
                 setpoints;
                 resize;
                 draw;
                 advanceframe;
               end;
             if f <> nil then
             with f^.data.keycodes do
               if (computer) and (not f^.data.pos[1].punch) and
               (not f^.data.pos[1].kick) then
                 begin
                   if abs(f^.closedist) > abs(1.3*f^.data.pos[1].size*
                     f^.data.pos[1].direction*PinM) then f^.walkf
                   else
                     if random(2)=0 then f^.kick else f^.punch;
                 end
               else
                 if not computer then
                 begin
                   if hiword(getkeystate(left))<>0 then f^.walkl;
                   if hiword(getkeystate(right))<>0 then f^.walkr;
                   if hiword(getkeystate(up))<>0 then f^.jump;
                   if hiword(getkeystate(down))<>0 then f^.duck;
                   if hiword(getkeystate(punch))<>0 then f^.punch;
                   if hiword(getkeystate(kick))<>0 then f^.kick; 
                 end;
             if f<> nil then
             with f^ do
               begin
                 if data.hits > data.maxhits then die;
                 advanceframe;
               end;
             if f <> nil then
               if (f^.closest=nil) and (f^.data.lastkill) then fin:=1;
             if f <> nil then
              if (not f^.data.pos[1].alive) then
               begin
                 dispose(f,done);
                 fpool^.atdelete(x);
                 for i1:=0 to fpool^.count-1 do
                   proximity(i1);
               end;
           end;
         if (not paused) and (UseDC=MemDC) then
           bitblt(WindDC^.handle,0,0,640,480,MemDC^.handle,0,0,Srccopy);
         finishdelay(1000 div fps,timer, Hwindow);
         repeat unfreeze(HWindow) until not paused;
         if not fpool^.alive then fin:=1;
         if pressesc then begin fin:=1; fighting:=true; end;
      until fin=1;
     end;

  procedure pause;
    begin
      paused := true;
      setbrush(WindDC,color[7],-1,4);
      setpen(WindDC,color[0],0,2);
      box(WindDC,0,0,640,480,0,0);
      setfont(WindDC,'Stencil',150,0,0,0,0,45);
      txt(WindDC,50,370,1,color[4],'PAUSED');
    end;

  begin
     defwndproc(msg);
     if first then
      begin
        first:=false;
        paused:=false;
        setbrush(WindDC,color[0],color[0],0);
        setpen(WindDC,color[0],0,2);
        box(WindDC,0,0,640,480,0,0);

{        fpool^.insert(new(pstickman,init(usedc,200,300,1,1,color[9],50,True,'Russ')));
        fpool^.insert(new(pstickman,init(usedc,200,300,1,1,color[9],50,True,'Russ')));
        modify(0);
 }
        intro;
        menu;
        done;
      end;
    if paused then pause;
  end;

procedure TWind.GetWindowClass( var WC: TWndClass);
  begin
    TWindow.GetWindowClass(WC);
    WC.hIcon := LoadIcon(hInstance, PChar(1));
  end;

procedure twind.givedc(TheDC: SDC); 
  var x:integer;
      f:pgenf;
  begin
    usedc:=TheDC;
    for x:= 0 to fpool^.count-1 do
      begin
        f:=fpool^.at(x);
        f^.setdc(TheDC);
      end;
  end;

procedure TWind.WMMouseMove(var Msg: Tmessage);
  var pos: tpoint;
      i,mx : integer;
      
  begin
    defwndproc(msg);

    pos.x := loword(msg.lparam);
    pos.y := hiword(msg.lparam);


    if mode ='menu' then mx:=8;
    if (mode='menu') then
      begin
        i := (pos.y-80) div 40;
        if (i<mx) and (i>0) and (pos.x>150) and (pos.x<490)
          then selected := i;
      end;

    if mode='players' then
      begin
        i := (pos.y-120) div 20;
        if (i>-1) and (i<10) then selected:=i else
          begin
            i := (pos.y-340) div 20+9;
            if(i>9) and (i<14) then selected:=i else selected:=-1;
          end;
      end;
  end;

procedure TWind.WMLButtonDown(var Msg: TMessage);
  var S: array[0..9] of Char;
      var pos: tpoint;
      i,mx : integer;
  begin
    defwndproc(msg);
    setcapture(Hwindow);

    pos.x := loword(msg.lparam);
    pos.y := hiword(msg.lparam);
    
    if not paused then pressany:=true;
    if mode ='menu' then mx:=8;
    if (mode='menu') then
      begin
        i := (pos.y-80) div 40;
        if (i<mx) and (i>0) and (pos.x>150) and (pos.x<490)
          then begin selected := i; activated := selected; end;
      end;

    if mode='players' then
      begin
        i := (pos.y-120) div 20;
        if (i>-1) and (i<10) then begin selected:=i; activated:=selected; end else
          begin
            i := (pos.y-340) div 20+9;
            if(i>9) and (i<14) then begin selected:=i; activated:=selected; end
            else selected := -1;
          end;
      end;

    if mode='mod' then
      begin
        if (pos.y>80) and (pos.y<110) then activated:=1;
        if (pos.y>120) and (pos.y<150) then
          begin
            i:= (pos.x-130) div 24 +2;
            if (i>=2) and (i<=17) then activated:=i;
          end;
        if (pos.y>160) and (pos.y<190) then activated:=18;
        if (pos.y>205) and (pos.y<235) then activated:=19;
        if (pos.y>260) and (pos.y<290) then
          begin
            if (pos.x>95) and (pos.x<205) then activated:=20;
            if (pos.x>225) and (pos.x<340) then activated:=21;
            if (pos.x>360) and (pos.x<420) then activated:=22;
            if (pos.x>450) and (pos.x<603) then activated:=23;
          end;
        if (pos.y>300) and (pos.y<400) then
          begin
           i:= round((pos.x-95)/((640-95)/7))+23;
           if (i>=24) and (i<=29) then activated:=i;
          end;
        if (pos.y>400) and (pos.y<435) and (pos.x>544) and (pos.x<606) then activated:=30;
      end;
     

  end;

procedure TWind.WMRButtonDown(var Msg: TMessage);
  begin
    defwndproc(msg);
    setcapture(Hwindow);
  end;

procedure TWind.WMLButtonUp(var Msg: Tmessage);
  begin
   defwndproc(msg);
   releasecapture;
  end;

procedure TWind.WMRButtonUp(var Msg: Tmessage);
  begin
   defwndproc(msg);
   releasecapture;
   done;
  end;

procedure Twind.WMKeyDown(var Msg:Tmessage);
  var x:integer;
      f: pgenf;
  begin
    vlast := msg.wparam;
    pressany := true;
    if msg.wparam = 27 then pressesc := true;

    if mode='fight' then
      for x:=0 to fpool^.count-1 do
        begin
          f:=fpool^.at(x);
          with f^.data.keycodes do
            if not computer then
            begin
              if msg.wparam = left  then f^.walkl;
              if msg.wparam = right then f^.walkr;
              if msg.wparam = up    then f^.jump; 
              if msg.wparam = down  then f^.duck; 
              if msg.wparam = punch then f^.punch;
              if msg.wparam = kick  then f^.kick; 
              if hiword(getkeystate(left))<>0 then f^.walkl;
              if hiword(getkeystate(right))<>0 then f^.walkr;
              if hiword(getkeystate(up))<>0 then f^.jump;
              if hiword(getkeystate(down))<>0 then f^.duck;
              if hiword(getkeystate(punch))<>0 then f^.punch;
              if hiword(getkeystate(kick))<>0 then f^.kick;
            end;
        end;
    defwndproc(Msg);
  end;

procedure Twind.WMKeyUp(var Msg:Tmessage);
  var x:integer;
      f: pgenf;
  begin
    if mode='fight' then
      for x:=0 to fpool^.count-1 do
        begin
          f:=fpool^.at(x);
          with f^.data.keycodes do
            if not computer then
            begin
              if msg.wparam = down  then f^.stopduck;
            end;
        end;
    defwndproc(Msg);
  end;

type tapp = object(tapplication)
       procedure initmainwindow; virtual;
     end;

procedure tapp.initmainwindow;
  var russ:HDC;
  begin
    mainwindow:=new(pwind,init(nil,'StickFighter!!!!'));
  end;

var myapp: tapp;
    thedc: hdc;
    x:integer;      
begin
  myapp.init('Appname');
  myapp.run;
  myapp.done;
end.