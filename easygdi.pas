{ EasyGDI v2.03 }

{ added clipto, cliptorect, clearclip, ishappyptr }

unit easygdi;

{$R easy.res}
             
interface

uses bitmaps,wobjects, winprocs,wintypes,strings,commdlg, windos, mmsystem, win31;

type points = record
    x: Integer;
    y: Integer;
  end;

type pFONT = ^FONT;
     FONT = record
       face: string;
       height,weight: integer;
       italic,underline,strikeout:byte;
       angle:real;
       fcolor,bgcolor:longint;
       halign,valign: word;
     end;  
type BMP = ^EZBitmap;
     EZBitmap = record
       Breed: Word;
       DChandle: HDC;
       origDC: integer;
       windowh: hwnd;
       ThePen: Hpen;
       TheBrush: HBrush;
       TheBitmap: HBitmap;
       TheFont: pFont;
     end;

const wndBMP = 0;
      memBMP = 1;
      encdcBMP = 2;
      enchBMP = 3;

const solid      = 0;
      dash       = 1;
      dots       = 2;
      dashdots   = 3;
      exdashdots = 4;

      hlines     = 1;
      vlines     = 2;
      ddlines    = 3;
      udlines    = 4;
      grid       = 5;
      dgrid      = 6;

      arcline    = 0;
      arcslice   = 1;
      pieslice   = 2;

      border     = 0;
      surface    = 1;

      alternate  = 1;
      winding    = 2;

      times      = 'Times New Roman';
      arial      = 'Arial';
      courier    = 'Courier New';
      cursive    = 'Cursive-Elegant';
      comic      = 'Comic Sans MS';
      stencil    = 'Stencil';
      verdana    = 'Verdana';
      ransom     = 'RansomNote';

      ta_Left   = 0;
      ta_Right  = 2;
      ta_Center = 6;

      ta_Top      = 0;
      ta_Bottom   = 8;
      ta_BaseLine = 24;


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

function RGB(R: Byte; G: Byte; B: Byte): LongInt;
inline(
  $5A/       { POP DX    }
  $5B/       { POP BX    }
  $58/       { POP AX    }
  $8A/$E3/   { MOV AH,BL }
  $32/$F6);  { XOR DH,DH }
function GetRValue(RGB: LongInt): Byte;
inline(
  $58/       { POP AX    }
  $5A/       { POP DX    }
  $32/$E4);  { XOR AH,AH }
function GetGValue(RGB: LongInt): Byte;
inline(
  $58/       { POP AX    }
  $5A/       { POP DX    }
  $8A/$C4/   { MOV AL,AH }
  $32/$E4);  { XOR AH,AH }
function GetBValue(RGB: LongInt): Byte;
inline(
  $5A/       { POP DX    }
  $58/       { POP AX    }
  $32/$E4);  { XOR AH,AH }

function gradient(color1,color2:longint; stepno,steps:integer):longint;

procedure setpen(TheBMP:BMP; color: longint; linestyle, width: integer);
procedure setbrush(TheBMP:BMP; color,bcolor:longint; style: integer);
procedure box(TheBMP:BMP; x1,y1,x2,y2,x3,y3:integer);
procedure circle(TheBMP:BMP; cx,cy,radiusw,radiush:integer);
procedure pcircle(TheBMP:BMP; xpos,ypos,radiusw,radiush,angle1,angle2,way:integer);
procedure line(TheBMP:BMP; x1,y1,x2,y2:integer);
procedure connectdots(TheBMP:BMP; var pointarray; count:integer);
procedure shape(TheBMP:BMP;  var pointarray; count,method: integer);
procedure pset(TheBMP:BMP; x,y: integer; color:longint);
function pixel(TheBMP:BMP; x,y:integer):longint;
procedure fill(TheBMP:BMP; x,y:integer; colorinfo:longint; filltype:integer);
procedure quickfont(var AFont:FONT; fface:string; fsize: integer);
procedure setfont(ABMP:BMP; var AFont:FONT);
function getfont(ABMP:BMP):pFONT;
procedure print(ABMP:BMP; x,y:integer; text:string);
procedure wrapprint(ABMP:BMP; x,y,w:integer; text:string);
function getwrappedheight(ABMP:BMP; w:integer; text:string):integer;
function getwrappedwidth(ABMP:BMP; w:integer; text:string):integer;
function gettextwidth(ABMP: BMP; text:string):word;
function gettextheight(ABMP: BMP; text:string):word;

