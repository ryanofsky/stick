program whothehellcares;
uses wobjects, winprocs, wintypes,strings;

{$R stick.res}

{------------------------------------------------  Drawing Commands}
type HDC = THandle;
     BMP = THandle;
     Points = record
       x: Integer;
       y: Integer;
     end;

var DC:HDC;
    ThePen: HPen;
    OldPen: HPen;
    PrpPen: TLogPen;
    TheBrush: HBrush;
    OldBrush: HBrush;
    PrpBrush:TLogBrush;
    TheFont: HFont;
    OldFont: HFont;
    PrpFont: TLogFont;
    ink: word;

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


function pc(strng:string):pchar;
var step1: array[0..1000] of Char;
  begin
    StrPCopy(step1,strng);
    pc:=step1;
  end;

procedure txt(DC: HDC; x,y,align:integer; color:longint; txt:string);
var aln,lng:integer;
  begin
    case align of
      1: aln:=TA_LEFT;
      2: aln:=TA_RIGHT;
      3: aln:=TA_CENTER;
      end;
    lng:=length(txt);
    TheFont := CreateFontIndirect(PrpFont);
    OldFont := SelectObject(DC, TheFont);
    settextalign(DC,aln);
    setbkmode(DC,1);  settextcolor(DC,color); textout(DC,x,y,pc(txt),lng); settextcolor(DC,0);
    TheFont:=SelectObject(DC, OldFont);
    DeleteObject(TheFont);
    TheFont:=OldFont;
  end;

procedure setfont(DC:HDC; fontface:string; size,weight,italic,underline,strikeout:integer;angle:real );
  begin
    PrpFont.lfHeight         := -1*size;
    PrpFont.lfWidth          := 0;
    PrpFont.lfEscapement     := round(angle*10);
    PrpFont.lfWeight         := weight*100;
    PrpFont.lfItalic         := byte(italic);
    PrpFont.lfUnderline      := byte(underline);
    PrpFont.lfStrikeout      := byte(strikeout);
{   PrpFont.lfcharset }
{   PrpFont.lfOutprecision   := OUT_TT_PRECIS; }
    PrpFont.lfQuality        := PROOF_QUALITY;
    PrpFont.lfPitchAndFamily := DEFAULT_PITCH or FF_DONTCARE;
    StrCopy(Prpfont.lfFaceName,pc(fontface));
  end;

procedure setpen(DC:HDC; color: longint; linestyle, width: integer);
  begin
    if color <> -1 then
      ThePen := CreatePen(linestyle, width, color)
    else
    ThePen := CreatePen(PS_NULL,width,0);
    oldpen:=selectobject(DC,ThePen);
    deleteobject(oldpen);
  end;

procedure setbrush(DC:HDC; color,bcolor:longint; style: integer);
var brushstyle: tlogbrush;
  begin
    if bcolor=-1 then
      begin
        setbkmode(DC,1);
      end;
    if bcolor>=0 then
      begin
        setbkmode(DC,2);
        setbkcolor(DC,bcolor);
      end;
    if color=-1 then
      begin
        brushstyle.lbstyle:=BS_HOLLOW;
        thebrush:=CreateBrushIndirect(brushstyle);
      end
    else
      if style=0 then
        begin
          brushstyle.lbstyle:=BS_SOLID;
          brushstyle.lbcolor:=color;
          thebrush:=CreateBrushIndirect(brushstyle);
        end
      else
        thebrush:=createhatchbrush(style-1,color);;
    oldbrush:=selectobject(DC,thebrush);
    deleteobject(oldbrush);
  end;

procedure box(DC:HDC; x1,y1,x2,y2,x3,y3:integer);
  begin
    roundrect(DC,x1,y1,x2,y2,x3,y3);
  end;

procedure qcircle(DC:HDC; xpos,ypos,radiusw,radiush:integer);
var x1,y1,x2,y2,c,d:integer;
  begin
    x1:=xpos-radiusw;  y1:=ypos-radiush;  x2:=xpos+radiusw;  y2:=ypos+radiush;
    Ellipse(DC, X1,Y1,X2,Y2);
  end;

procedure unfreeze;
var M: TMsg;
  begin  
    while PeekMessage(M, 0, 0, 0, pm_Remove) do
    begin
      DispatchMessage(M);
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

{- END ------------------------------------------  Drawing Commands}


