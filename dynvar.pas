unit dynvar;

interface

uses wobjects,win31;

type pcookie = ^tcookie;
     tcookie = object(tobject)
       timestart,timeend: longint;
       finalvalue: real;
       constructor init(t0,tf:longint; final:real);
       constructor load(var S: TStream);
       procedure store(var S: TStream); virtual;
       destructor done; virtual;
       function getval(time:longint):real; virtual;
       function evaluate(time:longint):real; virtual;
       function isexpired(time:longint):boolean; virtual;
     end;

type pquadratic = ^tquadratic;
     tquadratic = object(tcookie)
       ac,bc,cc:real;
       constructor init(t0,tf:longint; final,a,b,c:real);
       constructor load(var S: TStream);
       procedure store(var S: TStream); virtual;
       destructor done; virtual;
       function evaluate(time:longint):real; virtual;
     end;

type psine = ^tsine;
     tsine = object(tcookie)
       ac,bc,cc:real;
       constructor init(t0,tf:longint; final,a,b,c:real);
       constructor load(var S: TStream);
       procedure store(var S: TStream); virtual;
       destructor done; virtual;
       function evaluate(time:longint):real; virtual;
     end;

type pdynamicreal = ^tdynamicreal;
     tdynamicreal = object(tcollection)
       initialvalue: real;
       constructor init(initval:real);
       constructor load(var S: TStream);
       procedure store(var S: TStream); virtual;
       destructor done; virtual;
       procedure addcookie(cookie:pcookie); virtual;
       function getval(time:longint):real; virtual;
     end;

type pdynamicbool = ^tdynamicbool;
     tdynamicbool = object(tobject)
     cval,nval:boolean;
     fliptime: longint;
     constructor init(initval:boolean);
     constructor load(var S: TStream);
     procedure store(var S: TStream); virtual;
     destructor done; virtual;
     function getval(time:longint):boolean;
     procedure setval(switchtime:longint; currentval,newval:boolean);
     end;

implementation

constructor tcookie.init(t0,tf:longint; final:real);
  begin
    tobject.init;
    timestart  := t0;
    timeend    := tf;
    finalvalue := final;
  end;

constructor tcookie.load(var S: TStream);
  begin
    S.Read(timestart , sizeof(timestart ));
    S.Read(timeend   , sizeof(timeend   ));
    S.Read(finalvalue, sizeof(finalvalue));
  end;

procedure tcookie.store(var S: TStream);
  begin
    S.Write(timestart , sizeof(timestart ));
    S.Write(timeend   , sizeof(timeend   ));
    S.Write(finalvalue, sizeof(finalvalue));
  end;

destructor tcookie.done;
  begin
    tobject.done;
  end;

function tcookie.getval(time:longint):real; 
  begin
    if (time<timestart) then getval := 0;
    if (time>=timestart) and (time<timeend) then getval := evaluate(time);
    if (time>=timeend) then getval := finalvalue;
  end;

function tcookie.evaluate(time:longint):real;
  begin
    evaluate := -1;
  end;

function tcookie.isexpired(time:longint):boolean;
  begin
    isexpired := (time>=timeend);
  end;

constructor tquadratic.init(t0,tf:longint; final,a,b,c:real);
  begin
    tcookie.init(t0,tf,final);
    ac := a;
    bc := b;
    cc := c;
  end;

constructor tquadratic.load(var S: TStream);
  begin
    tcookie.load(s);
    S.Read(ac,sizeof(ac));
    S.Read(bc,sizeof(bc));
    S.Read(cc,sizeof(cc));
  end;

procedure tquadratic.store(var S: TStream);
  begin
    tcookie.store(s);
    S.Write(ac,sizeof(ac));
    S.Write(bc,sizeof(bc));
    S.Write(cc,sizeof(cc));
  end;

destructor tquadratic.done;
  begin
    tcookie.done;
  end;

function tquadratic.evaluate(time:longint):real;
  begin
    evaluate := ac + bc*time + cc*time*time;
  end;