procedure cliptorect(ABMP:BMP; x1,y1,x2,y2:hrgn);
procedure clipto(ABMP:BMP; rgn: hrgn);
procedure clearclip(ABMP:BMP);

function DChandle(thebmp:BMP):HDC;
function getwidth(thebmp:bmp):integer;
function getheight(thebmp:bmp):integer;
procedure supremecopy(Source, SourceMask, Destination: bmp;
                      Sx,Sy,Sw,Sh: integer;
                      Dx,Dy,Dw,Dh: integer);

function makewindowBMP(HWindow:hwnd):BMP;
function makeblankBMP(CompatibleBMP:BMP;  Width,Height:word):BMP;
function LoadBMP(filename:string):BMP;
function encapsulateDC(DC:HDC):BMP;
function isbmp(var it:BMP):boolean;
procedure killBMP(var it: BMP);
procedure saveBMP(TheBMP:BMP; filename:string);
procedure drawpicture(TheBMP: BMP; filename: string; x,y:integer);
procedure copybmp(Source,Destination:bmp; Dx,Dy:integer);
procedure stretchcopy(Source,Destination:bmp; Dx,Dy,Dw,Dh:integer);
procedure piececopy(Source,Destination:bmp; Sx,Sy,Sw,Sh,Dx,Dy:integer);
procedure maskcopy(Source,SourceMask,Destination:bmp; Dx,Dy:integer);

function pc(var s: string): pchar;
function FileExists(FileName: String): Boolean;
function ishappyptr(p:pointer; size:integer):boolean;
function isdown(virtkey: integer): boolean;

procedure wunfreeze(Wnd: Hwnd);
procedure wdelay(Wnd:Hwnd; milliseconds:longint);
procedure wstartdelay(var t: longint);
procedure wfinishdelay(Wnd:Hwnd; t,milliseconds:longint);
function wFileOpen(HWindow:hwnd; path,ftype,extension: string):string;
function wFileSave(HWindow:hwnd; path,ftype,extension: string):string;
function getapppath(instance: thandle): string;
function getappdir(instance:thandle):string;

implementation


function gradient(color1,color2:longint; stepno,steps:integer):longint;
var red,green,blue: integer;
  begin
    gradient := rgb(
      round(stepno/steps*(getrvalue(color2)-getrvalue(color1))+getrvalue(color1)),
      round(stepno/steps*(getgvalue(color2)-getgvalue(color1))+getgvalue(color1)),
      round(stepno/steps*(getbvalue(color2)-getbvalue(color1))+getbvalue(color1))
      );

  {  gradient := rgb (
      getrvalue(color1) + (stepno*(getrvalue(color2)-getrvalue(color1))) div steps,
      getgvalue(color1) + (stepno*(getgvalue(color2)-getgvalue(color1))) div steps,
      getbvalue(color1) + (stepno*(getbvalue(color2)-getbvalue(color1))) div steps
    ); }

  end;

procedure setpen(TheBMP:BMP; color: longint; linestyle, width: integer);
  begin
    with TheBMP^ do
      begin
        if color < 0 then
          ThePen := CreatePen(PS_NULL,width,0)
        else
          ThePen := CreatePen(linestyle, width, color);
        DeleteObject(SelectObject(DCHandle,ThePen));
      end;
  end;

procedure setbrush(TheBMP:BMP; color,bcolor:longint; style: integer);
var brushstyle: tlogbrush;
  begin
    with TheBMP^ do
      begin
        if bcolor < 0 then
          setbkmode(DChandle,1)
        else 
          begin
            setbkmode(DChandle,2);
            setbkcolor(DChandle,bcolor);
          end;

        if color<0 then
          begin
            brushstyle.lbstyle:=BS_HOLLOW;
            TheBrush:=CreateBrushIndirect(brushstyle);
          end
        else
          if style=0 then
            begin
              brushstyle.lbstyle:=BS_SOLID;
              brushstyle.lbcolor:=color;
              TheBrush:=CreateBrushIndirect(brushstyle);
            end
          else
            TheBrush := CreateHatchBrush(style-1,color);;;

        DeleteObject(SelectObject(DChandle,TheBrush));

      end;
  end;

