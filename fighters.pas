unit fighters;

interface

uses dynvar,wobjects,easygdi,sprocs;

const f_stickman = 1;
const PinM = 100;

type tkeys = record
       left,right,up,down,punch,kick:word;
       computer: boolean;
     end;

     tfposition = record
       x,y,l1x,l1y,l2x,l2y,cx,cy,a1x,a2x,head,duck:pdynamicreal;
       jump,walkf,walkb,punch,kick,ducked,dying,alive:pdynamicbool;
       size,direction:real;
     end;

type tfproperties = record
       ftype: byte;
       keycodes:tkeys;
       color: longint;
       hits,score: real;
       maxhits: integer;
       name:string;
       lastkill: boolean;
     end;

     pgenf = ^tgenf;
     tgenf = object(Tobject)
       fproperties: tfproperties;
       fposition: tfposition;
       closedist:integer;
       closest:pgenf;
       constructor init(x,y,direction:integer; size: real;
                        color:longint; maxhits: integer;
                        lastkill:boolean; name: string);
       constructor load(var S: TStream);
       procedure store(var S: TStream); virtual;
       destructor done;virtual;
       function steplit:real; virtual;
       procedure resetpoints; virtual;
       procedure setpoints(time:longint); virtual;
       procedure draw(drawbmp:bmp); virtual;
       procedure walkr(time:longint); virtual;
       procedure walkl(time:longint); virtual;
       procedure walkf(time:longint); virtual;
       procedure walkb(time:longint); virtual;
       procedure kick (time:longint); virtual;
       procedure punch(time:longint); virtual;
       procedure jump (time:longint); virtual;
       procedure duck (time:longint); virtual;
       procedure die  (time:longint); virtual;
       procedure stopduck(time:longint); virtual;
       procedure setkeys1; virtual;
       procedure setkeys2; virtual;
       procedure setcomp; virtual;
       procedure setkeyscust(l,u,r,d,p,k: word);
       procedure setclosest(dist:integer; who:pgenf);
       procedure hit(time:longint; ouch:real); virtual;
       procedure look(d:real);
     end;

type stickpos = record
       shape,x1,y1,x2,y2,angle1,angle2,way: word;
       color1,color2,color3: longint;
       lstyle,lthick,fillmode:word;
       plot: boolean;
     end;

type stickdims = record
       defl1,defl2,defa1,defa2,headW,headH,deftorso: integer;
       nose: real;
     end;

type pstickman = ^tstickman;
     tstickman = object(tgenf)
       pt: array[0..30] of stickpos;
       dims: stickdims;
       constructor init(x,y,direction:integer; size: real;
                        color:longint; maxhits: integer;
                        lastkill:boolean; name: string);
       constructor load(var S: TStream);
       procedure store(var S: TStream); virtual;
       destructor done; virtual;
       function steplit:real; virtual;
       procedure resetpoints; virtual;
       procedure setpoints(time:longint); virtual;
       procedure draw(drawbmp:bmp);virtual;
     end;

implementation

constructor tgenf.init(x,y,direction:integer; size: real;
            color:longint; maxhits: integer; lastkill:boolean;
            name: string);
  begin
    new(fposition.x,        init(x));
    new(fposition.y,        init(y));
    new(fposition.l1x,      init(0.5));
    new(fposition.l1y,      init(-1));
    new(fposition.l2x,      init(0.5));
    new(fposition.l2y,      init(-1));
    new(fposition.cx,       init(0));
    new(fposition.cy,       init(0));
    new(fposition.a1x,      init(0.5));
    new(fposition.a2x,      init(0.5));
    new(fposition.head,     init(0.5));
    new(fposition.duck,     init(0.8));
    new(fposition.jump,     init(false));
    new(fposition.walkf,    init(false));
    new(fposition.walkb,    init(false));
    new(fposition.punch,    init(false));
    new(fposition.kick,     init(false));
    new(fposition.ducked,   init(false));
    new(fposition.dying,    init(false));
    new(fposition.alive,    init(true));
    fposition.size :=       size;
    fposition.direction :=  direction;
    
    fproperties.color := color;
    fproperties.hits  := 0;
    fproperties.score := 0;
    fproperties.maxhits := maxhits;
    fproperties.name  := name;
    fproperties.lastkill := lastkill;

    { set keycodes, override ftype }

    closedist := 0;
    closest := nil;
  end;

