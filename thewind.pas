program fighter;
uses wobjects,winprocs,wintypes;

type pwnd = ^twnd;
     twnd = object(twindow)
     constructor init(AParent: PWindowsObject; ATitle: PChar);
     end;

constructor twnd.init(AParent: PWindowsObject; ATitle: PChar);
  begin
    twindow.init(AParent,ATitle);
    attr.x:=0;
    attr.y:=0;
    attr.w:=640;
    attr.h:=480;
    attr.style:=0;
    attr.style:=WS_POPUP + WS_VISIBLE + WS_MAXIMIZE;
    b_exit:=new(Pbutton,Init(twnd,1,'Exit',X,Y,W,H: Integer; IsDefault: Boolean);
  end;

type Tapp = object(tapplication)
       constructor init;
       destructor done; virtual;
       procedure initmainwindow; virtual;
     end;

constructor Tapp.init;
  begin
    tapplication.init('AppName');;
  end;

destructor Tapp.done;
  begin
    tapplication.done;
  end;

procedure tapp.initmainwindow;
  begin
    mainwindow:=new(Pwnd,init(nil,'Finally...'));
  end;

var app:tapp;
    b_exit:^tbutton;
begin
  app.init;
  app.run;
  app.done;
end.




