unit screens;
interface
{$B-}

uses wintypes,wobjects,easygdi,game,win31,easycrt,winprocs,fighters,sprocs;

var debug: text;

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
const minmovetime = 50;
const maxmovetime = 500;
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

type pscontrol = ^tscontrol;
     tscontrol = object(tobject)
       menu: pscreen;
       area:hrgn;
       moused,activated,visible:boolean;
       wantsinput:boolean;
       constructor init(parentmenu: pscreen);
       destructor done; virtual;
       procedure activate; virtual;
       procedure deactivate; virtual;
       procedure setbounds; virtual;
       procedure invalidate; virtual;
       procedure paint; virtual;
       procedure erase; virtual;

       { external input }
       procedure mousedown(var msg:tmessage); virtual;
       procedure mouseup(var msg:tmessage); virtual;
       procedure mousemove(var msg:tmessage); virtual;
       procedure keydown(var msg:tmessage); virtual;
       procedure keyup  (var msg:tmessage); virtual;
       procedure chartype(var msg:tmessage); virtual;
       procedure timertick(var msg:tmessage); virtual;
     end;

type pmenuscreen = ^tmenuscreen;
     tmenuscreen = object(tscreen)
       controls:pcollection;
       gamerect:prect;
       selected,activated:pscontrol;
       bgcolor: longint;
       constructor init(drawbmp:bmp; wnd:pwindow; gamescreen:prect);
       destructor done; virtual;
       procedure screenpoint(var point:tpoint); virtual;
       procedure windowpoint(var point:tpoint); virtual;
       function getcontrol(x,y:integer):pscontrol; virtual;
       procedure selectcontrol(control:pscontrol); virtual;
       procedure activatecontrol(control:pscontrol); virtual;
       procedure nextcontrol; virtual;
       procedure prevcontrol; virtual;
       procedure draw; virtual;
       procedure drawback; virtual;
       procedure mousedown(var msg:tmessage); virtual;
       procedure mouseup(var msg:tmessage); virtual;
       procedure mousemove(var msg:tmessage); virtual;
       procedure keydown(var msg:tmessage); virtual;
       procedure keyup  (var msg:tmessage); virtual;
       procedure chartype(var msg:tmessage); virtual;
       procedure timertick(var msg:tmessage); virtual;

     end;


{- Main Menu Screen -----------------------------------------------------------------}

type pmenu = ^tmenu;
     tmenu = object(tmenuscreen)
       p:array[0..30] of tshapesinmotion;
       f:pstickman;
       constructor init(drawbmp:bmp; wnd:pwindow; gamescreen:prect);
       destructor done; virtual;
       procedure drawback; virtual;
       procedure mousemove(var msg:tmessage); virtual;
     end;


{- Players Screen -------------------------------------------------------------------}

type pplayers = ^tplayers;
     tplayers = object(tmenuscreen)
     game:pgame;
     selectedplayer:pointer;
     playerbox:pscontrol;
     constructor init(drawbmp:bmp; wnd:pwindow; gamescreen:prect; agame:pgame);
     procedure drawback; virtual;
     procedure playerscreen(x:word); virtual;
     function canpause:boolean; virtual;
     end;

{- Player Modification Screen -------------------------------------------------------}

type pplayer = ^tplayer;
     tplayer = object(tmenuscreen)
     fighter:pgenf;
     constructor init(drawbmp:bmp; wnd:pwindow; gamescreen:prect; afighter:pgenf);
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
  var i:integer;
  begin
    usebmp := drawbmp;
    window := wnd;
    setfont(usebmp,usefont);
    paused := false;
    needsrepaint := false;
    istrashed := true;
    resettime;

    { reset fps display }
    fpsdata.noframes := 1;
    for i := 1 to fpsinterval do
      fpsdata.frametime[i] := -1;

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
      str(fpsinterval/(elapsed+difference-fpsdata.frametime[fpsdata.noframes])*1000:0:3,framerate);

    fpsdata.frametime[fpsdata.noframes] := elapsed+difference;
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
  begin
    { reset timer }
    elapsed := 0;
    difference := gettickcount;
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