constructor tgenf.load(var S: TStream);
  begin
    fposition.x         := pdynamicreal(s.get);
    fposition.y         := pdynamicreal(s.get);
    fposition.l1x       := pdynamicreal(s.get);
    fposition.l1y       := pdynamicreal(s.get);
    fposition.l2x       := pdynamicreal(s.get);
    fposition.l2y       := pdynamicreal(s.get);
    fposition.cx        := pdynamicreal(s.get);
    fposition.cy        := pdynamicreal(s.get);
    fposition.a1x       := pdynamicreal(s.get);
    fposition.a2x       := pdynamicreal(s.get);
    fposition.head      := pdynamicreal(s.get);
    fposition.duck      := pdynamicreal(s.get);
    fposition.jump      := pdynamicbool(s.get);
    fposition.walkf     := pdynamicbool(s.get);
    fposition.walkb     := pdynamicbool(s.get);
    fposition.punch     := pdynamicbool(s.get);
    fposition.kick      := pdynamicbool(s.get);
    fposition.ducked    := pdynamicbool(s.get);
    fposition.dying     := pdynamicbool(s.get);
    fposition.alive     := pdynamicbool(s.get);
    s.read(fposition.size,sizeof(fposition.size));
    s.read(fposition.direction,sizeof(fposition.direction));
    
    s.read(fproperties,sizeof(fproperties));


    closedist := 0;
    closest := nil;
  end;

procedure tgenf.store(var S: TStream);
  begin
    s.put(fposition.x);
    s.put(fposition.y);
    s.put(fposition.l1x);
    s.put(fposition.l1y);
    s.put(fposition.l2x);
    s.put(fposition.l2y);
    s.put(fposition.cx);
    s.put(fposition.cy);
    s.put(fposition.a1x);
    s.put(fposition.a2x);
    s.put(fposition.head);
    s.put(fposition.duck);
    s.put(fposition.jump);
    s.put(fposition.walkf);
    s.put(fposition.walkb);
    s.put(fposition.punch);
    s.put(fposition.kick);
    s.put(fposition.ducked);
    s.put(fposition.dying);
    s.put(fposition.alive);
    s.write(fposition.size,sizeof(fposition.size));
    s.write(fposition.direction,sizeof(fposition.direction));
    s.write(fproperties,sizeof(fproperties));
 
  end;

destructor tgenf.done;
  begin
    dispose(fposition.x,        done);
    dispose(fposition.y,        done);
    dispose(fposition.l1x,      done);
    dispose(fposition.l1y,      done);
    dispose(fposition.l2x,      done);
    dispose(fposition.l2y,      done);
    dispose(fposition.cx,       done);
    dispose(fposition.cy,       done);
    dispose(fposition.a1x,      done);
    dispose(fposition.a2x,      done);
    dispose(fposition.head,     done);
    dispose(fposition.duck,     done);
    dispose(fposition.jump,     done);
    dispose(fposition.walkf,    done);
    dispose(fposition.walkb,    done);
    dispose(fposition.punch,    done);
    dispose(fposition.kick,     done);
    dispose(fposition.ducked,   done);
    dispose(fposition.dying,    done);
    dispose(fposition.alive,    done);
  end;

function tgenf.steplit:real;
  begin
   messagebox(0,'TGENF.STEPLIT has been called','StickFighter Error',0);
  end;

procedure tgenf.resetpoints;
  begin
    messagebox(0,'TGENF.RESETPOINTS has been called','StickFighter Error',0);
  end;

procedure tgenf.setpoints(time:longint);
  begin
    messagebox(0,'TGENF.SETPOINTS has been called','StickFighter Error',0);
  end;

procedure tgenf.draw(drawbmp:bmp);
  begin
    messagebox(0,'TGENF.DRAW has been called','StickFighter Error',0);
  end;

procedure tgenf.walkr(time:longint);
  begin
    if closest = nil then look(1);
    if fposition.direction > 0 then walkf(time) else walkb(time);
  end;

procedure tgenf.walkl(time:longint);
  begin
    if closest = nil then look(-1);
    if fposition.direction < 0 then walkf(time) else walkb(time);
  end;

