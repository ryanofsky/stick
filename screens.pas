unit screens;
interface

uses wintypes,wobjects,easygdi,game,win31,easycrt,winprocs,fighters,sprocs;

type tfpsdata = record
       frametime: array[1..fpsinterval] of longint;
       noframes:integer;
     end;

{- Generic Screen -------------------------------------------------------------------}

type pscreen = ^tscreen;
     tscreen = object(tobject)

       { resources }
       usebmp:bmp;
       usefont:font;
       window: pwindow;

       { state variables }
       elapsed,difference:longint;
       fpsdata: tfpsdata;
       paused,needsrepaint,istrashed:boolean;

       { create & destroy }
       constructor init(drawbmp:bmp; wnd:pwindow);
       destructor done; virtual;

       { external procedures }
       procedure update;virtual;
       procedure drawfps; virtual;
       function canpause:boolean; virtual;
       procedure pause; virtual;
       procedure unpause; virtual;

       { external input }
       procedure mousedown(var msg:tmessage); virtual;
       procedure mouseup(var msg:tmessage); virtual;
       procedure mousemove(var msg:tmessage); virtual;
       procedure keydown(var msg:tmessage); virtual;
       procedure keyup  (var msg:tmessage); virtual;
       procedure chartype(var msg:tmessage); virtual;
       procedure timertick(var msg:tmessage); virtual;

       { internal procedures }
       procedure resettime; virtual;
       procedure settime; virtual;
       procedure draw; virtual;
       procedure windowmenu(id:word); virtual;

     end;

{- Intro Screen ---------------------------------------------------------------------}

const minvelocity = 0.01;
const maxvelocity = 0.25;
const etime = 1000;
const blinkrate = 700;
const blinktext = 'Press a key to continue...';
const ip_nothingness = 0;
      ip_bigbang = 1;
      ip_evolution = 2;
      ip_ultimatewarrior = 3;

type tshapesinmotion = record
    x10,y10,x20,y20:real;
    x1v,y1v,x2v,y2v:real;
  end;

type pintro = ^tintro;
     tintro = object(tscreen)
     p:array[0..30] of tshapesinmotion;
     f:pstickman;
     age:integer;
     blinkon: boolean;
     sticktitle:bmp;
     constructor init(drawbmp:bmp; wnd:pwindow);
     destructor done; virtual;
     procedure draw; virtual;
     procedure chartype(var msg:tmessage); virtual;
     procedure mousedown(var msg:tmessage); virtual;
     procedure nextage; virtual;
     procedure timertick(var msg:tmessage); virtual;
     end;

{- Generic Menu ---------------------------------------------------------------------}

type pmenuscreen = ^tmenuscreen;
     tmenuscreen = object(tscreen)
       nocontrols:integer;
       constructor init(drawbmp:bmp; wnd:pwindow; gamescreen:prect);
       procedure pconvert(var point:tpoint);
       procedure draw; virtual;
       procedure drawback; virtual;
     end;


{- Main Menu Screen -----------------------------------------------------------------}

type pmenu = ^tmenu;
     tmenu = object(tmenuscreen)
       p:array[0..30] of tshapesinmotion;
       f:pstickman;
       constructor init(drawbmp:bmp; wnd:pwindow);
       destructor done; virtual;
       procedure draw; virtual;
     end;


{- Players Screen -------------------------------------------------------------------}

type pplayers = ^tplayers;
     tplayers = object(tscreen)
     end;


{- Score Screen ---------------------------------------------------------------------}

type pscorescreen = ^tscorescreen;
     tscorescreen = object(tscreen)
       scores:pscores;
       constructor init(drawbmp:bmp; wnd:pwindow; thescores:pscores);
       function canpause: boolean; virtual;
       procedure draw; virtual;
     end;


{- About the Game Screen ------------------------------------------------------------}

type pabout = ^tabout;
     tabout = object(tscreen)
     end;

{- Game Screen ----------------------------------------------------------------------}

type pgamescreen = ^tgamescreen;
     tgamescreen = object(tscreen)
     end;

implementation

{- Generic Screen -------------------------------------------------------------------}

