unit swindow;

interface

uses wobjects,easygdi,wintypes,screens,winprocs,win31,fighters,game,sprocs;

{$R stick.res}

const resetscores = false;

type psfwindow = ^tsfwindow;
     tsfwindow = object(twindow)

       { resources }
       buffer,tile:bmp;
       scores: tscores;
       screen:pscreen;
       game: pgame;

       { state variables }
       fullscreen,endisnear,showfps,hasmenu,menuopen: boolean;
       gamerect: trect;

       { initialization routines }
       constructor init(AParent: PWindowsObject; ATitle: PChar);
       procedure GetWindowClass( var WC: TWndClass); virtual;
       procedure SetupWindow; virtual;

       { game functions }
       procedure pause; virtual;
       procedure unpause; virtual;
       procedure newgame; virtual;
       procedure opengame;virtual;
       procedure savegame;virtual;
       procedure repaint; virtual;
       procedure resize; virtual;
       procedure showmenu; virtual;
       procedure hidemenu; virtual;
       procedure fullsize; virtual;
       procedure windowsize; virtual;
       procedure swapfps; virtual;
       procedure runintro; virtual;
       procedure runmenu; virtual;
       procedure runplayers; virtual;
       procedure runplayer(n:integer); virtual;
       procedure runscores; virtual;
       procedure runabout; virtual;
       procedure rungame; virtual;

       { window messages }
       procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
       procedure WMsize(var Msg: Tmessage); virtual wm_First + wm_size;
       procedure wmncmousemove(var Msg: Tmessage); virtual wm_First + WM_NCMOUSEMOVE;
       procedure wminitmenu(var Msg: Tmessage); virtual wm_First + WM_INITMENU;
       procedure wmENTERMENULOOP(var Msg: Tmessage); virtual wm_First + WM_ENTERMENULOOP;
       procedure wmEXITMENULOOP(var Msg: Tmessage); virtual wm_First + WM_EXITMENULOOP;
       procedure wmkillfocus(var Msg: Tmessage); virtual wm_First + wm_killfocus;
       procedure wmnchittest(var Msg: Tmessage); virtual wm_First + wm_nchittest;
       procedure WMERASEBKGND(var Msg:Tmessage); virtual wm_First+ WM_ERASEBKGND;

       { menu response }
       procedure menunewgame(var Msg:Tmessage); virtual cm_First + menu_newgame;
       procedure menusavegame(var Msg:Tmessage); virtual cm_First + menu_savegame;
       procedure menuopengame(var Msg:Tmessage); virtual cm_First + menu_opengame;
       procedure menuquit(var Msg:Tmessage); virtual cm_First + menu_exitgame;
       procedure menupause(var Msg:Tmessage); virtual cm_First + menu_pausegame;
       procedure menufullscreen(var Msg:Tmessage); virtual cm_First + menu_fullscreen;
       procedure menufps(var Msg:Tmessage); virtual cm_First + menu_fps;
       procedure menurestart(var Msg:Tmessage); virtual cm_First + menu_restart;
       procedure menumainmenu(var Msg:Tmessage); virtual cm_First + menu_mainmenu;
       procedure menuplayers(var Msg:Tmessage); virtual cm_First + menu_players;
       procedure menuplayer(var Msg:Tmessage); virtual wm_first + wm_user + wm_player;
       procedure menuhighscores(var Msg:Tmessage); virtual cm_First + menu_highscores;
       procedure menuaboutgame(var Msg:Tmessage); virtual cm_First + menu_aboutgame;
       procedure menurungame(var Msg:Tmessage); virtual cm_First + menu_rungame;

       { screen messages }
       procedure WMMouseMove(var Msg: Tmessage); virtual wm_First + wm_MouseMove;
       procedure WMLButtonDown(var Msg: TMessage);  virtual wm_First + wm_LButtonDown;
       procedure WMLButtonUp(var Msg: TMessage);  virtual wm_First + wm_LButtonUp;
       procedure WMRButtonDown(var Msg: TMessage);  virtual wm_First + wm_RButtonDown;
       procedure WMRButtonUp(var Msg: TMessage);  virtual wm_First + wm_RButtonUp;
       procedure WMKeyDown(var Msg:Tmessage); virtual wm_First + wm_Keydown;
       procedure WMKeyUp(var Msg:Tmessage); virtual wm_First + wm_KeyUp;
       procedure wmchar(var Msg:Tmessage); virtual wm_First + wm_char;
       procedure wmtimer(var Msg:Tmessage); virtual wm_First + wm_timer;

       { cleanup routines }
       destructor Done; virtual;

     end;