procedure tgenf.walkb(time:longint);
  var pos,f: real;
  begin
    if fposition.jump^.getval(time) then f:=1.5/1000 else f:=1/1000;
    if not fposition.walkb^.getval(time) then
      with fposition do
        begin
          l1x^.addcookie(new(pquadratic,init(time    ,time+150, 150*f,0,f,0)));
          l1x^.addcookie(new(pquadratic,init(time+150,time+300,-150*f,0,-f,0)));
          pos:=f*steplit*direction;
          x^.addcookie  (new(pquadratic,init(time+150,time+300,150*pos,0,pos,0)));
          walkf^.setval(time+300,true,false);
        end;
  end;

procedure tgenf.walkf(time:longint);
  var pos,f: real;
  begin
    if fposition.jump^.getval(time) then f:=1.5/1000 else f:=1/1000;
    if not fposition.walkf^.getval(time) then
      with fposition do
        begin
          walkf^.setval(time+300,true,false);
          l2x^.addcookie(new(pquadratic,init(time,time+150,150*f,0,f,0)));
          l2x^.addcookie(new(pquadratic,init(time+150,time+300,-150*f,0,-f,0)));
          pos := f*steplit*direction;
          x^.addcookie(new(pquadratic,init(time+150,time+300,150*pos,0,pos,0)));
        end;
  end;

procedure tgenf.die(time:longint);
  var x: integer;
  begin
    fposition.dying^.setval(time+150,true,false);
    fposition.alive^.setval(time,false,false);
  end;

procedure tgenf.hit(time:longint; ouch: real);
  begin
    if fposition.ducked^.getval(time) then ouch := ouch /2;
    if fproperties.maxhits <> 0 then fproperties.hits := fproperties.hits + ouch;
  end;

procedure tgenf.kick(time:longint);
  var power: real;
  begin
    power := 1.1;
    if fposition.jump^.getval(time) then power := power * 2;

    if not fposition.kick^.getval(time) then
      with fposition do
        begin
          kick^.setval(300,true,false);
          l2y^.addcookie(new(pquadratic,init(time    ,time+150, 20/1000*150,0, 20/1000,0)));
          l2x^.addcookie(new(pquadratic,init(time    ,time+150,  3/1000*150,0,  3/1000,0)));
          l2y^.addcookie(new(pquadratic,init(time+150,time+300,-20/1000*150,0,-20/1000,0)));
          l2x^.addcookie(new(pquadratic,init(time+150,time+300, -3/1000*150,0, -3/1000,0)));

          if (abs(closedist)<abs(1.3*size*direction*PinM)) and
             (closest <> nil)
          then
            begin
              closest^.hit(time,power);
               fproperties.score:=fproperties.score+10;
            end;
        end;
  end;

procedure tgenf.punch(time:longint);
  var power: real;
  begin
    power := 1;
    if fposition.jump^.getval(time) then power := power * 2;

    if not fposition.punch^.getval(time) then
      with fposition do
        begin
          punch^.setval(300,true,false);
          a2x^.addcookie(new(pquadratic,init(time    ,time+150, 7/1000*150,0, 7/1000,0)));
          a2x^.addcookie(new(pquadratic,init(time+150,time+300,-7/1000*150,0,-7/1000,0)));

          if (abs(closedist) < abs(1.2*size*direction*PinM)) and
             (closest <> nil)

          then
            begin
              closest^.hit(time,power);
              fproperties.score := fproperties.score+10;
            end;
        end;
  end;

procedure tgenf.jump(time:longint);
  var v,a: real;
      t: longint;
  begin
    if not fposition.jump^.getval(time) then
      with fposition do
        begin
          v := -4/1000*PinM;
          a := 9.8/1000000*PinM;
          t := round(-2*v/a);
          y^.addcookie(new(pquadratic,init(time+250,time+250+t,0,0,v,a)));
          jump^.setval(time+250+t,true,false);
          duck^.addcookie(new(psine,init(time,time+500,0,-0.2,4*pi,0)));
        end;
  end;

procedure tgenf.duck(time:longint);
  begin
    if not fposition.ducked^.getval(time) then
      fposition.duck^.addcookie(new(pquadratic,init(time,time+300,-0.3,0,-1/1000,0)));
  end;