{- Intro Screen ---------------------------------------------------------------------}

constructor tintro.init(drawbmp:bmp; wnd:pwindow);
  begin
    tscreen.init(drawbmp, wnd);
    randomize;

    f:=new(pstickman,init(320,300,1,150,color[9],0,false,'Intro Guy'));
    sticktitle := loadbmp(getappdir(hinstance)+'\stick.bmp');

    age := ip_nothingness;
    nextage;
   end;

destructor tintro.done;
  begin
    killtimer(window^.hwindow,0);
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
          settimer(window^.hwindow,0,blinkrate,nil);
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
          settimer(window^.hwindow,0,minmovetime+random(maxmovetime-minmovetime),nil);
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

    case age of
    ip_bigbang:
      blinkon := not blinkon;
    ip_ultimatewarrior:
      begin
        killtimer(window^.hwindow,0);
        settimer(window^.hwindow,0,minmovetime+random(maxmovetime-minmovetime),nil);
        settime;
        case random(7) of
        0: f^.jump(elapsed);
        1: f^.punch(elapsed);
        2: f^.kick(elapsed);
        3: f^.walkr(elapsed);
        4: f^.walkl(elapsed);
        5: f^.duck(elapsed);
        6: f^.stopduck(elapsed);
        end;
      end;
    end;
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

{- Generic Menu ---------------------------------------------------------------------}

constructor tscontrol.init(parentmenu: pscreen);
  begin
    menu := parentmenu;
    visible := true;
    moused := false;
    activated := false;
    wantsinput := false;
  end;

destructor tscontrol.done;
  begin
  end;

procedure tscontrol.activate;
  begin
  end;

procedure tscontrol.deactivate;
  begin
  end;

procedure tscontrol.setbounds;
  begin
  end;

procedure tscontrol.invalidate;
  begin
    invalidatergn(menu^.window^.hwindow,area,false);
  end;

procedure tscontrol.paint;
  begin
  end;

procedure tscontrol.erase;
  begin
  end;

{ external input }
procedure tscontrol.mousedown(var msg:tmessage);
  begin
  end;

procedure tscontrol.mouseup(var msg:tmessage);
  begin
  end;

procedure tscontrol.mousemove(var msg:tmessage);
  begin
  end;

procedure tscontrol.keydown(var msg:tmessage);
  begin
  end;

procedure tscontrol.keyup  (var msg:tmessage);
  begin
  end;

procedure tscontrol.chartype(var msg:tmessage);
  begin
  end;

procedure tscontrol.timertick(var msg:tmessage);
  begin
  end;

type ptextproperties = ^ttextproperties;
     ttextproperties = record
       x,y:integer;
       rect:trect;
       text:string;
       normal,mouse,active:tsavebmp;
     end;

type TBRect = record
       left,top,right,bottom: boolean;
     end;

type ptextcontrol = ^ttextcontrol;
     ttextcontrol = object(tscontrol)
       props: ttextproperties;
       autorect: tbrect;
       constructor init(parentmenu:pmenuscreen; var textproperties: ttextproperties);
       procedure setbounds; virtual;
       procedure paint; virtual;
       procedure erase; virtual;
     end;

constructor ttextcontrol.init(parentmenu:pmenuscreen; var textproperties: ttextproperties);
  begin
    tscontrol.init(parentmenu);
    props := textproperties;
    if props.rect.left   = -1 then autorect.left   := true else autorect.left   := false;
    if props.rect.right  = -1 then autorect.right  := true else autorect.right  := false;
    if props.rect.top    = -1 then autorect.top    := true else autorect.top    := false;
    if props.rect.bottom = -1 then autorect.bottom := true else autorect.bottom := false;
  end;