constructor tscreen.init(drawbmp:bmp; wnd:pwindow);
  begin
    usebmp := drawbmp;
    window := wnd;
    setfont(usebmp,usefont);
    paused := false;
    needsrepaint := false;
    istrashed := true;
    resettime;
  end;

destructor tscreen.done;
  begin
  end;

procedure tscreen.update;
  begin
    if paused then
      begin
        needsrepaint := false;
        {setbrush(usebmp,color[7],color[-1],udlines);}
        setpen(usebmp,color[15],solid,3);
        setbrush(usebmp,color[-1],color[-1],solid);
        box(usebmp,0,0,640,480,0,0);
        setfont(usebmp,usefont);
        quickfont(usefont,stencil,175);
        usefont.angle := arctan(480/640)/pi*180;
        usefont.fcolor := color[4];
        print(usebmp,55,332,'PAUSED');
      end
    else
      draw;
  end;

procedure tscreen.drawfps;
  var framerate:string;
  begin
    if (fpsdata.frametime[fpsdata.noframes]=-1) or not needsrepaint then
      framerate:='-'
    else
      str(fpsinterval/(elapsed-fpsdata.frametime[fpsdata.noframes])*1000:0:3,framerate);

    fpsdata.frametime[fpsdata.noframes] := elapsed;
    inc(fpsdata.noframes);
    if fpsdata.noframes > fpsinterval then fpsdata.noframes := 1;

    setfont(usebmp,usefont);
    quickfont(usefont,arial,30);
    usefont.fcolor := color[15];
    usefont.weight := 700;
    print(usebmp,10,10,framerate+fpslabel);
  end;

function tscreen.canpause:boolean;
  begin
    canpause := true;
  end;

procedure tscreen.pause;
  begin
    paused := true;
    settime;
  end;

procedure tscreen.unpause;
  begin
    paused := false;
    difference := gettickcount-elapsed;
    istrashed := true;
  end;

procedure tscreen.mousedown(var msg:tmessage);
  begin
  end;

procedure tscreen.mouseup(var msg:tmessage);
  begin
  end;

procedure tscreen.mousemove(var msg:tmessage);
  begin
  end;

procedure tscreen.keydown(var msg:tmessage);
  begin
  end;

procedure tscreen.keyup  (var msg:tmessage);
  begin
  end;

procedure tscreen.chartype(var msg:tmessage);
  begin
  end;

procedure tscreen.timertick(var msg:tmessage);
  begin
  end;

procedure tscreen.resettime;
  var i: integer;
  begin
    { reset timer }
    elapsed := 0;
    difference := gettickcount;

    { reset fps display }
    fpsdata.noframes := 1;
    for i := 1 to fpsinterval do
      fpsdata.frametime[i] := -1;

  end;

procedure tscreen.settime;
  begin
    elapsed := gettickcount - difference;
  end;

procedure tscreen.draw;
  begin
    setpen(usebmp,color[0],solid,0);
    setbrush(usebmp,color[0],color[0],solid);
    box(usebmp,0,0,640,480,0,0);
  end;

procedure tscreen.windowmenu(id:word);
  begin
    postmessage(window^.hwindow,wm_command,id,0);
  end;

{- Generic Menu ---------------------------------------------------------------------}

type pcontrol = ^tcontrol;
     tcontrol = object(tobject)
       area:hrgn;
       mouseover,activated,visible:boolean;
       constructor init;
       destructor done; virtual;
     end;

constructor tcontrol.init;
  begin
  end;

destructor tcontrol.done;
  begin
  end;

constructor tmenuscreen.init(drawbmp:bmp; wnd:pwindow; gamescreen:prect);
  begin
    tscreen.init(drawbmp, wnd);
  end;

procedure tmenuscreen.pconvert(var point:tpoint);
  begin
  end;

procedure tmenuscreen.drawback; 
  begin
    setpen(usebmp,color[15],solid,3);
    setbrush(usebmp,color[0],color[0],solid);
    box(usebmp,0,0,640,480,0,0);
  end;

procedure tmenuscreen.draw; 
  begin
  end;






{- Intro Screen ---------------------------------------------------------------------}

