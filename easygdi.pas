{ EasyGDI v1.0}

unit easygdi;

{$R easy.res}
             
interface

uses wobjects, winprocs,wintypes,strings,commdlg, windos, mmsystem;

type HDC = THandle;
     BMP = THandle;
     Points = record
       x: Integer;
       y: Integer;
     end;

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

function makeDC(FromWhat:Thandle; Form:Word):SDC;
procedure killDC(var it: SDC);
procedure Asetpen(DC:SDC; color: longint; linestyle, width: integer);
procedure Asetbrush(DC:SDC; color,bcolor:longint; style: integer);
procedure Abox(DC:SDC; x1,y1,x2,y2,x3,y3:integer);
procedure Aqcircle(DC:SDC; xpos,ypos,radiusw,radiush:integer);
procedure Aqline(DC: SDC; x1,y1,x2,y2:integer);
procedure Aqarc(DC: SDC; xpos,ypos,radiusw,radiush,angle1,angle2,way:integer);
procedure Aconnectdots(DC: SDC; var pointarray; count:integer);
procedure Ashape(DC: SDC; var pointarray; count,method: integer);
procedure Apset(DC: SDC; xpos,ypos: integer; color:longint);
function Apixel(DC: SDC; xpos,ypos:integer):longint;
procedure Afill(DC: SDC; xpos,ypos:integer; colorinfo:longint; filltype:integer);
function getred(color:longint):integer;
function getgreen(color:longint):integer;
function getblue(color:longint):integer;
function gradient(color1,color2:longint; stepno,steps:integer):longint;
function pc(st: string): pchar;
procedure Asetfont(DC:SDC; fontface:string; size,weight,italic,underline,strikeout:integer;angle:real );
function Agetlng(DC:SDC; text:string):longint;
procedure Atxt(DC: SDC; x,y,align:integer; color:longint; text:string);
function getwidth(thebmp:bmp):integer;
function getheight(thebmp:bmp):integer;
procedure setbmp(DC: SDC; Picture: BMP);
function loadbmp(filename:string):BMP;
procedure deletebmp(var thebmp:bmp);
procedure Adrawbmp(DC: SDC; x,y: integer;  bmpname: bmp;  stretched,width,height:integer);
procedure Amaskbmp(TheDC:SDC; x,y: integer; themask,thepic: bmp; stretched,wth,ht:integer);
procedure Adrawpicture(DC:SDC; x,y:integer; filename:string);
procedure Aunfreeze(Wnd: Hwnd);
procedure Adelay(milliseconds:longint; Wnd:Hwnd);
procedure Astartdelay(var t: longint);
procedure Afinishdelay(milliseconds,t:longint; wnd:hwnd);
function AFileOpen(HWindow:hwnd; path,ftype,wildcards: string):string;
function AFileSave(HWindow:hwnd; path,ftype,wildcards: string):string;
function getapppath(instance: thandle): string;
function FileExists(FileName: String): Boolean;
function isdown(virtkey: integer): boolean;

implementation

function makeDC(FromWhat:Thandle; Form:Word):SDC;
  var bob: sdc;
  begin
    bob:=new(SDC);
    with bob^ do
      begin
        if form=0 then handle:=getDC(fromwhat);
        if form=1 then handle:=createcompatibleDC(Fromwhat);
        if form=2 then handle:=fromwhat;
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

procedure Asetpen(DC:SDC; color: longint; linestyle, width: integer);
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

procedure Asetbrush(DC:SDC; color,bcolor:longint; style: integer);
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

procedure Abox(DC:SDC; x1,y1,x2,y2,x3,y3:integer);
  begin
    if dc<>nil then
    roundrect(DC^.handle,x1,y1,x2,y2,x3,y3);
  end;

procedure Aqcircle(DC:SDC; xpos,ypos,radiusw,radiush:integer);
var x1,y1,x2,y2,c,d:integer;
  begin
    x1:=xpos-radiusw;  y1:=ypos-radiush;  x2:=xpos+radiusw;  y2:=ypos+radiush;
    if dc<>nil then
    Ellipse(DC^.handle, X1,Y1,X2,Y2);
  end;

procedure Aqline(DC: SDC; x1,y1,x2,y2:integer);
var ends:array[1..2] of tpoint;
  begin
    ends[1].x:=x1;  ends[1].y:=y1;  ends[2].x:=x2;  ends[2].y:=y2;
    if dc<>nil then
    polyline(DC^.handle,ends,2);
  end;

