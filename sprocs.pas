unit sprocs;

interface

uses wintypes,winprocs,maths,wobjects,easygdi,easycrt;

const WM_ENTERMENULOOP = $0211;
const WM_EXITMENULOOP  = $0212;

const gamepinm = 100;

const
  menu_aboutgame = 1;
  menu_newgame = 2;
  menu_opengame = 21;
  menu_savegame = 3;
  menu_fullscreen = 4;
  menu_restart = 5;
  menu_mainmenu = 6;
  menu_players = 7;
  menu_highscores = 8;
  menu_rungame=9;
  menu_exitgame = 10;
  menu_pausegame = 101;
  menu_fps = 102;
  wm_player = wm_user+1;

const fpsinterval = 10;
      fpslabel = ' frames/sec';

function atan(x,y:real): real;
function asin(x: real): real;
function acos(x: real): real;
function min(x,y: real): real;
function max(x,y: real): real;
function badtri(A,B,C:real):boolean;
function abovezero(number: integer):integer;

type tmapmode = record
       windowo,windowe,viewporto,viewporte:longint;
       mode:integer;
     end;

procedure savemapmode(dc:hdc; var mapmode:tmapmode);
procedure writemapmode(dc:hdc; s:string);
procedure loadmapmode(dc:hdc; var mapmode:tmapmode);

type tsavebmp = record
       rfont:font;
       pencolor:longint; penwidth,penstyle:integer;
       brushcolor1,brushcolor2: longint; brushstyle:integer;
     end;

procedure setbmp(thebmp:bmp; var saved:tsavebmp);

function rmin(x,y:real):real;
function rmax(x,y:real):real;
function gint(x:real):longint;
function bounce(time,min,max,velocity,init:real):real;
function descendupon(time,etime,startv,endv:real):real;
function choose(condition:boolean; iftrue,iffalse:integer):integer;

function isbeyond(current,beginning,ending:real):boolean;
procedure circleline(usebmp:bmp; x1,y1,x2,y2,radius:integer; displace:real);

implementation

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

function badtri(A,B,C:real): boolean;
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

procedure savemapmode(dc:hdc; var mapmode:tmapmode);
  begin
    mapmode.mode := getmapmode(dc);
    mapmode.viewporto := getviewportorg(dc);
    mapmode.viewporte := getviewportext(dc);
    mapmode.windowo   := getwindoworg(dc);
    mapmode.windowe   := getwindowext(dc);
  end;

procedure writemapmode(dc:hdc; s:string);
  var mapmode:tmapmode;
  begin
    mapmode.mode := getmapmode(dc);
    mapmode.viewporto := getviewportorg(dc);
    mapmode.viewporte := getviewportext(dc);
    mapmode.windowo   := getwindoworg(dc);
    mapmode.windowe   := getwindowext(dc);
    writeln(s,' mode:        ',mapmode.mode);
    writeln(s,' viewportorg: ',loword(mapmode.viewporto),',',hiword(mapmode.viewporto));
    writeln(s,' viewportext: ',loword(mapmode.viewporte),',',hiword(mapmode.viewporte));
    writeln(s,' windoworg  : ',loword(mapmode.windowo  ),',',hiword(mapmode.windowo  ));
    writeln(s,' windowext  : ',loword(mapmode.windowe  ),',',hiword(mapmode.windowe  )); 
  end;

procedure loadmapmode(dc:hdc; var mapmode:tmapmode);
  begin
    setmapmode(dc,mapmode.mode);
    setviewportorg(dc,loword(mapmode.viewporto), hiword(mapmode.viewporto));
    setviewportext(dc,loword(mapmode.viewporte), hiword(mapmode.viewporte));
    setwindoworg  (dc,loword(mapmode.windowo)  , hiword(mapmode.windowo));
    setwindowext  (dc,loword(mapmode.windowe)  , hiword(mapmode.windowe));
  end;

procedure setbmp(thebmp:bmp; var saved:tsavebmp);
  begin
    setfont(thebmp,saved.rfont);
    setpen(thebmp,saved.pencolor,saved.penstyle,saved.penwidth);
    setbrush(thebmp,saved.brushcolor1,saved.brushcolor2,saved.brushstyle);
  end;

function rmin(x,y:real):real;
  begin
    if x<y then rmin := x else rmin := y;
  end;

function rmax(x,y:real):real;
  begin
    if x>y then rmax := x else rmax := y;
  end;

function gint(x:real):longint;
  begin
    if x>=0 then
      gint := trunc(x)
    else
      gint := trunc(x)-1;
  end;

function bounce(time,min,max,velocity,init:real):real;
  var x:real;
  begin
    x := (time)*velocity/(max-min)+init*2;
    bounce := (max+min)/2 + (max-min)*(x-gint(x)-0.5)*pwrxy(-1,gint(x));
  end;

function descendupon(time,etime,startv,endv:real):real;
  begin
    descendupon := (endv-startv)/etime*rmin(time,etime)+startv;
  end;

function choose(condition:boolean; iftrue,iffalse:integer):integer;
  begin
    if condition then choose := iftrue else choose := iffalse;
  end;

procedure swap(var x:integer; var y:integer);
  var z:integer;
  begin
    z := x;
    x := y;
    y := z;
  end;

function isbeyond(current,beginning,ending:real):boolean;
  begin
    isbeyond := (current>rmax(beginning,ending)) or (current<rmin(beginning,ending));
  end;

procedure circleline(usebmp:bmp; x1,y1,x2,y2,radius:integer; displace:real);
  var x,y,incx,incy,incx1,incy1,n,m:real;
  begin
    writeln(x1,',',y1,',',x2,',',y2);
{    if (y2-y1=0) then incx1 := 2*radius
    else incx1 := 2*radius*sqrt(1-            1/(  sqr(x2-x1)/sqr(y2-y1)+1           )     );

    if (x2-x1=0) then incy1 := 2*radius
    else incy1 := 2*radius*sqrt(1-            1/(  sqr(y2-y1)/sqr(x2-x1)+1           )     );

   if (x1=x2) and (y1=y2) then
     begin
       incx := 0;
       incy := 0;
     end
   else }
     begin
       n := (  sqr(x2-x1)           +sqr(y2-y1)  );

      incx := 2*radius*sqrt(1-  sqr(y2-y1)/n     );
       incy := 2*radius*sqrt(1-  sqr(x2-x1)/n     );



{       incx := 2*radius*sqrt(1-  sqr(y2-y1)/(  sqr(x2-x1)           +sqr(y2-y1)  )     );
       incy := 2*radius*sqrt(1-  sqr(x2-x1)/(  sqr(x2-x1)           +sqr(y2-y1)  )     );
 }

    writeln({'    incx1=',incx1:0:2,}
            '    incx=',incx:0:2,
{            '    incy1=',incy1:0:2,    }
            '    incy=',incy:0:2);


    if x2<x1 then incx := -incx;
    if y2<y1 then incy := -incy;
   
    x := x1+incx*displace;
    y := y1+incy*displace;

    repeat
      circle(usebmp,round(x),round(y),radius,radius);
      x := x + incx;
      y := y + incy;
      unfreeze;
    until isbeyond(x,x1,x2) or isbeyond(y,y1,y2);














     end;


  end;


begin
end.