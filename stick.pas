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
    settextcolor(DC,color); textout(DC,x,y,pc(txt),lng); settextcolor(DC,0);
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

procedure qline(DC: HDC; x1,y1,x2,y2:integer);
var ends:array[1..2] of tpoint;
  begin
    ends[1].x:=x1;  ends[1].y:=y1;  ends[2].x:=x2;  ends[2].y:=y2;
    polyline(DC,ends,2);
  end;

procedure Qarc(DC: HDC; xpos,ypos,radiusw,radiush,angle1,angle2,way:integer);
var x1,y1,x2,y2,x3,y3,x4,y4,c,d:integer;
  begin
    x1:=xpos-radiusw;  y1:=ypos-radiush;  x2:=xpos+radiusw;  y2:=ypos+radiush;
    x3:=xpos+round(radiusw*(cos(angle1/180*pi))); y3:=ypos-round(radiush*(sin(angle1/180*pi)));
    x4:=xpos+round(radiusw*(cos(angle2/180*pi))); y4:=ypos-round(radiush*(sin(angle2/180*pi)));
    case way of
      0: arc(DC, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
      1: chord(DC, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
      2: pie(DC, X1,Y1,X2,Y2,X3,Y3,X4,Y4);
    end;
  end;

procedure unfreeze(Wnd: Hwnd);
var M: TMsg;
  begin  
    while PeekMessage(M, Wnd, 0, 0, pm_Remove) do
    begin
      DispatchMessage(M);
    end;
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

    { not mathematically correct, but painless way to fix program }
      if abs(x) > 1 then acos:=pi else
    { done }
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
    if (a+b<c) or (b+c<a) or (a+c<b) then badtri:=true else badtri:=false;
  end;

procedure setcurdc(tDC:HDC);
  begin
    DC := tDC;
  end;


{- END ------------------------------------------  Drawing Commands}


const fps = 5;
      gamespeed = 1;

      fframes = round(2*fps/gamespeed+1);

      PinM = 150;

type tkeys = record
       left,right,up,down,punch,kick:word
     end;

type pfprops = ^tfprops;
     tfprops = record
       l1x,l1y,l2x,l2y,cx,cy,a1x,a2x,head,size, duck: real;
       x,y,direction: integer;
       jump,walk,punch,kick: boolean;
     end;

type pgenf = ^tgenf;
     tgenf = object(Tobject)
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
          l1y  :=  -1;
          l2x  := 0.5;
          l2y  :=  -1;
          cx   :=   0;
          cy   :=   0;
          a1x  := 0.5;
          a2x  := 0.5;
          head := 0.5;
          duck := 0.8;
          size := sze*2;
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
    pos[1].x:=pos[1].x+10;
  end;

procedure tgenf.walkl;
  begin
    pos[1].x:=pos[1].x-10;
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
       defl1,defl2,defa1,defa2,headW,headH,deftorso: integer;
       K1x,K1y,K2x,K2y,F1x,F1y,F2x,F2y,Ctx,Cty,E1x,E1y,E2x,E2y,H1x,H1y,H2x,H2y,Hdx,Hdy,
       Sx,Sy: integer;
       nose: real;
       procedure subinit; virtual;
       procedure draw; virtual;
     end;

procedure tstickman.draw;
  var duckby,ang,t1x,t1y,t2x,t2y: real;
      temp: string;
      a2: real;
  begin
    with pos[1] do
      begin
        setcurdc(DC);
        setbrush(DC,0,0,0);
        box(DC,0,0,640,480,0,0);

        duckby := duck*(defl1+defl2);
        cty    := round(y-duckby);
        ctx    := round(x);
{ ------------------------------------------  Legs         }
        t1x := l1x*(defl1+defl2);
        t1y := l1y*duckby;
        t2x := l2x*(defl1+defl2);
        t2y := l2y*duckby;

        f1x    := round(x-direction*t1x);
        f2x    := round(x+direction*t2x);
        f1y    := round(y-duckby-t1y);
        f2y    := round(y-duckby-t2y);

        ang    := atan(t1x,t1y)+pi
                  -acos((sqr(defl2)-sqr(defl1)-(sqr(t1x)+sqr(t1y)))/
                  (2*defl1*sqrt(sqr(t1x)+sqr(t1y))));
        k1x    := round(x-direction*defl1*cos(ang));
        k1y    := round(y-duckby-defl1*sin(ang));
        
        ang    := atan(t2x,t2y)+pi
                  -acos((sqr(defl2)-sqr(defl1)-(sqr(t2x)+sqr(t2y)))/
                  (2*defl1*sqrt(sqr(t2x)+sqr(t2y))));
        k2x    := round(x+direction*defl1*cos(ang));
        k2y    := round(y-duckby-defl1*sin(ang));


{ ------------------------------------------  Torso        }
        Sx     := ctx;
        Sy     := cty-deftorso;

{ ------------------------------------------  Arms         }

        a2x:=0.2;

        t1x := a1x*(defa1+defa2);
        t2x := a2x*(defa1+defa2);
        t1y := 0;
        t2y := 0;

        h1x    := round(x-direction*t1x);
        h2x    := round(x+direction*t2x);
        h1y    := Sy;
        h2y    := Sy;

        ang    := -acos((sqr(defa2)-sqr(defa1)-(sqr(t1x)+sqr(t1y)))/
                  (2*defa1*sqrt(sqr(t1x)+sqr(t1y))));
        e1x    := round(Sx+direction*defa1*cos(ang));
        e1y    := round(Sy-defa1*sin(ang));
        
        ang    := -acos((sqr(defa2)-sqr(defa1)-(sqr(t2x)+sqr(t2y)))/
                  (2*defa1*sqrt(sqr(t2x)+sqr(t2y))));
        e2x    := round(Sx-direction*defa1*cos(ang));
        e2y    := round(Sy-defa1*sin(ang));

{ ------------------------------------------  Head         }
        hdx    := sx;
        hdy    := round(sy-head*PinM*size/2);

        {herehere}


    setpen(DC,color[15],0,0);
    qline(DC,k2x,k2y,f2x,f2y);
    qline(DC,ctx,cty,k2x,k2y);
    qline(DC,k1x,k1y,f1x,f1y);
    qline(DC,ctx,cty,k1x,k1y);
    qline(DC,ctx,cty,Sx,Sy);
    qline(DC,Sx,Sy,E1x,E1y);
    qline(DC,E1x,E1y,H1x,H1y);
    qline(DC,Sx,Sy,E2x,E2y);
    qline(DC,E2x,E2y,H2x,H2y);
    qline(DC,Sx,Sy,Hdx,Hdy);
    
    setpen(DC,color[12],0,2);
    qcircle(DC,ctx,cty,3,3);
    qcircle(DC,k1x,k1y,3,3);
    qcircle(DC,k2x,k2y,3,3);
    qcircle(DC,f1x,f1y,3,3);
    qcircle(DC,f2x,f2y,3,3);
    qcircle(DC,Sx,Sy,3,3);
    qcircle(DC,E1x,E1y,3,3);
    qcircle(DC,H1x,H1y,3,3);
    qcircle(DC,E2x,E2y,3,3);
    qcircle(DC,H2x,H2y,3,3);
    setbrush(DC,0,0,0);
    qcircle(DC,HDx,HDy,direction*headw,headh);
    qline(DC,HDx+round(direction*headw*nose),HDy,
          HDx+round(direction*headw*cos(20/180*pi)),
          HDy-round(headh*sin(20/180*pi)));
    qline(DC,HDx+round(direction*headw*nose),HDy,
          HDx+round(direction*headw),HDy);
    {

    qarc(DC,HDx+round(direction*headw*0.75),HDy-round(headh*0.3),
           25,20,160,190,2);


    qarc(DC,HDX+round(direction*headw),HDy,
            round(direction*headw*1),10,190,260,0);
     }
   
      end;

    setfont(DC,'Arial',15,9,0,0,0,0);
    str(t2x:0:0,temp);
    txt(DC,10,250+10,1,color[15],'t2x   '+temp);
    str(t2y:0:0,temp);
    txt(DC,10,250+30,1,color[15],'t2y   '+temp);
    str(ang/pi*180:0:0,temp);
    txt(DC,10,250+50,1,color[15],'ang   '+temp);
    str(k1x:0,temp);
    txt(DC,10,250+70,1,color[15],'k1x   '+temp);
    str(k1y:0,temp);
    txt(DC,10,250+90,1,color[15],'k1y   '+temp);


  end;

procedure tstickman.subinit;
  begin
    defl1     := round(0.5  * PinM  * pos[1].size);
    defl2     := round(0.4  * PinM  * pos[1].size);
    defa1     := round(0.3  * PinM  * pos[1].size);
    defa2     := round(0.3  * PinM  * pos[1].size);
    deftorso  := round(0.4  * PinM  * pos[1].size);
    headw     := round(0.25 * PinM  * pos[1].size);
    headh     := round(0.15 * PinM  * pos[1].size);
    nose      := 1.4;
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
    defwndproc(Msg);
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
     var x,fin: integer;
         f: pgenf;
     begin
      fin:=0;
      mode:='fight';
      repeat
        for x:=0 to fpool^.count-1 do
          begin
            f:=fpool^.at(x);
            with f^ do
              begin
                unfreeze(HWindow);
                draw;
                advanceframe;
              end;
          end;
      until fin=1;
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
        fpool^.insert(new(pstickman,init(WindDC,Hwindow,300,300,1,0.5)));
        curfighter:=fpool^.at(0);
        curfighter^.setkeys1;
        curfighter^.draw;
        fight;
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