implementation

{- initialization routines --------------------------------------------------------------------}

constructor tsfwindow.Init(AParent: PWindowsObject; ATitle: PChar);
  begin
    twindow.init(AParent,ATitle);
    attr.menu := loadmenu(hinstance,'STICKMENU');
  end;

procedure tsfwindow.GetWindowClass( var WC: TWndClass);
  begin
    TWindow.GetWindowClass(WC);
    WC.hIcon := LoadIcon(hInstance, MakeIntResource(999));
  end;

procedure tsfwindow.SetupWindow;
  var w:bmp;
  begin
    twindow.setupwindow;

    { initialize graphics buffer }
    if not isbmp(buffer) then
      begin
        w := makewindowbmp(hwindow);
        buffer := makeblankbmp(w,GetSystemMetrics(SM_CXSCREEN),GetSystemMetrics(SM_CYSCREEN));
        killbmp(w);
      end;

    { set variables }
    endisnear := false;
    fullscreen := false;
    showfps := false;
    hasmenu := true;

    { initialize resources }
    tile := loadbmp(getappdir(hinstance)+'\tile.bmp');
    scores.load(getappdir(hinstance)+'\scores.dat');
    game:=nil;
    screen := nil;
    runintro;

    { scores.clr  to clear scores }
  end;

{- game functions -----------------------------------------------------------------------------}

procedure tsfwindow.pause;
  begin
    if screen^.canpause and not screen^.paused then
      begin
        screen^.pause;
        repaint;
      end;
  end;

procedure tsfwindow.unpause;
  begin
    screen^.unpause;
    repaint;
  end;

procedure tsfwindow.newgame;
  begin
    if ishappyptr(game,sizeof(tgame)) then dispose(game,done);
    new(game,init);
  end;

procedure tsfwindow.opengame;
var filename:string;
    s: tdosstream;
  begin
    filename := wfileopen(hwindow,getappdir(hinstance),'Stickfighter Game (*.gam)','gam');
    if fileexists(filename) then
      begin
        s.init(pc(filename),stOpenRead);
        if ishappyptr(game,sizeof(tgame)) then dispose(game,done);
        game := pgame(s.get);
        s.done;
        rungame;
      end
    else
      unpause;
  end;

procedure tsfwindow.savegame;
var filename:string;
    s: tdosstream;
  begin
    if ishappyptr(game,sizeof(tgame)) then
      begin
        filename := wfilesave(hwindow,getappdir(hinstance),'Stickfighter Game (*.gam)','gam');
        if (filename<>'') then
        begin
          if fileexists(filename) then
            s.init(pc(filename),stopenwrite)
          else
            s.init(pc(filename),stcreate);
          s.put(game);
          s.done
        end;
      end;
  end;

procedure tsfwindow.repaint;
  begin
    screen^.update;
    if showfps and not screen^.paused then screen^.drawfps;
    invalidaterect(hwindow,@gamerect,false);         
  end;