const fps = 5;
      gamespeed = 1;

      fframes = round(2*fps/gamespeed+1);

      PinM = 150;

type tkeys = record
       left,right,up,down,punch,kick:integer;
     end;

type pfprops = ^tfprops;
     tfprops = record
       l1x,l1y,l2x,l2y,cx,cy,a1x,a2x,head,size, duck: real;
       x,y,direction: integer;
       jump,walk,punch,kick: boolean;
     end;

type pgenf = ^tgenf;
     tgenf = object(Tobject)
       defheight: integer;
       pos: array [1..fframes] of tfprops;
       keycodes: tkeys;
       DC: HDC;
       HWindow: Hwnd;
       constructor init(TheDC:HDC; TheWind: Hwnd; xpos,ypos, dir:integer; sze: real);
       destructor done; virtual;
       procedure draw; virtual;
       procedure subinit; virtual;
       procedure advanceframe; virtual;
       procedure walkr; virtual;
       procedure walkl; virtual;
       procedure kick; virtual;
       procedure punch; virtual;
       procedure jump; virtual;
       procedure duck; virtual;
       procedure setkeys1; virtual;
     end;

constructor tgenf.init(TheDC:HDC; TheWind: Hwnd; xpos,ypos, dir: integer; sze:real);
  var x: integer;
  begin
    DC:=TheDC;
    HWindow:=TheWind;
    for x := 1 to fframes do
      with pos[x] do
        begin
          l1x  := 0.5;
          l2x  := 0.5;
          l2y  :=  -1;
          cx   :=   0;
          cy   :=   0;
          a1x  := 0.5;
          a2x  := 0.5;
          head := 0.5;
          duck := 0.5;
          x    := xpos;
          y    := ypos;
          direction := dir;
          jump := false;
          walk := false;
          punch:= false;
          kick := false;
        end;
    subinit;
  end;

destructor tgenf.done;
  begin
  end;

procedure tgenf.subinit;
  begin
    messagebox(0,'TGENF.SUBINIT has been called','StickFighter Error',0);
  end;

procedure tgenf.draw;
  begin
    messagebox(0,'TGENF.DRAW has been called','StickFighter Error',0);
  end;

procedure tgenf.advanceframe;
  var x: integer;
  begin
    for x:=1 to fframes-1 do
      begin
        pos[x]:=pos[x+1]
      end;
  end;

procedure tgenf.walkr;
  begin
  end;

procedure tgenf.walkl;
  begin
  end;

procedure tgenf.kick;
  begin
  end;

procedure tgenf.punch;
  begin
  end;

procedure tgenf.jump;
  begin
  end;

procedure tgenf.duck;
  begin
  end;

procedure tgenf.setkeys1;
  begin
    with keycodes do
      begin
        up    :=  38; {up arrow    }
        down  :=  40; {down arrow  }
        left  :=  37; {left arrow  }
        right :=  39; {right arrow }
        punch :=  16; {shift       }
        kick  :=  17; {control     }
      end;
  end;

type pstickman = ^tstickman;
     tstickman = object(tgenf)
       defl1,defl2,defa1,defa2,headdiam: integer;
       K1x,K1y,K2x,K2y,F1x,F1y,F2x,F2y,Ctx,Cty,E1x,E1y,E2x,E2y,H1x,H1y,H2x,H2y,Hdx,Hdy: integer;
       procedure subinit; virtual;
       procedure draw; virtual;
     end;

procedure tstickman.draw;
  begin
    setpen(DC,color[4],0,2);
    setbrush(DC,color[0],color[0],0);
    qcircle(DC,pos[1].x,pos[1].y,10,10);




{

          l1x  := 0.5;
          l2x  := 0.5;
          l2y  :=  -1;
          cx   :=   0;
          cy   :=   0;
          a1x  := 0.5;
          a2x  := 0.5;
          head := 0.5;
          duck := 0.5;
          x    := xpos;
          y    := ypos;
          direction := dir;
          jump := false;
          walk := false;
          punch:= false;
          kick := false;
}






  end;

procedure tstickman.subinit;
  begin
    defheight := round(1.75 * PinM);
    defl1     := round(0.5 * PinM);
    defl2     := round(0.5 * PinM);
    defa1     := round(0.4 * PinM);
    defa2     := round(0.4 * PinM);
    headdiam  := round(0.3 * PinM);
  end;