procedure AQarc(DC: SDC; xpos,ypos,radiusw,radiush,angle1,angle2,way:integer);
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

procedure Aconnectdots(DC: SDC; var pointarray; count:integer);
  begin
    if DC <> nil then Polyline(DC^.handle,pointarray,count)
  end;

procedure Ashape(DC: SDC; var pointarray; count,method: integer);
  begin
    if DC <> nil then
      begin
        setpolyfillmode(DC^.handle,method);     {1=alternate, 2=winding}
        polygon(DC^.handle,pointarray,count);
      end;
  end;

procedure Apset(DC: SDC; xpos,ypos: integer; color:longint);
  begin
    if DC <> nil then setpixel(DC^.handle,xpos,ypos,color);
  end;

function Apixel(DC: SDC; xpos,ypos:integer):longint;
  begin
    if DC <> nil then Apixel:=getpixel(DC^.handle,xpos,ypos);
  end;

procedure Afill(DC: SDC; xpos,ypos:integer; colorinfo:longint; filltype:integer);
  begin
    if DC <> nil then EXTFLOODFILL(DC^.handle,xpos,ypos,colorinfo,filltype);
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

function pc(st: string): pchar;
  var p: array[0..1024] of char;
  begin
    strpcopy(p,st);
    pc := @p;
  end;  

procedure Asetfont(DC:SDC; fontface:string; size,weight,italic,underline,strikeout:integer;angle:real );
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

function Agetlng(DC:SDC; text:string):longint;
  var p:pchar;
  begin
    if dc<>nil then
    with DC^ do
      begin
        newfont:=createfontindirect(prpfont);
        thefont:=selectobject(handle,Newfont);
        if oldfont=0 then oldfont:=thefont else deleteobject(thefont);
        p:=pc(text);
        Agetlng:=loword(GetTextExtent(handle,p,strlen(p)));
      end;
  end;

procedure Atxt(DC: SDC; x,y,align:integer; color:longint; text:string);
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
          0: aln:=TA_LEFT;
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

procedure setbmp(DC: SDC; Picture: BMP);
  begin
    if (DC <> nil) and (picture>0) then
    with DC^ do begin
      thebmp:=selectobject(handle,picture);
      if oldbmp=0 then oldbmp:=thebmp else deleteobject(thebmp);
    end;
  end;

procedure AHIncr; far; external 'KERNEL' index 114;

function loadbmp(filename:string):BMP;

  procedure GetBitmapData(var TheFile: File; BitsHandle: THandle; BitsByteSize: Longint);
    type
      LongType = record
        case Word of
          0: (Ptr: Pointer);
          1: (Long: Longint);
          2: (Lo: Word; Hi: Word);
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

  function OpenDIB(var TheFile: File): bmp;
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
          opendib := NewBitmapHandle
        else
          OpenDIB := 0;
      end
      else
        OpenDIB := 0;
    end;

  var
    TheFile: File;
    TestWin30Bitmap: Longint;
    tempbmp: bmp;
begin
  LoadBmp := 0;
  Assign(TheFile, filename);
  Reset(TheFile, 1);
  Seek(TheFile, 14);
  BlockRead(TheFile, TestWin30Bitmap, SizeOf(TestWin30Bitmap));
  if TestWin30Bitmap = 40 then
    begin
      tempbmp := opendib(thefile);
      if tempbmp = 0 then
        MessageBox(0, 'EASYGDI:  Unable to create Windows 3.0 bitmap from file.',
          pc(filename), mb_Ok);
    end
    else
      MessageBox(0, 'EASYGDI:  Not a Windows 3.0 bitmap file.  Convert using Paintbrush.', pc(fileName), mb_Ok);
    Close(TheFile);
    loadbmp := tempbmp;
end;

procedure deletebmp(var thebmp:bmp);
begin
  deleteobject(thebmp);
end;

procedure Paint(PaintDC:HDC; thebmp: bmp; xpos,ypos,width,height:integer; stretch: boolean; Rop:longint);
  var
    MemDC: HDC;
    Info:tbitmap;
begin
  if thebmp <> 0 then
    begin
      getobject(thebmp,10,@info);
{      if width = 0  then width  := info.bmwidth;
      if height = 0 then height := info.bmheight;
 }     MemDC := CreateCompatibleDC(PaintDC);
      SelectObject(MemDC, thebmp);
      if Stretch then
          StretchBlt(PaintDC, xpos, ypos, width, height, MemDC, 0, 0,
	    info.bmwidth, info.bmheight, Rop)
      else
        BitBlt(PaintDC, xpos, ypos, info.bmwidth, info.bmheight, MemDC, 0, 0, Rop);
      DeleteDC(MemDC);
    end;