procedure tsfwindow.resize;
    var i,j,k:integer;
        windsize,tilesize,gamesize:tpoint;
        ratio:real;
        window:bmp;
  begin
    window := makewindowbmp(Hwindow);
    tilesize.x := getwidth(tile);
    tilesize.y := getheight(tile);
    windsize.x := getwidth(window);
    windsize.y := getheight(window);
    killbmp(window);

    setmapmode(dchandle(buffer),MM_TEXT);
    setviewportorg(dchandle(buffer),0,0);
    setwindoworg(dchandle(buffer),0,0);
    clearclip(buffer);

    for i := 0 to (windsize.x div tilesize.x) do
      for j := 0 to (windsize.y div tilesize.y) do
        copybmp(tile,buffer,i*tilesize.x,j*tilesize.y);

    ratio := rmin(windsize.x/640,windsize.y/480);

    gamesize.x := round(rmin(640,640*ratio));
    gamesize.y := round(rmin(480,480*ratio));

    gamerect.left   := (windsize.x-gamesize.x) div 2;
    gamerect.top    := (windsize.y-gamesize.y) div 2;
    gamerect.right  := gamerect.left + gamesize.x;
    gamerect.bottom := gamerect.top +gamesize.y;

    cliptorect(buffer,gamerect.left,gamerect.top,gamerect.right,gamerect.bottom);
    setmapmode    (dchandle(buffer),MM_ANISOTROPIC);
    setwindoworg  (dchandle(buffer),0,0);
    setwindowext  (dchandle(buffer),640,480);
    setviewportorg(dchandle(buffer),gamerect.left,gamerect.top);
    setviewportext(dchandle(buffer),gamesize.x,gamesize.y);

    screen^.istrashed := true;
    repaint;
  end;

procedure tsfwindow.showmenu;
  begin
    if not hasmenu then begin setmenu(hwindow,attr.menu); hasmenu := true end;
  end;

procedure tsfwindow.hidemenu;
  begin
    if hasmenu then begin setmenu(hwindow,0); hasmenu := false; end;
  end;

procedure tsfwindow.fullsize;
  begin
    if not fullscreen then
      begin
        hidemenu;
        setwindowlong(hwindow, GWL_Style,
          getwindowlong(hwindow, GWL_Style) and not
          (ws_border or ws_thickframe or ws_caption));
        ShowWindow(hwindow, sw_maximize);
        setwindowpos(hwindow,0,0,0,getsystemmetrics(SM_CXSCREEN),getsystemmetrics(SM_CXSCREEN),SWP_NOZORDER);
        fullscreen := true;
      end;
  end;

procedure tsfwindow.windowsize;
  begin
    ShowWindow(hwindow, sw_restore);
  end;

procedure tsfwindow.swapfps;
  begin
    showfps := not showfps;
    unpause;
  end;

procedure tsfwindow.runintro;
  begin
    newgame;
    if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
    screen := new(pintro,init(buffer,@self));
    unpause;
  end;

procedure tsfwindow.runmenu; 
  begin
    if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
    screen := new(pmenu,init(buffer,@self,@gamerect));
    unpause;
  end;

procedure tsfwindow.runplayers; 
  begin
    if ishappyptr(game,sizeof(tgame)) then
      begin
        if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
        screen := new(pplayers,init(buffer,@self,@gamerect,game));
        unpause;
      end;
  end;

procedure tsfwindow.runplayer(n:integer); 
  begin
    if ishappyptr(game,sizeof(tgame)) then
      begin
        if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
        screen := new(pplayer,init(buffer,@self,@gamerect,game^.at(n)));
        unpause;
      end;
  end;

procedure tsfwindow.runscores;
  begin
    if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
    screen := new(pscorescreen,init(buffer,@self,@scores));
    unpause;
  end;

procedure tsfwindow.runabout; 
  begin
    if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
    screen := new(pabout,init(buffer,@self));
    unpause;
  end;

procedure tsfwindow.rungame;
  begin
    if ishappyptr(game,sizeof(tgame)) then
      begin
        if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
        screen := new(pgamescreen,init(buffer,@self));
        unpause;
      end;
  end;

{- window messages ----------------------------------------------------------------------------}