procedure tgenf.stopduck(time:longint);
  begin
    if fposition.ducked^.getval(time) then
      fposition.duck^.addcookie(new(pquadratic,init(time,time+300,0.3,0,1/1000,0)));
  end;

procedure tgenf.setkeys1;
  begin
    with fproperties.keycodes do
      begin
        up    :=  38; {up arrow    }
        down  :=  40; {down arrow  }
        left  :=  37; {left arrow  }
        right :=  39; {right arrow }
        punch :=  16; {shift       }
        kick  :=  17; {control     }
        computer := false;
      end;
  end;

procedure tgenf.setkeys2;
  begin
    with fproperties.keycodes do
      begin
        up    :=  87; {letter 'W'  }
        down  :=  83; {letter 'S'  }
        left  :=  65; {letter 'A'  }
        right :=  68; {letter 'D'  }
        punch :=  74; {letter 'J'  }
        kick  :=  75; {letter 'K'  }
        computer := false;
      end;
  end;

procedure tgenf.setcomp;
  begin
    with fproperties.keycodes do
      begin
        computer := true;
      end;
  end;

procedure tgenf.setkeyscust(l,u,r,d,p,k: word);
  begin
    with fproperties.keycodes do
      begin
        up    :=  l;
        down  :=  d;
        left  :=  l;
        right :=  r;
        punch :=  p;
        kick  :=  k;
        computer := false;
      end;
  end;

procedure tgenf.setclosest(dist:integer; who:pgenf);
  begin
    closedist := dist;
    closest   := who;
  end;

procedure tgenf.look(d: real);
  var x: integer;
  begin
    fposition.direction := d;
  end;

constructor tstickman.init(x,y,direction:integer; size: real;
            color:longint; maxhits: integer; lastkill:boolean;
            name: string);
  begin
    tgenf.init(x,y,direction,size,color,maxhits,lastkill,name);
    fproperties.ftype := f_stickman;
    resetpoints;
  end;

constructor tstickman.load(var S:TStream);
  begin
    tgenf.load(s);
    resetpoints;
  end;

procedure tstickman.store(var S:TStream);
  begin
    tgenf.store(s);
  end;

destructor tstickman.done;
  begin
    tgenf.done;
  end;

function tstickman.steplit:real;
  begin
    steplit := dims.defl1+dims.defl2;
  end;

procedure tstickman.resetpoints;
  var x: integer;
  begin
    dims.defl1     := round(0.5  * PinM  * fposition.size);
    dims.defl2     := round(0.4  * PinM  * fposition.size);
    dims.defa1     := round(0.3  * PinM  * fposition.size);
    dims.defa2     := round(0.3  * PinM  * fposition.size);
    dims.deftorso  := round(0.4  * PinM  * fposition.size);
    dims.headw     := round(0.25 * PinM  * fposition.size);
    dims.headh     := round(0.25 * PinM  * fposition.size);
    dims.nose := 1.4;

    for x:= 0 to 30 do
      with pt[x] do
        begin
          plot := false;
          color1 := 0;
          color2 := 0;
          color3 := 0;
          lstyle := 0;
          lthick := 0;
          fillmode := 0;
        end;
  end;

procedure tstickman.setpoints(time:longint);
  var duckby,ang,a2,a3,t1x,t1y,t2x,t2y: real;
      ctx,cty: integer;
  begin
    resetpoints;
      begin
        duckby := fposition.duck^.getval(time)*(dims.defl1+dims.defl2);
        cty    := round(fposition.y^.getval(time)-duckby);
        ctx    := round(fposition.x^.getval(time));

{-----------------------------------------------------------------------------}

        with pt[0] do                                 {control}
          begin
            shape := 0;
            x1 := round(fposition.x^.getval(time));
            y1 := round(fposition.y^.getval(time));
            plot := false;
          end;

{-----------------------------------------------------------------------------}

t1x := -fposition.l1x^.getval(time)*fposition.direction*(dims.defl1+dims.defl2);
t1y := fposition.l1y^.getval(time)*duckby;
ang := atan(t1x,t1y)+pi+fposition.direction/abs(fposition.direction)*
       acos((sqr(dims.defl2)-sqr(dims.defl1)-(sqr(t1x)+sqr(t1y)))/
      (2*dims.defl1*sqrt(sqr(t1x)+sqr(t1y))));
        