procedure ttextcontrol.setbounds;
  var p1,p2:tpoint;
  begin
    if activated then
      setbmp(menu^.usebmp,props.active)
    else if moused then
      setbmp(menu^.usebmp,props.mouse)
    else
      setbmp(menu^.usebmp,props.normal);

    if autorect.left   then props.rect.left   := props.x +
                                                 gettextoffsetx(menu^.usebmp,props.text);
    if autorect.right  then props.rect.right  := props.x +
                                                 gettextoffsetx(menu^.usebmp,props.text) +
                                                 gettextwidth(menu^.usebmp,props.text);
    if autorect.top    then props.rect.top    := props.y + gettextoffsety(menu^.usebmp);
    if autorect.bottom then props.rect.bottom := props.y + gettextoffsety(menu^.usebmp) +
                                                 gettextheight(menu^.usebmp,props.text);
    p1.x := props.rect.left; p1.y := props.rect.top;
    p2.x := props.rect.right; p2.y := props.rect.bottom;
    pmenuscreen(menu)^.windowpoint(p1);
    pmenuscreen(menu)^.windowpoint(p2);
    deleteobject(area);
    area := CreateRectRgn(p1.x,p1.y,p2.x,p2.y);
  end;

procedure ttextcontrol.paint;
  begin
    setbounds;
    box(menu^.usebmp,props.rect.left,props.rect.top,props.rect.right,props.rect.bottom,0,0);
    print(menu^.usebmp,props.x,props.y,props.text);
  end;

procedure ttextcontrol.erase;
  begin
    setbounds;
    setpen(menu^.usebmp,pmenuscreen(menu)^.bgcolor,solid,0);
    setbrush(menu^.usebmp,pmenuscreen(menu)^.bgcolor,pmenuscreen(menu)^.bgcolor,solid);
    box(menu^.usebmp,props.rect.left,props.rect.top,props.rect.right,props.rect.bottom,0,0);
  end;

constructor tmenuscreen.init(drawbmp:bmp; wnd:pwindow; gamescreen:prect);
  begin
    tscreen.init(drawbmp, wnd);
    gamerect := gamescreen;
    controls := new(pcollection,init(0,1));
    selected := nil;
    activated := nil;
    bgcolor := color[0];
  end;

destructor tmenuscreen.done;
  begin
    dispose(controls,done);
    tscreen.done;
  end;

procedure tmenuscreen.screenpoint(var point:tpoint);
  begin
    point.x := round((point.x-gamerect^.left)/(gamerect^.right -gamerect^.left)*640);
    point.y := round((point.y-gamerect^.top )/(gamerect^.bottom-gamerect^.top)*480);
  end;

procedure tmenuscreen.windowpoint(var point:tpoint);
  begin
    point.x := gamerect^.left + round((point.x)/640*(gamerect^.right-gamerect^.left));
    point.y := gamerect^.top  + round((point.y)/480*(gamerect^.bottom-gamerect^.top));
  end;

function tmenuscreen.getcontrol(x,y:integer):pscontrol;
  var i:integer;
      c:pscontrol;
  begin
    getcontrol := nil;
    for i := 0 to controls^.count-1 do
      begin
        c := controls^.at(i);
        if ptinregion(c^.area,x,y) then getcontrol := c;
      end;
  end;

procedure tmenuscreen.selectcontrol(control:pscontrol);
  begin
    if selected <> nil then
      begin
        selected^.erase;
        selected^.invalidate;
        selected^.moused := false;
        selected^.paint;
        selected^.invalidate;
      end;
    selected := control;
    if selected<>nil then
      begin
        selected^.erase;
        selected^.invalidate;
        selected^.moused := true;
        selected^.paint;
        selected^.invalidate;
      end;
  end;

procedure tmenuscreen.activatecontrol(control:pscontrol);
  begin
    if activated <> nil then
      begin
        activated^.deactivate;
        activated^.erase;
        activated^.invalidate;
        activated^.activated := false;
        activated^.paint;
        activated^.invalidate;
      end;
    activated := control;
    if activated<>nil then
      begin
        activated^.erase;
        activated^.invalidate;
        activated^.activated := true;
        activated^.paint;
        activated^.invalidate;
        activated^.activate;
      end;
  end;

procedure tmenuscreen.nextcontrol;
  var n:integer;
  begin
    n := controls^.indexof(selected);
    inc(n);
    if n>=controls^.count then n := 0;
    selectcontrol(controls^.at(n));
  end;