procedure tsfwindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); {wm_paint}
  var gamemode:tmapmode;
      msg:tmsg;
  begin
    savemapmode(dchandle(buffer),gamemode);

    setmapmode(dchandle(buffer),mm_text);
    setwindoworg(dchandle(buffer),0,0);
    setwindowext(dchandle(buffer),1,1);
    setviewportorg(dchandle(buffer),0,0);
    setviewportext(dchandle(buffer),1,1);

    with PaintInfo.rcpaint do
       bitblt(paintdc,left,top,right-left,bottom-top,dchandle(buffer),left,top,srccopy);

    loadmapmode(dchandle(buffer),gamemode);

    if screen^.needsrepaint then
      begin
        peekmessage(msg,0,0,0,PM_NOREMOVE); 
        repaint;
      end;
   end;

procedure tsfwindow.WMsize(var Msg: Tmessage); {wm_size}
  begin
    twindow.wmsize(Msg);
    if (msg.wparam = SIZE_RESTORED) and fullscreen then
      begin
        fullscreen := false;
        showmenu;
        setwindowlong(hwindow, GWL_Style,
        getwindowlong(hwindow, GWL_Style) or
        ws_caption or ws_border or ws_thickframe);
        setwindowpos(hwindow,0,0,0,0,0,SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or SWP_DRAWFRAME);
      end;
    resize;
  end;

procedure tsfwindow.wmncmousemove(var Msg: Tmessage); { WM_NCMOUSEMOVE }
  begin
    if fullscreen then
      if msg.LParamHi<getsystemmetrics(SM_CYMENU) then
        showmenu
      else
        if not menuopen then hidemenu;
  end;

procedure tsfwindow.wminitmenu(var Msg: Tmessage); {WM_INITMENU}

  function mf_check(test:boolean):word;
    begin
      if test then mf_check := MF_CHECKED else mf_check := MF_UNCHECKED;
    end;

  function mf_enable(test:boolean):word;
    begin
      if test then mf_enable := MF_ENABLED else mf_enable := MF_DISABLED or MF_GRAYED;
    end;

  begin
    checkmenuitem(attr.menu,menu_pausegame ,MF_BYCOMMAND or mf_check(screen^.paused));
    enablemenuitem(attr.menu,menu_pausegame ,MF_BYCOMMAND or mf_enable(screen^.canpause));
    enablemenuitem(attr.menu,menu_savegame ,MF_BYCOMMAND or mf_enable(ishappyptr(game,sizeof(tgame))));
    enablemenuitem(attr.menu,menu_rungame ,MF_BYCOMMAND or mf_enable(ishappyptr(game,sizeof(tgame))));
    enablemenuitem(attr.menu,menu_players ,MF_BYCOMMAND or mf_enable(ishappyptr(game,sizeof(tgame))));
    checkmenuitem(attr.menu,menu_fullscreen,MF_BYCOMMAND or mf_check(fullscreen));
    checkmenuitem(attr.menu,menu_fps,       MF_BYCOMMAND or mf_check(showfps));
    defwndproc(msg);
  end;

procedure tsfwindow.wmENTERMENULOOP(var Msg: Tmessage);
  begin
    pause;
    menuopen := true;
    if fullscreen then showmenu;
  end;

procedure tsfwindow.wmEXITMENULOOP(var Msg: Tmessage);
  begin
    menuopen := false;
    if fullscreen then hidemenu;
  end;

procedure tsfwindow.wmkillfocus(var Msg: Tmessage); {wm_killfocus}
  var f: font;
  begin
    if not endisnear then pause;
  end;

procedure tsfwindow.wmnchittest(var Msg: Tmessage); {WM_NCHITTEST}
  var pos:tpoint;
  begin
    defwndproc(msg);
    pos := tpoint(msg.lparam); screentoclient(hwindow,pos);
    if (msg.result = htclient) and not ptinrect(gamerect,pos) then msg.result := htcaption;
  end;

procedure tsfwindow.WMERASEBKGND(var Msg:Tmessage); {wm_erasebkgnd}
  begin
    msg.result := 1;
  end;

{- menu response ------------------------------------------------------------------------------}

procedure tsfwindow.menunewgame(var Msg:Tmessage);
  begin
    newgame;
    game^.genericplayers;
    runplayers;
  end;

procedure tsfwindow.menusavegame(var Msg:Tmessage);
  begin
    savegame;
  end;

