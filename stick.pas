program stickfighter;
uses swindow,wobjects;

type tapp = object(tapplication)
       procedure initmainwindow; virtual;
     end;

procedure tapp.initmainwindow;
  begin
    mainwindow:=new(psfwindow,init(nil,'StickFighter'));
  end;

var myapp: tapp;

begin
  myapp.init('StickFighter');
  myapp.run;
  myapp.done;
end.