type pwind = ^twind;
     twind = object(twindow)
       WindDC: HDC;
       mode: string;
       first: boolean;
       ldown,rdown:boolean;
       fpool: pcollection;
       curfighter: pgenf;
       constructor init(AParent: PWindowsObject; ATitle: PChar);
       procedure WMLButtonDown(var Msg: TMessage);  virtual wm_First + wm_LButtonDown;
       procedure WMRButtonDown(var Msg: TMessage);  virtual wm_First + wm_RButtonDown;
       procedure WMLButtonUp(var Msg: TMessage);  virtual wm_First + wm_LButtonUp;
       procedure WMRButtonUp(var Msg: TMessage);  virtual wm_First + wm_RButtonUp;
       procedure WMKeyDown(var Msg:Tmessage); virtual wm_First + wm_Keydown;
       procedure WMPaint(var Msg: Tmessage);        virtual wm_First + wm_Paint;
       procedure GetWindowClass( var WC: TWndClass); virtual;
       destructor Done; virtual;
     end;

constructor twind.Init(AParent: PWindowsObject; ATitle: PChar);
  var wc: twndclass;
  begin
    twindow.init(AParent,ATitle);
    with attr do
      begin
        style:= WS_POPUPwindow;
        exstyle:=exstyle or $00000008;
        x:=0;                                   
        y:=0;
        w:=640;
        h:=480;
      end;
    WindDC := GetDC(HWindow);
    first:=TRUE;
    fpool:=new(pcollection,init(1,1));
  end;

procedure TWind.GetWindowClass( var WC: TWndClass);
  begin
    TWindow.GetWindowClass(WC);
    WC.hIcon := LoadIcon(hInstance, PChar(1));
  end;

destructor twind.done;
  begin
    releasecapture;
    dispose(fpool,done);
    ReleaseDC(HWindow, WindDC);
    twindow.done;
  end;

procedure TWind.WMLButtonDown(var Msg: TMessage);
 var S: array[0..9] of Char;
  begin
    defwndproc(msg);
    setcapture(Hwindow);
    ldown:=true;
    if (mode='intro') or (mode='menu') or (mode='test') then
      begin
        setpen(windDC,color[4],0,0);
        qcircle(windDC,Msg.LParamLo+attr.X, Msg.LParamHi+attr.Y,10,10);
      end;
  end;

procedure TWind.WMRButtonDown(var Msg: TMessage);
  begin
    defwndproc(msg);
    setcapture(Hwindow);
    rdown:=true;
    done;
  end;

procedure TWind.WMLButtonUp(var Msg: Tmessage);
  begin
   defwndproc(msg);
   ldown:=false;
   releasecapture;
  end;

procedure TWind.WMRButtonUp(var Msg: Tmessage);
  begin
   defwndproc(msg);
   rdown:=false;
   releasecapture;
  end;

procedure Twind.WMKeyDown(var Msg:Tmessage);
  var x:integer;
      codes: tkeys;
      f: pgenf;
  begin
    if mode='fight' then
      for x:=0 to fpool^.count-1 do
        begin
          f:=fpool^.at(x);
          with f^.keycodes do
            begin
              if msg.wparam = left  then f^.walkl;
              if msg.wparam = right then f^.walkr;
              if msg.wparam = up    then f^.jump;
              if msg.wparam = down  then f^.duck;
              if msg.wparam = punch then f^.punch;
              if msg.wparam = kick  then f^.kick;
            end;
        end;
  end;

procedure twind.wmpaint(var msg: tmessage);
  procedure intro;
    begin
      mode:='intro';
      txt(windDC,100,200,1,color[14],'Introduction Here');
    end;

   procedure menu;
     begin
       mode:='menu';
     end;

   procedure fight;
     begin
       mode:='fight';
     end;

  begin
     defwndproc(msg);
     if first then
      begin
        first:=false;
        setbrush(WindDC,0,0,0);
        box(WindDC,0+attr.x,0+attr.y,640+attr.x,480+attr.y,0,0);
        setbrush(WindDC,0,color[15],0);
        intro;
        menu;
        fpool^.insert(new(pstickman,init(WindDC,Hwindow,200,200,1,1)));
        curfighter:=fpool^.at(0);
        fight; 
        curfighter^.draw;
      end;
     
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