{-----------------------------------------------------------------------------}

        with pt[1] do                         {Leg 1 Knee-Foot}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(fposition.x^.getval(time)+t1x);                   {f1x}
            y1 := round(fposition.y^.getval(time)-duckby-t1y);            {f1y}
            x2 := round(fposition.x^.getval(time)+dims.defl1*cos(ang));        {k1x}
            y2 := round(fposition.y^.getval(time)-duckby-dims.defl1*sin(ang)); {k1y}
          end;
        with pt[2] do                          {Leg 1 Knee-Mid}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;
            y1 := cty;
            x2 := round(fposition.x^.getval(time)+dims.defl1*cos(ang));           {k1x}
            y2 := round(fposition.y^.getval(time)-duckby-dims.defl1*sin(ang));    {k1y}
          end;

{-----------------------------------------------------------------------------}

t2x := fposition.l2x^.getval(time)*fposition.direction*(dims.defl1+dims.defl2);
t2y := fposition.l2y^.getval(time)*duckby;
ang := atan(t2x,t2y)+pi-t2x/abs(t2x)*
       acos((sqr(dims.defl2)-sqr(dims.defl1)-(sqr(t2x)+sqr(t2y)))/
       (2*dims.defl1*sqrt(sqr(t2x)+sqr(t2y))))
          ;
{-----------------------------------------------------------------------------}
        with pt[3] do                         {Leg 2 Knee-Foot}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(fposition.x^.getval(time)+t2x);            {f2x}
            y1 := round(fposition.y^.getval(time)-duckby-t2y);               {f2y}
            x2 := round(ctx+dims.defl1*cos(ang));         {k2x}
            y2 := round(fposition.y^.getval(time)-duckby-dims.defl1*sin(ang));    {k2y}
          end;
        with pt[4] do                           {Leg2 Knee-Mid}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;
            y1 := cty;
            x2 := round(ctx+dims.defl1*cos(ang));         {k2x}
            y2 := round(fposition.y^.getval(time)-duckby-dims.defl1*sin(ang));    {k2y}
          end;
        with pt[5] do                                  {Mid-Sh}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;
            y1 := cty;
            x2 := ctx;                               {Sx}
            y2 := cty-dims.deftorso;                      {Sy}
          end;

{-----------------------------------------------------------------------------}

t1x := fposition.direction*fposition.a1x^.getval(time)*(dims.defa1+dims.defa2);
t2x := fposition.direction*fposition.a2x^.getval(time)*(dims.defa1+dims.defa2);
t1y := 0;
t2y := 0;
ang := -acos((sqr(dims.defa2)-sqr(dims.defa1)-(sqr(t1x)+sqr(t1y)))/(2*dims.defa1*sqrt(sqr(t1x)+sqr(t1y))));

{-----------------------------------------------------------------------------}

        with pt[6] do                                  {Sh-El1}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx+fposition.direction*dims.defa1*cos(ang)); {e1x}
            y1 := round(cty-dims.deftorso-dims.defa1*sin(ang));  {e1y}
            x2 := ctx;                                 {Sx}
            y2 := cty-dims.deftorso;                        {Sy}
          end;
        with pt[7] do                                  {El1-H1}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx+fposition.direction*dims.defa1*cos(ang)); {e1x}
            y1 := round(cty-dims.deftorso-dims.defa1*sin(ang));  {e1y}
            x2 := round(fposition.x^.getval(time)-t1x);                        {H1x}
            y2 := cty-dims.deftorso;                        {H1y}
          end;

{-----------------------------------------------------------------------------}

ang := -acos((sqr(dims.defa2)-sqr(dims.defa1)-(sqr(t2x)+sqr(t2y)))/(2*dims.defa1*sqrt(sqr(t2x)+sqr(t2y))));