procedure tmenuscreen.prevcontrol;
  var n:integer;
  begin
    n := controls^.indexof(selected);
    dec(n);
    if n<0 then n := controls^.count-1;
    selectcontrol(controls^.at(n));
  end;

procedure tmenuscreen.drawback;
  begin
    setpen(usebmp,color[0],solid,0);
    setbrush(usebmp,color[0],color[0],solid);
    box(usebmp,0,0,640,480,0,0);
  end;

procedure tmenuscreen.draw; 
  var i: integer;
  c: pscontrol;
  begin
    drawback;
    for i := 0 to controls^.count-1 do
      begin
        c := controls^.at(i);
        c^.paint;
      end;
  end;


procedure tmenuscreen.mousedown(var msg:tmessage);
  var new:pscontrol;
  begin
    new := getcontrol(msg.lparamlo,msg.lparamhi);
    if new<>nil then
      if new^.wantsinput then new^.mousedown(msg);

    selectcontrol(new);
    activated := new;
    if new <> nil then
      begin
        activated := new;
        new^.activate;
      end;
  end;

procedure tmenuscreen.mouseup(var msg:tmessage);
  var new:pscontrol;
  begin
    new := getcontrol(msg.lparamlo,msg.lparamhi);
    if new<>nil then
      if new^.wantsinput then new^.mouseup(msg);
  end;

procedure tmenuscreen.mousemove(var msg:tmessage);
  var new:pscontrol;
  begin
    new := getcontrol(msg.lparamlo,msg.lparamhi);
    if new<>nil then
      if new^.wantsinput then new^.mousemove(msg);

    new := getcontrol(msg.lparamlo,msg.lparamhi);
    selectcontrol(new);
  end;

procedure tmenuscreen.keydown(var msg:tmessage);
  begin
    if (activated<>nil) and (activated^.wantsinput) and (selected=activated) then
      activated^.keydown(msg)
    else
      case msg.wparam of
      vk_down:nextcontrol;
      vk_up:prevcontrol;
      end;
  end;

procedure tmenuscreen.keyup(var msg:tmessage);
  begin
    if (activated<>nil) and (activated^.wantsinput) and (selected=activated) then
      activated^.keydown(msg);
  end;

procedure tmenuscreen.chartype(var msg:tmessage);
  var s:integer;
  begin
    s := getkeystate(vk_shift);
    case msg.wparam of
      9: if s<0 then prevcontrol else nextcontrol;
    end;

    if (activated<>nil) and (activated^.wantsinput) and (selected=activated) then
      activated^.keydown(msg)
    else
      case msg.wparam of
        13: activatecontrol(selected);
      end;
  end;

procedure tmenuscreen.timertick(var msg:tmessage);
  begin
  end;

{- Main Menu ------------------------------------------------------------------------}

type pcnewgame = ^cnewgame;
     cnewgame = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cnewgame.activate;
  begin
    menu^.windowmenu(menu_newgame);
  end;

type pcloadgame = ^cloadgame;
     cloadgame = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cloadgame.activate;
  begin
    menu^.windowmenu(menu_opengame);
  end;

type pcsavegame = ^csavegame;
     csavegame = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure csavegame.activate;
  begin
    menu^.windowmenu(menu_savegame);
  end;

type pcplayers = ^cplayers;
     cplayers = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cplayers.activate;
  begin
    menu^.windowmenu(menu_players);
  end;

type pchighscores = ^chighscores;
     chighscores = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure chighscores.activate;
  begin
    menu^.windowmenu(menu_highscores);
  end;

type pcabout = ^cabout;
     cabout = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cabout.activate;
  begin
    menu^.windowmenu(menu_aboutgame);
  end;

type pcexit = ^cexit;
     cexit = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cexit.activate;
  begin
    menu^.windowmenu(menu_exitgame);
  end;

