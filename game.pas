unit game;

interface

uses wobjects,easygdi,fighters;

type pgame = ^tgame;
     tgame = object(tcollection)
       constructor Init;
       destructor done; virtual;
     end;

type tscoredata = record
       name: string;
       score: longint;
       alive: boolean;
     end;

type   pscores = ^tscores;
       tscores = object
       data: array[1..10] of tscoredata;
       procedure add(who:string; what: longint);
       procedure sort;
       procedure save(filename: string);
       procedure load(filename: string);
       procedure clr;
     end;

implementation

constructor tgame.Init;
  var f:pgenf;
  begin
    tcollection.Init(1,1);
    insert(new(pstickman,init(200,350,1,1,color[12],50,True,'Computer')));
    f := at(0); f^.setcomp;
    insert(new(pstickman,init(200,350,1,1,color[9],50,True,'Bob')));
    f := at(0); f^.setkeys1;
  end;

destructor tgame.done;
  begin
    tcollection.done;
  end;

procedure tscores.add(who:string; what: longint);
  var i: integer;
      beenthere: boolean;
  begin
    beenthere := false;
    sort;
   for i := 1 to 10 do
      begin
        beenthere := beenthere or (data[i].name=who);
        if data[i].name = who then
           if data[i].score < what then data[i].score := what;
      end;
    if not beenthere then
      begin
        sort;
        if (what > data[10].score) or not data[10].alive then
        begin
          data[10].name  := who;
          data[10].score := what;
          data[10].alive := true;
        end;
      end;
    sort;
  end;

procedure tscores.sort;
  var i,j,k: integer;
      swap: tscoredata;
  begin
    for i := 1 to 9 do
      for j := i to 10 do
        begin
          if (data[i].score < data[j].score) or not data[i].alive then
            begin
              swap    := data[i];
              data[i] := data[j];
              data[j] := swap;
            end;
        end;
  end;

procedure tscores.save(filename: string);
  var f: file of tscoredata;
      i: integer;
  begin
    assign(f,filename);
    rewrite(f);
    for i := 1 to 10 do
      write(f,data[i]); 
    close(f);
  end;

procedure tscores.load(filename: string);
  var f: file of tscoredata;
      i: integer;
  begin
    if fileexists(filename) then 
      begin
        assign(f,filename);
        reset(f);
        for i := 1 to 10 do
          read(f,data[i]); 
        close(f);
      end
    else
      clr;
  end;

procedure tscores.clr;
  var i: integer;
  begin
    for i:= 1 to 10 do
      with data[i] do
        begin
          alive := false;
          score := 0;
          name  := '';
        end;
  end;

const
  rgameu = 250;

  rgame: TStreamRec = (
    ObjType: rgameu+1;
    VmtLink: Ofs(TypeOf(tgame)^);
    Load: @tgame.load;
    Store: @tgame.store);

begin
  RegisterType(rgame);
end.