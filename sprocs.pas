unit sprocs;

interface

uses wintypes,winprocs,maths,wobjects;

const WM_ENTERMENULOOP = $0211;
const WM_EXITMENULOOP  = $0212;

const
  menu_newgame = 2;
  menu_pausegame = 11;
  menu_opengame = 3;
  menu_savegame = 4;
  menu_exitgame = 1;
  menu_fullscreen = 10;
  menu_restart = 7;
  menu_mainmenu = 6;
  menu_players = 5;
  menu_highscores = 101;
  menu_aboutgame = 9;
  menu_fps = 200;

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
function rmin(x,y:real):real;
function gint(x:real):longint;
function bounce(time,min,max,velocity,init:real):real;
function descendupon(time,etime,startv,endv:real):real;

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

function rmin(x,y:real):real;
  begin
    if x<y then rmin := x else rmin := y;
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


begin
end.