constructor tmenu.init(drawbmp:bmp; wnd:pwindow; gamescreen:prect);
  var i:integer;
      pr:ttextproperties;
  begin
    tmenuscreen.init(drawbmp, wnd, gamescreen);
    randomize;
    f:=new(pstickman,init(320,300,1,150,color[9],0,false,'Intro Guy'));

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

    quickfont(pr.normal.rfont,comic,-30);
    pr.normal.rfont.fcolor := color[7];
    pr.normal.rfont.halign := ta_center;

    pr.normal.pencolor    := color[-1];
    pr.normal.penwidth    := 0;
    pr.normal.penstyle    := solid;
    pr.normal.brushcolor1 := color[-1];
    pr.normal.brushcolor2 := color[-1];
    pr.normal.brushstyle  := solid;

    pr.mouse := pr.normal;

    quickfont(pr.mouse.rfont,comic,-34);
    pr.mouse.rfont.fcolor := color[15];
    pr.mouse.rfont.halign := ta_center;

    pr.active := pr.mouse;

    pr.rect.left   := -1;
    pr.rect.top    := -1;
    pr.rect.right  := -1;
    pr.rect.bottom := -1;

    pr.x := 320;

    pr.text := 'New Game';
    pr.y := 80+1*41;
    controls^.insert(new(pcnewgame,init(@self,pr)));

    pr.text := 'Load Game';
    pr.y := 80+2*41;
    controls^.insert(new(pcloadgame,init(@self,pr)));

    pr.text := 'Save Game';
    pr.y := 80+3*41;
    controls^.insert(new(pcsavegame,init(@self,pr)));

    pr.text := 'Players';
    pr.y := 80+4*41;
    controls^.insert(new(pcplayers,init(@self,pr)));

    pr.text := 'High Scores';
    pr.y := 80+5*41;
    controls^.insert(new(pchighscores,init(@self,pr)));

    pr.text := 'About the Game';
    pr.y := 80+6*41;
    controls^.insert(new(pcabout,init(@self,pr)));

    pr.text := 'Exit';
    pr.y := 80+7*41;
    controls^.insert(new(pcexit,init(@self,pr)));

   end;

destructor tmenu.done;
  begin
    dispose(f,done);
    tscreen.done;
  end;

procedure tmenu.drawback;
  var i:integer;
  begin
    tmenuscreen.drawback;
    needsrepaint := true;
    settime;
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

procedure tmenu.mousemove(var msg:tmessage);
  begin
    tmenuscreen.mousemove(msg);
  end;


{- Players Screen -------------------------------------------------------------------}

type pcaddnewplayer = ^caddnewplayer;
     caddnewplayer = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure caddnewplayer.activate;
  begin
    pplayers(menu)^.game^.insert(new(pstickman,init(200,350,1,gamepinm,color[0],50,True,'New Player')));
    pplayers(menu)^.playerscreen(pplayers(menu)^.game^.count);
  end;

type pcmodifyplayer = ^cmodifyplayer;
     cmodifyplayer = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cmodifyplayer.activate;
  begin
    pplayers(menu)^.playerscreen(0);
  end;

type pcdeleteplayer = ^cdeleteplayer;
     cdeleteplayer = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cdeleteplayer.activate;
  begin
  end;

type pcmainmenu = ^cmainmenu;
     cmainmenu = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cmainmenu.activate;
  begin
    menu^.windowmenu(menu_mainmenu);
  end;

type pcgamescreen = ^cgamescreen;
     cgamescreen = object(ttextcontrol)
     procedure activate; virtual;
     end;

procedure cgamescreen.activate;
  begin
    menu^.windowmenu(menu_rungame);
  end;

type pcplayerlist = ^cplayerlist;
     cplayerlist = object(tscontrol)
       box: trect;
       constructor init(parentmenu: pscreen; x,y,width,height:integer);
       procedure activate; virtual;
       procedure setbounds; virtual;
       procedure paint; virtual;

       { external input }
       procedure mousedown(var msg:tmessage); virtual;
       procedure keydown(var msg:tmessage); virtual;
       procedure chartype(var msg:tmessage); virtual;
     end;

constructor cplayerlist.init(parentmenu: pscreen; x,y,width,height:integer);
  begin
    box.left   := x;
    box.right  := x+width;
    box.top    := y;
    box.bottom := y+height;
    setbounds;
  end;

procedure cplayerlist.activate;
  begin
    tscontrol.activate;
  end;