procedure tsfwindow.menuopengame(var Msg:Tmessage);
  begin
    opengame;
  end;

procedure tsfwindow.menuquit(var Msg:Tmessage);
  begin
    done;
  end;

procedure tsfwindow.menupause(var Msg:Tmessage);
  begin
    if screen^.paused then unpause else pause;
{    pause;                                     }
  end;

procedure tsfwindow.menufullscreen(var Msg:Tmessage);
  begin
   if fullscreen then windowsize else fullsize;
  end;

procedure tsfwindow.menufps(var Msg:Tmessage);
  begin
    swapfps;
  end;

procedure tsfwindow.menurestart(var Msg:Tmessage);
  var n:integer;
  begin
    if ishappyptr(game,sizeof(tgame)) then
      begin
        n:=messagebox(hwindow,'Do you want to save the current game?','Stickfighter',MB_YESNOCANCEL);
        case n of
          idyes: savegame;
          {idno:} 
          idcancel:exit;
        end;
        dispose(game,done);
        game := nil;
      end;
    runintro;
  end;

procedure tsfwindow.menumainmenu(var Msg:Tmessage);
  begin
    runmenu;
  end;

procedure tsfwindow.menuplayers(var Msg:Tmessage);
  begin
    runplayers;
  end;

procedure tsfwindow.menuplayer(var Msg:Tmessage);
  begin
    runplayer(msg.wparam);
  end;


procedure tsfwindow.menuhighscores(var Msg:Tmessage);
  begin
    runscores;
  end;

procedure tsfwindow.menuaboutgame(var Msg:Tmessage);
  begin
    runabout;
  end;

procedure tsfwindow.menurungame(var Msg:Tmessage);
  begin
    rungame;
  end;

{- screen messages ----------------------------------------------------------------------------}

procedure tsfwindow.WMMouseMove(var Msg: Tmessage); {wm_mousemove}
  begin
    wmncmousemove(msg);
    defwndproc(msg);
    if not screen^.paused then screen^.mousemove(Msg);
  end;

procedure tsfwindow.WMLButtonDown(var Msg: TMessage); {wm_lbuttondown}
  begin
    setcapture(hwindow);
    defwndproc(msg);
    if not screen^.paused then screen^.mousedown(Msg);
  end;

procedure tsfwindow.WMLButtonUp(var Msg: Tmessage); {wm_lbuttonup}
  begin
   releasecapture;
   defwndproc(msg);
   if screen^.paused then unpause else screen^.mouseup(Msg);
  end;

procedure tsfwindow.WMRButtonDown(var Msg: TMessage); {wm_rbuttondown}
  begin
    defwndproc(msg);
  end;


procedure tsfwindow.WMRButtonUp(var Msg: Tmessage); {wm_rbuttonup}
  begin
   defwndproc(msg);
   done;
  end;

procedure tsfwindow.WMKeyDown(var Msg:Tmessage); {wm_keydown}
  begin
    defwndproc(Msg);
    if not screen^.paused then screen^.keydown(Msg);
  end;

procedure tsfwindow.WMKeyUp(var Msg:Tmessage); {wm_keyup}
  begin
    defwndproc(Msg);
    if not screen^.paused then screen^.keyup(Msg);
  end;

procedure tsfwindow.wmchar(var msg:tmessage); {wm_char}
  begin
    defwndproc(msg);
    if not screen^.paused then screen^.chartype(msg);
  end;

procedure tsfwindow.wmtimer(var Msg: Tmessage); {wm_timer}
  begin
    if not screen^.paused then screen^.timertick(msg);
  end;


{- cleanup routines ---------------------------------------------------------------------------}

destructor tsfwindow.done;
  begin
    endisnear := true;
    twindow.done;

    scores.save(getappdir(hinstance)+'\scores.dat');

    if isbmp(buffer) then killbmp(buffer);
    if isbmp(tile )  then killbmp(tile);
    if ishappyptr(screen,sizeof(tscreen)) then dispose(screen,done);
    if ishappyptr(game,sizeof(tgame)) then dispose(game,done);
  end;

begin
end.