procedure box(TheBMP:BMP; x1,y1,x2,y2,x3,y3:integer);
  begin
    roundrect(TheBMP^.DChandle,x1,y1,x2,y2,x3,y3);
  end;

procedure circle(TheBMP:BMP; cx,cy,radiusw,radiush:integer);
var x1,y1,x2,y2,c,d:integer;
  begin
    Ellipse(TheBMP^.DChandle,cx-radiusw,cy-radiush,cx+radiusw,cy+radiush);
  end;

procedure pcircle(TheBMP:BMP; xpos,ypos,radiusw,radiush,angle1,angle2,way:integer);
var x1,y1,x2,y2,x3,y3,x4,y4,c,d:integer;
  begin
    x1:=xpos-radiusw;  y1:=ypos-radiush;  x2:=xpos+radiusw;  y2:=ypos+radiush;
    x3:=xpos+round(radiusw*(cos(angle1/180*pi))); y3:=ypos-round(radiush*(sin(angle1/180*pi)));
    x4:=xpos+round(radiusw*(cos(angle2/180*pi))); y4:=ypos-round(radiush*(sin(angle2/180*pi)));

    case way of
      0: arc(TheBMP^.dchandle, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
      1: chord(TheBMP^.dchandle, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
      2: pie(TheBMP^.dchandle, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
    end;
  end;

procedure line(TheBMP:BMP; x1,y1,x2,y2:integer);
var ends:array[1..2] of tpoint;
  begin
    ends[1].x:=x1;  ends[1].y:=y1;  ends[2].x:=x2;  ends[2].y:=y2;
    polyline(TheBMP^.dchandle,ends,2);
  end;

procedure connectdots(TheBMP:BMP; var pointarray; count:integer);
  begin
    Polyline(TheBMP^.dchandle,pointarray,count)
  end;

procedure shape(TheBMP:BMP;  var pointarray; count,method: integer);
  begin
    setpolyfillmode(TheBMP^.dchandle,method);     {1=alternate, 2=winding}
    polygon(TheBMP^.dchandle,pointarray,count);
  end;

procedure pset(TheBMP:BMP; x,y: integer; color:longint);
  begin
    if not(color < 0) then setpixel(TheBMP^.dchandle,x,y,color);
  end;

function pixel(TheBMP:BMP; x,y:integer):longint;
  begin
    pixel := getpixel(TheBMP^.dchandle,x,y);
  end;

procedure fill(TheBMP:BMP; x,y:integer; colorinfo:longint; filltype:integer);
  begin
    ExtFloodFill(TheBMP^.dchandle,x,y,colorinfo,filltype);
  end;

function pc(var s: string): pchar;
  begin
    s[length(s)+1] := char(0);
    pc := @s[1];
  end;  

procedure quickfont(var AFont:FONT; fface:string; fsize: integer);
  begin
    with AFont do
      begin
        face := fface;
        height := fsize;
        weight := 0;
        italic := 0;
        underline := 0;
        strikeout := 0;
        angle := 0;
        fcolor := color[0];
        bgcolor := -1;
        halign := TA_LEFT;
        valign := TA_TOP;
      end;
  end;

procedure setfont(ABMP:BMP; var AFont:FONT);
  begin
    ABMP^.TheFont := @AFont;
  end;

function getfont(ABMP:BMP):pFONT;
  begin
    getfont := ABMP^.TheFont;
  end;

function prepfont(DC:HDC; font: pFONT): hfont; {not part of interface}
  var nfont:hfont;
  begin 
    with font^ do
      begin
        settextcolor(DC, fcolor);
        settextalign(DC, halign or valign);

        if bgcolor < 0 then
          setbkmode(DC,TRANSPARENT)
        else
          begin
            setbkmode(DC,OPAQUE);
            setbkcolor(DC,bgcolor);
          end;

        nfont := CreateFont(height,0,
                   round(angle*10),0,
                   weight,italic,underline,strikeout,
                   1 {DEFAULT_CHARSET},
                   out_Default_Precis,
                   CLIP_DEFAULT_PRECIS,
                   DEFAULT_QUALITY,
                   DEFAULT_PITCH or FF_DONTCARE,
                   pc(face));

        prepfont := selectobject(DC,nfont);
      end;
  end;

procedure print(ABMP:BMP; x,y:integer; text:string);
  var oldfont: hfont;
      oldbkmode:integer;
      oldbkcolor:longint;
      DC:HDC;
  begin
    DC         :=  ABMP^.dchandle;
    oldbkmode  :=  getbkmode(DC);
    oldbkcolor :=  getbkcolor(DC);
    oldfont    :=  prepfont(DC,ABMP^.TheFont);

    TextOut(DC,x,y,pc(text),length(text));

    deleteobject(selectobject(DC,oldfont));
    setbkmode(DC, oldbkmode);
    setbkcolor(DC, oldbkcolor);
  end;

procedure wrapprint(ABMP:BMP; x,y,w:integer; text:string);
  var oldfont: hfont;
      oldbkmode:integer;
      oldbkcolor:longint;
      DC:HDC;
      TextBox: trect;

  begin
    DC         :=  ABMP^.dchandle;
    oldbkmode  :=  getbkmode(DC);
    oldbkcolor :=  getbkcolor(DC);
    oldfont    :=  prepfont(DC,ABMP^.TheFont);

    TextBox.Left   := x;
    TextBox.Top    := y;
    TextBox.Right  := x+w;
    TextBox.Bottom := y+1;

    DrawText(DC, pc(text), length(text), TextBox, DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_NOCLIP);

    deleteobject(selectobject(DC,oldfont));
    setbkmode(DC, oldbkmode);
    setbkcolor(DC, oldbkcolor);
  end;

function getwrappedwidth(ABMP:BMP; w:integer; text:string):integer;
  var oldfont: hfont;
      DC:HDC;
      TextBox: trect;
      TextFormat: word;

  begin
    DC         :=  ABMP^.dchandle;
    oldfont    :=  prepfont(DC,ABMP^.TheFont);

    TextBox.Left   := 0;
    TextBox.Top    := 0;
    TextBox.Right  := w;
    TextBox.Bottom := 1;

    DrawText(DC, pc(text), length(text), TextBox,
      DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_NOCLIP);

    getwrappedwidth := TextBox.Right-TextBox.Left;

    deleteobject(selectobject(DC,oldfont));
  end;

function getwrappedheight(ABMP:BMP; w:integer; text:string):integer;
  var oldfont: hfont;
      DC:HDC;
      TextBox: trect;
      TextFormat: word;

  begin
    DC         :=  ABMP^.dchandle;
    oldfont    :=  prepfont(DC,ABMP^.TheFont);

    TextBox.Left   := 0;
    TextBox.Top    := 0;
    TextBox.Right  := w;
    TextBox.Bottom := 1;

    DrawText(DC, pc(text), length(text), TextBox,
      DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_NOCLIP);

    getwrappedheight := TextBox.Bottom-TextBox.Top;

    deleteobject(selectobject(DC,oldfont));
  end;


function gettextwidth(ABMP: BMP; text:string):word;
  var oldfont: hfont;
      DC:HDC;
  begin
    DC      :=  ABMP^.dchandle;
    oldfont :=  prepfont(DC,ABMP^.TheFont);

    gettextwidth := loword(GetTextExtent(DC,pc(text),length(text)) );

    deleteobject(selectobject(DC,oldfont));
  end;

function gettextheight(ABMP: BMP; text:string):word;
  var oldfont: hfont;
      DC:HDC;
  begin
    DC      :=  ABMP^.dchandle;
    oldfont :=  prepfont(DC,ABMP^.TheFont);

    gettextheight := hiword(GetTextExtent(DC,pc(text),length(text)) );

    deleteobject(selectobject(DC,oldfont));
  end;

procedure cliptorect(ABMP:BMP; x1,y1,x2,y2:hrgn);
  var rgn:hrgn;
  begin
    rgn := CreateRectRgn(X1, Y1, X2, Y2);
    selectcliprgn(ABMP^.dchandle,rgn);
    deleteobject(rgn);
  end;

procedure clipto(ABMP:BMP; rgn: hrgn);
  begin
    selectcliprgn(ABMP^.dchandle,rgn);
  end;

procedure clearclip(ABMP:BMP);
  begin
    selectcliprgn(ABMP^.dchandle,0);
  end;

function DChandle(thebmp:BMP):HDC;
  begin
    DChandle := thebmp^.dchandle;
  end;

function getwidth(thebmp:bmp):integer;
var infob:tbitmap;
    infow:trect;
  begin
    with TheBMP^ do
      case breed of
        wndBMP:
          begin
            getclientrect(windowh,infow);
            getwidth := infow.right-infow.left;
          end; 
        memBMP:
          begin
            getobject(TheBitmap,sizeof(infob),@infob);
            getwidth:=infob.bmwidth;
          end;
        encdcBMP:
          begin
            getwidth:=GetDeviceCaps(DChandle,horzres);
          end;
        else getwidth := 0;
      end;
  end;

function getheight(thebmp:bmp):integer;
var infob:tbitmap;
    infow:trect;
  begin
    with TheBMP^ do
      case breed of
        wndBMP:
          begin
            getclientrect(windowh,infow);
            getheight := infow.bottom-infow.top;
          end; 
        memBMP:
          begin
            getobject(TheBitmap,sizeof(infob),@infob);
            getheight := infob.bmheight;
          end; 
        else getheight := 0;
      end;
  end;

procedure supremecopy(Source, SourceMask, Destination: bmp;
                      Sx,Sy,Sw,Sh: integer;
                      Dx,Dy,Dw,Dh: integer);

  var newdc1,newdc2: HDC;
      oldbmp1,oldbmp2: HBitmap;

  begin
    if (Sw=0) then Sw := getwidth(source);
    if (Sh=0) then Sh := getheight(source);
    if (Dw=0) then Dw := Sw;
    if (Dh=0) then Dh := Sh;

    if (sourcemask=nil) then
      begin
        StretchBlt( Destination^.DCHandle, Dx, Dy, Dw, Dh,
                    Source^.DCHandle,      Sx, Sy, Sw, Sh,
                    srccopy );
      end
    else
      begin
        newdc1 := CreateCompatibleDC(Destination^.DCHandle);
        newdc2 := CreateCompatibleDC(Source^.DCHandle);

        oldbmp1 := SelectObject(newdc1, CreateCompatibleBitmap(Destination^.DChandle,Dw,Dh));
        oldbmp2 := SelectObject(newdc2, CreateCompatibleBitmap(Source^.DChandle,Sw,Sh));

        BitBlt(     newdc1,                 0,  0, Dw, Dh,
                    Destination^.DChandle, Dx, Dy,
                    SrcCopy);

        BitBlt(newdc2,                      0,  0, Sw, Sh,
                    Source^.DChandle,      Sx, Sy,
                    SrcCopy);

        BitBlt(     newdc2,                 0,  0, Sw, Sh,
                    SourceMask^.DCHandle,  Sx, Sy,
                    SrcAnd);              

        StretchBlt( newdc1,                 0,  0, Dw, Dh,
                    SourceMask^.DCHandle,  Sx, Sy, Sw, Sh,
                    $00220326);

        StretchBlt( newdc1,                 0,  0, Dw, Dh,
                    newdc2,                Sx, Sy, Sw, Sh,
                    SrcPaint);

        BitBlt(     Destination^.DChandle, Dx, Dy, Dw, Dh,
                    newdc1,                 0,  0,
                    SRCCOPY);

        Deleteobject(SelectObject(newdc1,oldbmp1));
        Deleteobject(SelectObject(newdc2,oldbmp2));
        DeleteDC(newdc1); DeleteDC(newdc2);
      end;
  end;

function makewindowBMP(HWindow:hwnd):BMP;
  var x: BMP;
  begin
    x := new(BMP);
    with x^ do
      begin
        Breed     :=  wndbmp;
        DChandle  :=  GetDC(HWindow);
        origDC    :=  SaveDC(DChandle);
        windowh   :=  hwindow;
     end;
    makewindowBMP := x;
  end;

function makeblankBMP(CompatibleBMP:BMP;  Width,Height:word):BMP;
  var x: BMP;
  begin
    x := new(BMP);
    with x^ do
      begin
        Breed     := memBMP;
        DChandle  := CreateCompatibleDC(CompatibleBMP^.DChandle);
        origDC    := SaveDC(DChandle);
        TheBitmap := CreateCompatibleBitmap(CompatibleBMP^.DChandle,Width,Height);
        SelectObject(DChandle,TheBitmap);
      end;
    makeblankBMP := x;
  end;

function LoadBMP(filename:string):BMP;
  var x: BMP;
      error: string;
  begin
    x := new(BMP);
    with x^ do
      begin
        Breed     := memBMP;
        DChandle  := CreateCompatibleDC(0);
        origDC    := SaveDC(DChandle);
        TheBitmap := LoadBitmapFile(pc(filename));
        if TheBitmap=0 then
          begin
            error := 'Failed to load bitmap ' + '''' + filename +'''';
            MessageBox(0,pc(error),
            'EasyGDI Error',MB_ICONEXCLAMATION or MB_OK);  
          end;
        SelectObject(DChandle,TheBitmap);
      end;
    LoadBMP := x;
  end;

function encapsulateDC(DC:HDC):BMP;
  var x: BMP;
  begin
    x := new(BMP);
    with x^ do
      begin
        Breed     := encdcBMP;
        DChandle  := DC;
        origDC    := SaveDC(DChandle);
      end;
    encapsulateDC := x;
  end;

function isbmp(var it:BMP):boolean;
  begin
    if (it=nil) or IsBadWritePtr(it,sizeof(ezbitmap)) then
      isbmp := false
    else
      if isgdiobject(it^.dchandle) then isbmp := true;
  end;

procedure killBMP(var it: BMP);
  begin
    with it^ do
      begin
        RestoreDC(DChandle, origDC);
        deleteobject(ThePen);
        deleteobject(TheBrush);
        deleteobject(TheBitmap);
        case Breed of
          wndBMP: ReleaseDC(windowh, DCHandle);
          memBMP: DeleteDC(DCHandle);
          encdcBMP: begin end;
        end;
      end;
    dispose(it);
    it := nil;
  end;

procedure saveBMP(TheBMP:BMP; filename:string);
  var newb: BMP;
  begin
     case TheBMP^.breed of
        membmp: StoreBitmapFile(pc(filename),TheBMP^.TheBitmap);
        wndbmp:
          begin
            newb := makeblankBMP(TheBMP,getwidth(TheBMP),getheight(TheBMP));
            supremecopy(TheBMP,nil,newb,0,0,0,0,0,0,0,0);
            StoreBitmapFile(pc(filename),newb^.TheBitmap);
            killBMP(newb);
          end;
     end;
  end;
  
procedure drawpicture(TheBMP: BMP; filename: string; x,y:integer);
  var n: bmp;
  begin
    n := LoadBMP(filename);
    SupremeCopy(n, nil, TheBMP,
                0,0,0,0,
                x,y,0,0);
    killbmp(n);
  end;

procedure copybmp(Source,Destination:bmp; Dx,Dy:integer);
  begin
    supremecopy(Source,nil,Destination,0,0,0,0,Dx,Dy,0,0);
  end;

procedure stretchcopy(Source,Destination:bmp; Dx,Dy,Dw,Dh:integer);
  begin
    supremecopy(Source,nil,Destination,0,0,0,0,Dx,Dy,Dw,Dh);
  end;

procedure piececopy(Source,Destination:bmp; Sx,Sy,Sw,Sh,Dx,Dy:integer);
  begin
    supremecopy(Source,nil,Destination,Sx,Sy,Sw,Sh,Dx,Dy,0,0);
  end;

procedure maskcopy(Source,SourceMask,Destination:bmp; Dx,Dy:integer);
  begin
    supremecopy(Source,SourceMask,Destination,0,0,0,0,Dx,Dy,0,0);
  end;

function FileExists(FileName: String): Boolean;
var
  F: file;
begin
  {$I-}
  Assign(F, FileName);
  Reset(F);
  Close(F);
  {$I+}
  FileExists := (IOResult = 0) and (FileName <> '');
end;

function ishappyptr(p:pointer; size:integer):boolean;
  begin
    ishappyptr := (p<>nil) and not IsBadWritePtr(p,size);
  end;

function isdown(virtkey: integer): boolean;
  begin
    isdown := boolean(hiword(getkeystate(virtkey)));
  end;

procedure wunfreeze(Wnd: Hwnd);
var Msg: TMsg;
  begin  
    while PeekMessage(Msg, Wnd, 0, 0, pm_Remove) do
    begin
      if Msg.Message = WM_QUIT then begin Application^.Done; halt; end;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  end;

procedure wdelay(Wnd:Hwnd; milliseconds:longint);
var t: longint;
  begin
    t:=gettickcount;
    repeat
      wunfreeze(Wnd);
    until gettickcount-t>=milliseconds;
  end;

procedure wstartdelay(var t: longint);
  begin
    t := gettickcount;
  end;

procedure wfinishdelay(Wnd:Hwnd; t,milliseconds:longint);
  begin
    repeat
      wunfreeze(Wnd);
    until gettickcount-t>=milliseconds;
  end;

type TFilename = array [0..255] of Char;

function wFileOpen(HWindow:hwnd; path,ftype,extension: string):string;
var
  OpenFN      : TOpenFileName;
  Filter      : array [0..100] of Char;
  FullFileName: TFilename;
  WinDir      : array [0..145] of Char;
  filename    : pchar;
  wildcards   : string;
begin
  wildcards := '*.'+extension;
  SetCurDir(pc(path));
  StrCopy(FullFileName, '');
  FillChar(Filter, SizeOf(Filter), #0);  { Set up for double null at end }
  StrCopy(Filter, pc(ftype));
  StrCopy(@Filter[StrLen(Filter)+1], pc(wildcards));
  FillChar(OpenFN, SizeOf(TOpenFileName), #0);
  with OpenFN do
  begin
    hInstance     := HInstance;
    hwndOwner     := HWindow;
    lpstrDefExt   := pc(extension);
    lpstrFile     := FullFileName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= FileName;
    flags         := ofn_FileMustExist;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FullFileName);
  end;
  if GetOpenFileName(OpenFN) then wfileopen := strpas(fullfilename);
  {SndPlaySound(FileName, 1);   {Second parameter must be 1} 
end;

function wFileSave(HWindow:hwnd; path,ftype,extension: string):string;
var
  OpenFN      : TOpenFileName;
  Filter      : array [0..100] of Char;
  FullFileName: TFilename;
  WinDir      : array [0..145] of Char;
  filename    : pchar;
  wildcards   : string;
begin
  wildcards := '*.'+extension;
  SetCurDir(pc(path));
  StrCopy(FullFileName, '');
  FillChar(Filter, SizeOf(Filter), #0);  { Set up for double null at end }
  StrCopy(Filter, pc(ftype));
  StrCopy(@Filter[StrLen(Filter)+1], pc(wildcards));
  FillChar(OpenFN, SizeOf(TOpenFileName), #0);
  with OpenFN do
  begin
    hInstance     := HInstance;
    hwndOwner     := HWindow;
    lpstrDefExt   := pc(extension);
    lpstrFile     := FullFileName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= FileName;
    flags         := ofn_FileMustExist;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FullFileName);
  end;
  if GetSaveFileName(OpenFN) then wfilesave := strpas(fullfilename);
end;

function getapppath(instance: thandle): string;
  var path: array[0..255] of char;
      l : integer;
  begin
    l := getmodulefilename(instance,path,255);
    getapppath := strpas(path);
  end;

function getappdir(instance:thandle):string;
  var x:boolean;
      pos:integer;
      s: string;
  begin
    s := getapppath(instance);
    x := false;
    pos := length(s);
    repeat
      dec(pos);
      if (pos = 0) or (s[pos]='\') then x := true;
    until x;
      getappdir := copy(s,1,pos-1);
  end;

begin
end.