procedure cplayerlist.setbounds;
  begin
    deleteobject(area);
    area := CreateRectRgn(box.left,box.top,box.right,box.bottom);
  end;

procedure cplayerlist.paint;
  var i:integer;
  begin
{    tscontrol.paint;
    circle(menu^.usebmp,(box.left+box.right)div 2,(box.top+box.bottom)div 2,
          (box.right-box.left)div 2,(box.bottom-box.top)div 2);
    for i := 1 to pplayers(menu)^.game^.count do
      begin

      end;}
  end;

procedure cplayerlist.mousedown(var msg:tmessage);
  begin
  end;

procedure cplayerlist.keydown(var msg:tmessage);
  begin
  end;

procedure cplayerlist.chartype(var msg:tmessage);
  begin
  end;

constructor tplayers.init(drawbmp:bmp; wnd:pwindow; gamescreen:prect; agame:pgame);
  var pr:ttextproperties;
  begin
    tmenuscreen.init(drawbmp,wnd,gamescreen);
    game := agame;
    selectedplayer := nil;

    playerbox := new(pcplayerlist);
    controls^.insert(playerbox);

    quickfont(pr.normal.rfont,comic,-18);
    pr.normal.rfont.fcolor := color[7];
    pr.normal.rfont.halign := ta_center;

    pr.normal.pencolor    := color[-1];
    pr.normal.penwidth    := 0;
    pr.normal.penstyle    := solid;
    pr.normal.brushcolor1 := color[-1];
    pr.normal.brushcolor2 := color[-1];
    pr.normal.brushstyle  := solid;

    pr.mouse := pr.normal;
    pr.mouse.rfont.fcolor := color[15];
    pr.active := pr.mouse;

    pr.rect.left   := -1;
    pr.rect.top    := -1;
    pr.rect.right  := -1;
    pr.rect.bottom := -1;

    pr.x := 320;

    pr.text := 'Add New Player';
    pr.y := 320+1*25;
    controls^.insert(new(pcaddnewplayer,init(@self,pr)));

    pr.text := 'Modify Player';
    pr.y := 320+2*25;
    controls^.insert(new(pcmodifyplayer,init(@self,pr)));

    pr.text := 'Delete Player';
    pr.y := 320+3*25;
    controls^.insert(new(pcdeleteplayer,init(@self,pr)));

    pr.text := 'Main Menu';
    pr.y := 320+4*25;
    controls^.insert(new(pcmainmenu,init(@self,pr)));

    pr.text := 'Go to Game';
    pr.y := 320+5*25;
    controls^.insert(new(pcgamescreen,init(@self,pr)));

  end;

procedure tplayers.drawback;
  begin
    tmenuscreen.drawback;

    setfont(usebmp,usefont);

    quickfont(usefont,comic,-40);
    usefont.fcolor := color[15];
    usefont.halign := ta_center;

    print(usebmp,320,30,'Choose a Player');

    quickfont(usefont,comic,-20);
    usefont.fcolor := color[15];
    print(usebmp,20,90,'#');
    print(usebmp,50,90,'Name');
    print(usebmp,390,90,'Color');
    print(usebmp,460,90,'Type');
    print(usebmp,560,90,'Score');

    setpen(usebmp,rgb(255,0,0),solid,0);
    line(usebmp,20,115,620,115);
    line(usebmp,20,130+10*20,620,130+10*20);
  end;

function tplayers.canpause:boolean;
  begin
    canpause := false;
  end;

procedure tplayers.playerscreen(x:word);
  begin
    postmessage(window^.hwindow,wm_player,x,0);
  end;

{- Player Modification Screen -------------------------------------------------------}

constructor tplayer.init(drawbmp:bmp; wnd:pwindow; gamescreen:prect; afighter:pgenf);
  begin
    fighter := afighter;
    tmenuscreen.init(drawbmp,wnd,gamescreen);
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


var SaveExit:Tfarproc;
procedure exitdebug; far;
begin
  ExitProc := SaveExit;
  close(debug);
end;

begin
  SaveExit := ExitProc;
  ExitProc := @Exitdebug;

  assign(debug,'c:\russ\sht4brns.txt');
  rewrite(debug);
end.