end;

procedure Adrawbmp(DC: SDC; x,y: integer;  bmpname: bmp;  stretched,width,height:integer);
  begin
    if dc<>nil then
    Paint(DC^.handle,bmpname,x,y,width,height,boolean(stretched), srccopy);
  end;

procedure Amaskbmp(TheDC:SDC; x,y: integer; themask,thepic: bmp; stretched,wth,ht:integer);
var tempdc: HDC;
    Info:tbitmap;
    DC:HDC;
  begin
    getobject(thepic,10,@info);
    if (wth = 0) or (stretched = 0) then wth := info.bmwidth;
    if (ht = 0)  or (stretched = 0) then ht  := info.bmheight;
    if TheDC<>nil then
      begin
        DC:=TheDC^.handle;
        paint(DC,themask,x,y,wth,ht,boolean(stretched),dstinvert);
        paint(DC,themask,x,y,wth,ht,boolean(stretched),notsrcerase);
        tempdc := createcompatibledc(DC);
        selectobject(tempdc, thepic);  
        paint(tempDC,themask,0,0,0,0,false,srcand);
        stretchblt(DC,x,y,wth,ht,tempdc,0,0,info.bmwidth,info.bmheight,srcpaint);
        deletedc(tempdc);     
      end;
  end;

procedure Adrawpicture(DC:SDC; x,y:integer; filename:string);
var pict: bmp;
begin
  pict := loadbmp(filename);
  Adrawbmp(DC,x,y,pict,0,0,0);
  deletebmp(pict);
end;

procedure Aunfreeze(Wnd: Hwnd);
var Msg: TMsg;
  begin  
    while PeekMessage(Msg, Wnd, 0, 0, pm_Remove) do
    begin
      if Msg.Message = WM_QUIT then begin Application^.Done; halt; end; 
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  end;

procedure Adelay(milliseconds:longint; Wnd:Hwnd);
var t: longint;
  begin
    t:=gettickcount;
    repeat
      Aunfreeze(Wnd);
    until gettickcount-t>=milliseconds;
  end;

procedure Astartdelay(var t: longint);
  begin
    t := gettickcount;
  end;

procedure Afinishdelay(milliseconds,t:longint; wnd:hwnd);
  begin
    repeat
      Aunfreeze(Wnd);
    until gettickcount-t>=milliseconds;
  end;

type TFilename = array [0..255] of Char;

function AFileOpen(HWindow:hwnd; path,ftype,wildcards: string):string;
const
  DefExt = 'sav';
var
  OpenFN      : TOpenFileName;
  Filter      : array [0..100] of Char;
  FullFileName: TFilename;
  WinDir      : array [0..145] of Char;
  filename    : pchar;
begin
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
    lpstrDefExt   := DefExt;
    lpstrFile     := FullFileName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= FileName;
    flags         := ofn_FileMustExist;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FullFileName);
  end;
  if GetOpenFileName(OpenFN) then Afileopen := strpas(fullfilename);
  {SndPlaySound(FileName, 1);   {Second parameter must be 1} 
end;

function AFileSave(HWindow:hwnd; path,ftype,wildcards: string):string;
const
  DefExt = 'sav';
var
  OpenFN      : TOpenFileName;
  Filter      : array [0..100] of Char;
  FullFileName: TFilename;
  WinDir      : array [0..145] of Char;
  filename    : pchar;
begin
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
    lpstrDefExt   := DefExt;
    lpstrFile     := FullFileName;
    lpstrFilter   := Filter;
    lpstrFileTitle:= FileName;
    flags         := ofn_FileMustExist;
    lStructSize   := sizeof(TOpenFileName);
    nFilterIndex  := 1;       {Index into Filter String in lpstrFilter}
    nMaxFile      := SizeOf(FullFileName);
  end;
  if GetSaveFileName(OpenFN) then Afilesave := strpas(fullfilename);
end;

function getapppath(instance: thandle): string;
  var path: array[0..255] of char;
      l : integer;
  begin
    l := getmodulefilename(instance,path,255);
    getapppath := strpas(path);
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

function isdown(virtkey: integer): boolean;
  begin
    isdown := boolean(hiword(getkeystate(virtkey)));
  end;

begin
end.