{-----------------------------------------------------------------------------}

        with pt[8] do                                  {Sh-El2}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx-fposition.direction*dims.defa1*cos(ang));  {e2x}
            y1 := round(cty-dims.deftorso-dims.defa1*sin(ang));   {e2y}
            x2 := ctx;                               {Sx}
            y2 := cty-dims.deftorso;                      {Sy}
          end;
        with pt[9] do                                  {El2-H2}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(ctx-fposition.direction*dims.defa1*cos(ang));  {e2x}
            y1 := round(cty-dims.deftorso-dims.defa1*sin(ang));   {e2y}
            x2 := round(fposition.x^.getval(time)+t2x);                         {H2x}
            y2 := cty-dims.deftorso;                         {H2y}
          end;

t1x := fposition.x^.getval(time);                                    {Hdx}
t1y := cty-dims.deftorso-fposition.head^.getval(time)*PinM*fposition.size/2;        {Hdy}

{-----------------------------------------------------------------------------}

        with pt[10] do                                 {Sh-Head}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := ctx;                                   {Sx}
            y1 := cty-dims.deftorso;                          {Sy}
            x2 := round(t1x);                            {Hdx}
            y2 := round(t1y);                            {Hdy}
          end;

        with pt[11] do                                 {Head}
          begin
            shape:=1; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            color2:=0;
            x1 := round(t1x);                            {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := round(fposition.direction*dims.headw);
            y2 := round(dims.headh);
          end;
        with pt[12] do                                 {NoseTop}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(t1x+fposition.direction*dims.headw*dims.nose);       {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := round(t1x+fposition.direction*dims.headw*cos(20/180*pi));
            y2 := round(t1y-dims.headh*sin(20/180*pi));
          end;
        with pt[13] do                                 {NoseBot}
          begin
            shape:=0; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(t1x+fposition.direction*dims.headw*dims.nose);       {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := round(t1x+fposition.direction*dims.headw*cos(20/180*pi));
            y2 := round(t1y);
          end;
        with pt[14] do                                 {Smiley}
          begin
            shape:=2; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            x1 := round(t1x+fposition.direction*dims.headw);            {Hdx}
            y1 := round(t1y);                            {Hdy}
            x2 := abs(round(fposition.direction*dims.headw));
            y2 := abs(round(dims.headh*2/3));
            way:=0;
            if fposition.direction > 0 then angle1:=200 else angle1:=285;
            if fposition.direction > 0 then angle2:=255 else angle2:=360;
          end;
        with pt[16] do                                 {Smiley}
          begin
            shape:=1; color1:=color[7]; lstyle:=0; lthick:=2; plot := true;
            color2:=-1;
            x1 := round(t1x+fposition.direction*dims.headw/2);           {EyeX}
            y1 := round(t1y-dims.headh/2);           {EyeY}
            x2 := abs(round(fposition.direction*dims.headw/3.9));
            y2 := abs(round(dims.headh/3.9));
            way:=0;
            angle1:=180;
            angle2:=260;
          end;
        with pt[15] do                                 {Smiley}
          begin
            shape:=1; color1:=fproperties.color; lstyle:=0; lthick:=2; plot := true;
            color2:=fproperties.color;
            x1 := round(t1x+fposition.direction*dims.headw/2+fposition.direction*dims.headw/10);           {EyeX}
            y1 := round(t1y-dims.headh/2);           {EyeY}
            x2 := abs(round(fposition.direction*dims.headw/7));
            y2 := abs(round(dims.headh/7));
            way:=0;
            angle1:=180;
            angle2:=260;
          end;

      end;
  end;

procedure tstickman.draw(drawbmp:bmp);
  var x: integer;
  begin
    for x:= 0 to 30 do
      with pt[x] do
        if plot then
          begin
            setpen(drawbmp,color1,lstyle,lthick);
            setbrush(drawbmp,color2,color3,fillmode);
            case shape of
            0: line(drawbmp,x1,y1,x2,y2);
            1: circle(drawbmp,x1,y1,x2,y2);
            2: pcircle(drawbmp,x1,y1,x2,y2,angle1,angle2,way);
            end;
          end;
  end;

const
  rfighters = 200;

  rstickman: TStreamRec = (
    ObjType: rfighters+1;
    VmtLink: Ofs(TypeOf(tstickman)^);
    Load: @tstickman.load;
    Store: @tstickman.store);

begin
  RegisterType(rstickman);
end.