constructor tsine.init(t0,tf:longint; final,a,b,c:real);
  begin
    tcookie.init(t0,tf,final);
    ac := a;
    bc := b;
    cc := c;
  end;

constructor tsine.load(var S: TStream);
  begin
    tcookie.load(s);
    S.Read(ac,sizeof(ac));
    S.Read(bc,sizeof(bc));
    S.Read(cc,sizeof(cc));
  end;

procedure tsine.store(var S: TStream);
  begin
    tcookie.store(s);
    S.Write(ac,sizeof(ac));
    S.Write(bc,sizeof(bc));
    S.Write(cc,sizeof(cc));
  end;

destructor tsine.done;
  begin
    tcookie.done;
  end;

function tsine.evaluate(time:longint):real;
  begin
    evaluate := ac*sin(bc*time + cc);
  end;

constructor tdynamicreal.init(initval:real);
  begin
    initialvalue := initval;
    tcollection.init(1,1);
  end;

constructor tdynamicreal.load(var S: TStream);
  begin
    tcollection.load(s);
    S.Read(initialvalue,sizeof(initialvalue));
  end;
  
procedure tdynamicreal.store(var S: TStream);
  begin
    tcollection.store(s);
    S.Write(initialvalue,sizeof(initialvalue));
  end;

destructor tdynamicreal.done;
  begin
    tcollection.done;
  end;

procedure tdynamicreal.addcookie(cookie:pcookie);
  var c: pcookie;
  begin
    insert(cookie);
  end;

function tdynamicreal.getval(time:longint):real;
  var s:real;
      c: pcookie;
      i:integer;
  begin
    s := 0;
    for i := 0 to count-1 do
      begin
        c := at(i);
        if c^.isexpired(time) then
          begin
            initialvalue := initialvalue + c^.getval(time);
            dispose(c,done);
          end 
        else
          s := s + c^.getval(time);
      end;  
    pack;
    getval := initialvalue + s;
  end;

constructor tdynamicbool.init(initval:boolean);
  begin
    cval := initval;
    nval := initval;
    fliptime := 0;
  end;

constructor tdynamicbool.load(var S: TStream);
  begin
    s.read(cval,sizeof(cval));
    s.read(nval,sizeof(nval));
    s.read(fliptime,sizeof(fliptime));
  end;

procedure tdynamicbool.store(var S: TStream); 
  begin
    s.write(cval,sizeof(cval));
    s.write(nval,sizeof(nval));
    s.write(fliptime,sizeof(fliptime));
  end;

destructor tdynamicbool.done;
  begin
    tobject.done;
  end;

function tdynamicbool.getval(time:longint):boolean;
  begin
    if time < fliptime then
      getval := cval
    else
      getval := nval;
  end;

procedure tdynamicbool.setval(switchtime:longint; currentval,newval:boolean);
  begin
    fliptime := switchtime;
    cval := currentval;
    nval := newval;
  end;

const
  rdynvar = 150;

  rquadratic: TStreamRec = (
    ObjType: rdynvar+1;
    VmtLink: Ofs(TypeOf(tquadratic)^);
    Load: @tquadratic.load;
    Store: @tquadratic.store);

  rsine: TStreamRec = (
    ObjType: rdynvar+2;
    VmtLink: Ofs(TypeOf(tsine)^);
    Load: @tsine.load;
    Store: @tsine.store);

  rdynamicreal: TStreamRec = (
    ObjType: rdynvar+3;
    VmtLink: Ofs(TypeOf(tdynamicreal)^);
    Load: @tdynamicreal.load;
    Store: @tdynamicreal.store);

  rdynamicbool: TStreamRec = (
    ObjType: rdynvar+4;
    VmtLink: Ofs(TypeOf(tdynamicbool)^);
    Load: @tdynamicbool.load;
    Store: @tdynamicbool.store);

begin
  RegisterType(rquadratic);
  RegisterType(rsine);
  RegisterType(rdynamicreal);
  RegisterType(rdynamicbool);
end.