constructor tintro.init(drawbmp:bmp; wnd:pwindow);
  begin
    tscreen.init(drawbmp, wnd);
    randomize;

    settimer(window^.hwindow,0,blinkrate,nil);

    f:=new(pstickman,init(320,300,1,1.5,color[9],0,false,'Intro Guy'));
    sticktitle := loadbmp(getappdir(hinstance)+'\stick.bmp');

    age := ip_nothingness;
    nextage;
   end;

destructor tintro.done;
  begin
    dispose(f,done);
    killbmp(sticktitle);
    tscreen.done;
  end;

procedure tintro.nextage;
  var i:integer;
  begin
    inc(age);
    istrashed := true;
    case age of
      ip_bigbang:
        begin
          f^.setpoints(0);
          for i:=0 to 30 do
            begin
              p[i].x10 := random;
              p[i].y10 := random;
              p[i].x20 := random;
              p[i].y20 := random;
              p[i].x1v := random*(maxvelocity-minvelocity)+minvelocity;
              p[i].y1v := random*(maxvelocity-minvelocity)+minvelocity;
              p[i].x2v := random*(maxvelocity-minvelocity)+minvelocity;
              p[i].y2v := random*(maxvelocity-minvelocity)+minvelocity;
            end;
        end;
      ip_evolution:
        begin
          killtimer(window^.hwindow,0);
          blinkon := false;
          for i := 0 to 30 do
            begin
              p[i].x10 := f^.pt[i].x1;
              p[i].y10 := f^.pt[i].y1;
              p[i].x20 := f^.pt[i].x2;
              p[i].y20 := f^.pt[i].y2;
            end;
          f^.setpoints(0);
          for i := 0 to 30 do
            begin
              p[i].x1v := f^.pt[i].x1;
              p[i].y1v := f^.pt[i].y1;
              p[i].x2v := f^.pt[i].x2;
              p[i].y2v := f^.pt[i].y2;
            end;
         end;
      ip_ultimatewarrior:
        begin
          f^.setpoints(0);
        end;
      else
        windowmenu(menu_mainmenu);
      end;
    resettime;
  end;

procedure tintro.chartype(var msg:tmessage);
  var i:integer;
  begin
    nextage;
  end;

procedure tintro.mousedown(var msg:tmessage);
  begin
    nextage;
  end;

procedure tintro.timertick(var msg:tmessage);
  begin
    blinkon := not blinkon;
  end;

procedure tintro.draw;
  var i:integer;
  begin
    needsrepaint := true;
    settime;

    case age of
    ip_bigbang:
      begin
        tscreen.draw;
        for i := 0 to 30 do
          begin
            f^.pt[i].x1 := round(bounce(elapsed,0,640,p[i].x1v,p[i].x10));
            f^.pt[i].y1 := round(bounce(elapsed,0,480,p[i].y1v,p[i].y10));
            f^.pt[i].x2 := round(bounce(elapsed,0,640,p[i].x2v,p[i].x20));
            f^.pt[i].y2 := round(bounce(elapsed,0,480,p[i].y2v,p[i].y20));
          end;
        f^.draw(usebmp);
      end;
    ip_evolution:
      begin
        tscreen.draw;
        for i := 0 to 30 do
          begin
            f^.pt[i].x1 := round(descendupon(elapsed,etime,p[i].x10,p[i].x1v));
            f^.pt[i].y1 := round(descendupon(elapsed,etime,p[i].y10,p[i].y1v));
            f^.pt[i].x2 := round(descendupon(elapsed,etime,p[i].x20,p[i].x2v));
            f^.pt[i].y2 := round(descendupon(elapsed,etime,p[i].y20,p[i].y2v));
          end;
        f^.draw(usebmp);
        if elapsed>etime then nextage;
      end;
    ip_ultimatewarrior:
      begin
        if istrashed then
          begin
            tscreen.draw;
            copybmp(sticktitle,usebmp,32,320);
            istrashed := false;
          end
        else
          begin
            setbrush(usebmp,color[0],color[0],solid);
            setpen(usebmp,color[-1],solid,0);
            box(usebmp,0,0,640,318,0,0);
          end;
        f^.setpoints(elapsed);
        f^.draw(usebmp);
      end;
    end;

    if blinkon then
      begin
        setfont(usebmp,usefont);
        quickfont(usefont,verdana,30);
        usefont.fcolor := color[15];
        usefont.halign := ta_center;
        print(usebmp,320,400,blinktext);
      end;
  end;

