program stickfighter;
uses swindow,wobjects,winprocs;

type tapp = object(tapplication)
       procedure initmainwindow; virtual;
       procedure initinstance; virtual;
     end;

procedure tapp.initmainwindow;
  begin
    mainwindow:=new(psfwindow,init(nil,'StickFighter'));
  end;

procedure tapp.initinstance;
  begin
    tapplication.initinstance;
    hacctable := loadaccelerators(hinstance,'STICKMENU');
  end;

var myapp: tapp;

begin
  myapp.init('StickFighter');
  myapp.run;
  myapp.done;
end.