{- Main Menu ------------------------------------------------------------------------}

constructor tmenu.init(drawbmp:bmp; wnd:pwindow);
  var i:integer;
  begin
    tscreen.init(drawbmp, wnd);
    randomize;
    f:=new(pstickman,init(320,300,1,1.5,color[9],0,false,'Intro Guy'));

    f^.setpoints(0);
    for i:=0 to 30 do
      begin
        p[i].x10 := random;
        p[i].y10 := random;
        p[i].x20 := random;
        p[i].y20 := random;
        p[i].x1v := random*(maxvelocity-minvelocity)+minvelocity;
        p[i].y1v := random*(maxvelocity-minvelocity)+minvelocity;
        p[i].x2v := random*(maxvelocity-minvelocity)+minvelocity;
        p[i].y2v := random*(maxvelocity-minvelocity)+minvelocity;
      end;
   end;

destructor tmenu.done;
  begin
    dispose(f,done);
    tscreen.done;
  end;

procedure tmenu.draw;
  var i:integer;
  begin
    needsrepaint := true;
    settime;
    tscreen.draw;
    for i := 0 to 30 do
      begin
        f^.pt[i].x1 := round(bounce(elapsed,0,640,p[i].x1v,p[i].x10));
        f^.pt[i].y1 := round(bounce(elapsed,0,480,p[i].y1v,p[i].y10));
        f^.pt[i].x2 := round(bounce(elapsed,0,640,p[i].x2v,p[i].x20));
        f^.pt[i].y2 := round(bounce(elapsed,0,480,p[i].y2v,p[i].y20));
      end;
    f^.draw(usebmp);
    setpen(usebmp,color[7],solid,0);
    setbrush(usebmp,color[0],color[0],solid);
    box(usebmp,150,50,490,430,0,0);

    quickfont(usefont,comic,-40);
    usefont.weight := 500;
    usefont.fcolor := color[15];
    usefont.halign := ta_center;
    setfont(usebmp,usefont);
    print(usebmp,320,60,'Main Menu');
    setpen(usebmp,color[9],solid,2);
    i := gettextwidth(usebmp,'Main Menu');
    line(usebmp,320-i div 2,110,320+i div 2,110);

  end;


{- Score Screen ---------------------------------------------------------------------}

constructor tscorescreen.init(drawbmp:bmp; wnd:pwindow; thescores:pscores);
  begin
    tscreen.init(drawbmp,wnd);
    scores := thescores;
  end;

function tscorescreen.canpause: boolean;
  begin
    canpause := false;
  end;

procedure tscorescreen.draw;
var i,j,mx:integer;
    temp:string;
  begin
    tscreen.draw;
    setpen(usebmp,color[0],solid,0);
    setbrush(usebmp,0,0,solid);
    box(usebmp,0,0,640,480,0,0);
    quickfont(usefont,comic,40);
    usefont.fcolor := color[15];
    usefont.weight := 500;
    usefont.halign := ta_center;
    print(usebmp,320,30,'High Scores');

    quickfont(usefont,comic,20);
    usefont.fcolor := color[15];
    scores^.sort;
    mx:=scores^.data[1].score + 1;

    for i := 1 to 10 do
      with scores^.data[i] do
        if alive then  
          begin
            for j := 20 to round(530*score/mx)+20 do
              begin
                setpen(usebmp,gradient(rgb(226,45,0),rgb(251,195,67),j,621),0,1);
                line(usebmp,j,75+i*35,j,95+i*35)
               end;
            usefont.halign := ta_center;
            print(usebmp,44,73+i*35,name);
            str(score,temp);
            usefont.halign := ta_right;
            print(usebmp,610,73+i*35,temp);
          end;
  end;

{- Game Screen ----------------------------------------------------------------------}

{ game   if fposition.dying^.getval(time) then
      begin
        f := getfont(drawbmp);
        quickfont(f^,'Comic Sans MS',30);
        f^.halign := ta_center;
        f^.fcolor := color[15];
        print(drawbmp,320,60,fproperties.name+' is dead!!');
      end
    else

 }

begin

end.

