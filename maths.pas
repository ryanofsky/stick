unit maths;
interface

type
  polyptr       = ^polynom;
  rootstack     = ^eachroot;
  complex       = record
                     re : real  ;
                   im : real  ;
                 end;
  polynom       = record
                     link : polyptr;
                   coeff : complex;
                 end;
  eachroot      = record
                     link : rootstack;
                   coeff : complex;
                 end;

function floor(x : real  ) : real  ;  (* the next lowest integer             *)
function ceiling(x : real  ) : real  ; (* the next highest integer           *)
function log10(x : real  ) : real  ;  (* base 10 log of x                    *)
function exp10(x : real  ) : real  ;  (* 10 raised to the x power            *)
function pwrxy(x, y : real  ) : real  ; (* raise x to the power y            *)
function qdbv(volts : real  ) : real  ; (* convert from volts to db          *)
function qdbw(watts : real  ) : real  ; (* convert from watts to db          *)
function qwatts(db : real  ) : real  ; (* convert from db to watts           *)
function qvolts(db : real  ) : real  ; (* convert from db to volts           *)
function sinh(x : real  ) : real  ;   (* hyperbolic sine                     *)
function cosh(x : real  ) : real  ;   (* hyperbolic cosine                   *)
function tanh(x : real  ) : real  ;   (* hyperbolic tangent                  *)
function isinh(x : real  ) : real  ;  (* arc hyperbolic sine                 *)
function icosh(x : real  ) : real  ;  (* arc hyperbolic cosine               *)
function itanh(x : real  ) : real  ;  (* arc hyperbolic tangent              *)
function arcsin(x : real  ) : real  ; (* arc sine using tp arctan function   *)
function arccos(x : real  ) : real  ; (* inverse cosine using tp arctan      *)
function atan2(x, y : real  ) : real  ; (* arctan function with quadrant check
 x is real axis value or denominator, y is imaginary axis value or numerator *)
function tan(x : real  ) : real  ;    (* tangent of x                        *)
function gauss (mean, stddev : real  ) : real  ; (* gaussian random number   *)
function residue(radix, number : real  ) : real  ; (* remainder of number/radix
                                                                             *)
function minimum(a, b : real  ) : real  ; (* the minimum of a and b          *)
function maximum(a, b : real  ) : real  ; (* the maximum of a and b          *)
procedure cadd(c, d : complex;
                   var result : complex); (* add two complex numbers         *)
procedure cconj(a : complex;
                   var result : complex); (* complex conjugate               *)
procedure cdiv(num, denom : complex;
                   var result : complex); (* complex division   *)
procedure cinv(a : complex;
                   var result : complex); (* complex inverse                 *)
function cmag(c : complex) : real  ;  (* magnitude of a complex number       *)
procedure cmake(a, b : real  ;
                   var result : complex); (* form a complex number           *)
procedure cmult(c, d : complex;
                   var result : complex); (* multiply two complex numbers    *)
procedure csub(c, d : complex;
                   var result : complex); (* subtract d from c complex number
                                                                             *)
procedure cexp(a : complex;
                   var result : complex); (* exponential of a complex number *)
procedure csqr(a : complex;
                   var result : complex); (* square of a complex number      *)
procedure csqrt(a : complex;
                   var result : complex); (* sqrt of a complex number        *)
procedure cln(a : complex;
                   var result : complex); (* natural log of complex a        *)
procedure cpwrxy(x, y : complex;
                   var result : complex); (* raise x to the y power          *)
procedure csinh(a : complex;
                   var result : complex); (* hyperbolic sine of complex a    *)
procedure ccosh(a : complex;
                   var result : complex); (* hyperbolic cosine of complex a  *)
procedure ctanh(a : complex;
                   var result : complex); (* hyperbolic tangent of complex a *)
procedure csin(a : complex;
                   var result : complex); (* sine of complex a               *)
procedure ccos(a : complex;
                   var result : complex); (* cosine of complex a             *)
procedure ctan(a : complex;
                   var result : complex); (* tangent of complex a            *)
procedure carcsin(a : complex;
                   var result : complex); (* inverse sine of complex a       *)
procedure carccos(a : complex;
                   var result : complex); (* inverse cosine of complex a     *)
procedure carctan(a : complex;
                   var result : complex); (* inverse tangent of complex a    *)
procedure polyassign(x : polyptr;     (* generate new polynomial at y with   *)
                   var y : polyptr);  (* same coefficients as poly at x      *)
procedure polyclear(var ptr : polyptr); (* remove a polynomial               *)
procedure polyeval(x : polyptr;       (* evaluate polynomial x in s          *)
                   s : complex;       (* at complex value s                  *)
                   var result : complex); (* assign to result                *)
procedure polyform(a : rootstack;     (* form a polynomial b from the
                                                        roots of rootstack a *)
                   var b : polyptr);
procedure polymult(xx, yy : polyptr;
                   var z : polyptr);  (* multiply two polynomials            *)
procedure polynegate(x : polyptr);
function polyorder(z : polyptr) : byte; (* order of a polynomial             *)
procedure polypower(i : byte;           (* raise a polynomial x to power i *)
                   x  : polyptr;
                   var y : polyptr);
procedure polyprint(x : polyptr);     (* writeln for polynomial              *)
procedure polyscale(x : polyptr;      (* multiply polynomial x by            *)
                   scalar : complex); (* complex number scalar               *)
procedure polyunary(x : polyptr);     (* make the polynomial x unary         *)
(* i.e. the leading coef = 1                                                 *)
procedure rootpush(r : complex;       (* add root r to a rootstack l         *)
                   var l : rootstack);
procedure rootpop(var l : rootstack;      (* get root from a rootstack l *)
                  var r : complex);
procedure rootclear(var l : rootstack);   (* clear a rootstack l             *)
procedure rootrotate(n : byte;var l : rootstack);(* rotate rootstack l by n  *)
                                            (* so that last moves toward 1st *)
procedure rootcopy(s : rootstack;     (* copy a rootstack from s to d        *)
                   var d: rootstack);

const
  cone : complex = (re : 1.0; im : 0.0);
  czero: complex = (re : 0.0; im : 0.0);
  ci   : complex = (re : 0.0; im : 1.0);

implementation
var
  ln10          : real  ;

function floor (x : real  ) : real  ; (* the next lowest integer             *)

(* note that int will not work when x is a negative number *)
begin
  if x >= 0.0 then
    floor := int(x)
  else                                (* use int for positive x              *)
    if frac(x) = 0.0 then
      floor := x
    else                              (* no shift on exact integer           *)
      floor := - int(1 - x)           (* round away from zero                *)
end;                                  (* floor                               *)

function ceiling (x : real  ) : real  ; (* the next highest integer          *)
begin
  if x <= 0.0 then
    ceiling := int(x)
  else                                (* use int for negative x              *)
    if frac(x) = 0.0 then
      ceiling := x
    else                              (* no shift on exact integer           *)
      ceiling := 1 - int(- x)         (* shift x to negative                 *)
end;                                  (* ceiling                             *)

function log10 (x : real  ) : real  ; (* base 10 log of x                    *)
begin                                 (* ln(10) supplied for speed           *)
  log10 := ln(x) / ln10               (* easily derived                      *)
end;                                  (* log10                               *)

function exp10 (x : real  ) : real  ; (* 10 raised to the x power            *)
begin                                 (* ln(10) supplied for speed           *)
  exp10 := exp(x * ln10)              (* easily derived                      *)
end;                                  (* exp10                               *)

function pwrxy (x, y : real  ) : real  ; (* raise x to the power y           *)
begin
  if (y = 0.0) then
    pwrxy := 1.0
  else
    if (x <= 0.0) and (frac(y) = 0.0) then
      if (frac(y / 2)) = 0.0 then
        pwrxy := exp(y * ln(abs(x)))
      else
        pwrxy := - exp(y * ln(abs(x)))
    else
      pwrxy := exp(y * ln(x));
end;                                  (* pwrxy                               *)

function qdbv (volts : real  ) : real  ; (* convert from volts to db         *)
begin
  qdbv := 20.0 * log10(volts)
end;                                  (* qdbv                                *)

function qdbw (watts : real  ) : real  ; (* convert from watts to db         *)
begin
  qdbw := 10.0 * log10(watts)
end;                                  (* qdbw                                *)

function qwatts (db : real  ) : real  ; (* convert from db to watts          *)
begin
  qwatts := exp10(db / 10.0);
end;                                  (* qwatts                              *)

function qvolts (db : real  ) : real  ; (* convert from db to volts          *)
begin
  qvolts := exp10(db / 20.0);
end;                                  (* qvolts                              *)

function sinh (x : real  ) : real  ;  (* hyperbolic sine                     *)
begin
  sinh := 0.5 * (exp(x) - exp(- x))
end;                                  (* sinh                                *)

function cosh (x : real  ) : real  ;  (* hyperbolic cosine                   *)
begin
  cosh := 0.5 * (exp(x) + exp(- x))
end;                                  (* cosh                                *)

function tanh (x : real  ) : real  ;  (* hyperbolic tangent                  *)
begin
  x := exp(2.0 * x);
  tanh := (x - 1.0) / (x + 1.0)
end;                                  (* tanh                                *)

function isinh (x : real  ) : real  ; (* arc hyperbolic sine                 *)
begin
  isinh := ln(sqrt(1.0 + x * x) + x)
end;                                  (* isinh                               *)

function icosh (x : real  ) : real  ; (* arc hyperbolic cosine               *)
begin
  icosh := ln(x + sqrt(x * x - 1.0))
end;                                  (* icosh                               *)

function itanh (x : real  ) : real  ; (* arc hyperbolic tangent              *)
begin
  itanh := ln((1.0 + x) / (1.0 - x))
end;                                  (* itanh                               *)

function arcsin (x : real  ) : real  ; (* arc sine using tp arctan function  *)
begin                                 (* answer returned in radians          *)
  if x = 1.0 then
    arcsin := pi / 2.0
  else
    if x = - 1.0 then
      arcsin := pi / - 2.0
    else
      arcsin := arctan(x / sqrt(1.0 - sqr(x)))
end;                                  (* arcsin                              *)

function arccos (x : real  ) : real  ; (* inverse cosine using tp arctan     *)
begin                                 (* answer returned in radians          *)
  if x = 0.0 then
    arccos := pi / 2.0
  else
    if x < 0.0 then
      arccos := pi - arctan(sqrt(1.0 - sqr(x)) / abs(x))
    else
      arccos := arctan(sqrt(1.0 - sqr(x)) / abs(x))
end;                                  (* arccos                              *)

function atan2(x, y : real  ) : real  ; (* arctan function with quadrant check
 x is real axis value or denominator, y is imaginary axis value or numerator *)
begin                                 (* answer returned in radians          *)
  if y <> 0.0 then
    if x <> 0.0 then                  (* point not on an axis                *)
      if x > 0.0 then                 (* 1st or 4th quadrant use std arctan  *)
        atan2 := arctan(y / x)
      else
        if y > 0.0 then               (* 2nd quadrant                        *)
          atan2 := pi + arctan(y / x)
        else
          atan2 := arctan(y / x) - pi (* 3rd quadrant                        *)
    else                              (* point on the y axis                 *)
      if y >= 0.0 then
        atan2 := pi / 2.0             (* positive y axis                     *)
       else
        atan2 := - pi / 2.0           (* negative y axis                     *)
   else                               (* point on the x axis                 *)
    if x >= 0.0 then
      atan2 := 0.0                    (* positive x axis                     *)
     else
      atan2 := - pi                   (* negative x axis                     *)
end;                                  (* atan2                               *)

function tan (x : real  ) : real  ;   (* tangent of x                        *)
begin
  tan := sin(x) / cos(x)
end;                                  (* tan                                 *)

function gauss (mean, stddev : real  ) : real  ; (* gaussian random number   *)
var
  i             : byte;               (* index for loop                      *)
  t             : real  ;             (* temporary variable                  *)

begin                                 (* based on the central limit theorem  *)
  t := - 6.0;                         (* maximum deviation is 6 sigma, remove
                                         the mean first                      *)
  for i := 1 to 12 do
    t := t + random;                  (* 12 uniform over 0 to 1              *)
  gauss := mean + t * stddev          (* adjust mean and standard deviation  *)
end;                                  (* gauss                               *)

function residue (radix, number : real  ) : real  ; (* remainder of
                                         radix/number                        *)

(* uses apl residue definition *)
begin
  residue := number - radix * floor(number / radix)
end;                                  (* residue                             *)

function minimum (a, b : real  ) : real  ; (* the minimum of a and b         *)
begin
  if a < b then
    minimum := a
  else
    minimum := b
end;                                  (* minimum                             *)

function maximum (a, b : real  ) : real  ; (* the maximum of a and b         *)
begin
  if a < b then
    maximum := b
  else
    maximum := a
end;                                  (* maximum                             *)

procedure cmult(c, d : complex;
                   var result : complex); (* multiply two complex numbers    *)
begin
  result.re := c.re * d.re - c.im * d.im; (* real part                       *)
  result.im := c.re * d.im + c.im * d.re; (* imaginary part                  *)
end;

procedure cadd(c, d : complex;
                   var result : complex); (* add two complex numbers         *)
begin
  result.re := c.re + d.re;           (* real part                           *)
  result.im := c.im + d.im;           (* imaginary part                      *)
end;

procedure csub(c, d : complex;
                   var result : complex); (* subtract d from c complex number
                                                                             *)
begin
  result.re := c.re - d.re;           (* real part                           *)
  result.im := c.im - d.im;           (* imaginary part                      *)
end;

function cmag (c : complex) : real  ; (* magnitude of a complex number       *)
begin
  cmag := sqrt(sqr(c.re) + sqr(c.im));
end;

procedure cmake(a, b : real  ;
                   var result : complex); (* form a complex number           *)
begin
  result.re := a;
  result.im := b;
end;

procedure cconj(a : complex;
                   var result : complex); (* complex conjugate               *)
begin
  result.re := a.re;
  result.im := - a.im;
end;

procedure cexp(a : complex;
                   var result : complex); (* exponential of a complex number *)
var
  magnitude     : real  ;

begin                               (* exp(real+j imag)=exp(real)exp(j imag) *)
  magnitude := exp(a.re);
  result.re := magnitude * cos(a.im); (* eulers equation                     *)
  result.im := magnitude * sin(a.im);
end;

procedure csqr(a : complex;
                   var result : complex); (* square of a complex number      *)
begin                                 (* sqr(real + j imag)                  *)
  result.re := sqr(a.re) - sqr(a.im);
  result.im := 2.0 * a.re * a.im;
end;

procedure csqrt(a : complex;
                   var result : complex); (* sqrt of a complex number        *)
var
  magnitude, phase : real  ;          (* a to be written as mag*exp(j phase) *)

begin                                 (* solve sqrt(mag)*exp(j .5*phase      *)
  phase := 0.5 * atan2(a.re, a.im);
  magnitude := sqrt(sqrt(sqr(a.re) + sqr(a.im)));
  result.re := magnitude * cos(phase); (* eulers equation                    *)
  result.im := magnitude * sin(phase);
end;

procedure cln(a : complex;
                   var result : complex); (* natural log of complex a        *)
begin                                 (* a to be written as mag*exp(j phase) *)
  result.re := 0.5 * ln(sqr(a.re) + sqr(a.im));
  result.im := atan2(a.re, a.im);
end;

procedure cpwrxy(x, y : complex;
                   var result : complex); (* raise x to the y power          *)
var
  temp          : complex;

begin
  if (x.re = 0.0) and (x.im = 0.0) then (* avoid taking log of 0             *)
    begin
      result.re := 0.0;
      result.im := 0.0;
    end
  else
    begin
      cln(x,temp);
      cmult(y,temp,temp);
      cexp(temp,result);
    end
end;

procedure csinh(a : complex;
                   var result : complex); (* hyperbolic sine of complex a    *)
begin
  result.re := cos(a.im) * sinh(a.re);
  result.im := sin(a.im) * cosh(a.re);
end;

procedure ccosh(a : complex;
                   var result : complex); (* hyperbolic cosine of complex a  *)
begin
  result.re := cos(a.im) * cosh(a.re);
  result.im := sin(a.im) * sinh(a.re);
end;

procedure ctanh(a : complex;
                   var result : complex); (* hyperbolic tangent of complex a *)
var
  denom         : real  ;

begin
  denom := cos(2.0 * a.im) + cosh(2.0 * a.re);
  result.re := sinh(2.0 * a.re) / denom;
  result.im := sin(2.0 * a.im) / denom;
end;

procedure csin(a : complex;
                   var result : complex); (* sine of complex a               *)
begin
  result.re := sin(a.re) * cosh(a.im);
  result.im := cos(a.re) * sinh(a.im);
end;

procedure ccos(a : complex;
                   var result : complex); (* cosine of complex a             *)
begin
  result.re := cos(a.re) * cosh(a.im);
  result.im := - sin(a.re) * sinh(a.im);
end;

procedure ctan(a : complex;
                   var result : complex); (* tangent of complex a            *)
var
  denom         : real  ;

begin
  denom := cos(2.0 * a.re) + cosh(2.0 * a.im);
  result.re := sin(2.0 * a.re) / denom;
  result.im := sinh(2.0 * a.im) / denom;
end;

procedure cinv(a : complex;
                   var result : complex); (* complex inverse                 *)
var
  scalar        : real  ;

begin
  scalar := sqr(a.re) + sqr(a.im);
  result.re := a.re / scalar;
  result.im := - a.im / scalar;
end;

procedure cdiv(num, denom : complex;
                   var result : complex); (* complex division   *)

(* returns num/denom *)
var
  scalar        : real  ;

begin

 (****************************************************************************)
 (* try to avoid overflow by normalizing the denominator                     *)
 (****************************************************************************)
  if (abs(denom.re) > abs(denom.im)) then
    begin
      scalar := denom.re;
      denom.im := - denom.im / scalar;
(*    denom.re := 1.0;  is implied *)
      scalar := (sqr(denom.im) + 1.0) * scalar;
      result.re := (num.re - num.im * denom.im) / scalar;
      result.im := (num.re * denom.im + num.im) / scalar;
    end
  else
    begin
      scalar := denom.im;
      denom.re := denom.re / scalar;
(*    denom.im := -1.0;  is implied *)
      scalar := (sqr(denom.re) + 1.0) * scalar;
      result.re := (num.re * denom.re + num.im) / scalar;
      result.im := (num.im * denom.re - num.re) / scalar;
    end;
end;

procedure carcsin(a : complex;
                   var result : complex); (* inverse sine of complex a       *)
var
  temp          : complex;

begin
  csqr(a, temp);
  csub(cone, temp, temp);
  csqrt(temp, temp);
  cmult(ci, a, a);
  csub(temp, a, temp);
  cln(temp, temp);
  cmult(ci, temp, result)
end;

procedure carccos(a : complex;
                   var result : complex); (* inverse cosine of complex a     *)
var
  temp          : complex;

begin
  csqr(a, temp);
  csub(temp, cone, temp);
  csqrt(temp, temp);
  csub(a, temp, temp);
  cln(temp, temp);
  cmult(ci, temp, result)
end;

procedure carctan(a : complex;
                   var result : complex); (* inverse tangent of complex a    *)
var
  temp          : real  ;

begin
  temp := sqr(a.re);
  result.re := 0.5 * atan2((1.0 - temp - sqr(a.im)),2.0 * a.re);
  result.im := 0.25 * ln((sqr(1.0 + a.im) + temp) / (sqr(1.0 - a.im) + temp));
end;

procedure polyclear(var ptr : polyptr); (* remove a polynomial               *)
var
  tempptr       : polyptr;

begin
  while ptr <> nil do                 (* for all polynomial coefficients     *)
    begin
      tempptr := ptr^.link;           (* store link to the next coefficient  *)
      dispose(ptr);                   (* free memory at current coefficient  *)
      ptr := tempptr;                 (* go to next coefficient              *)
    end;
end;

procedure polynext(var ptr : polyptr); (* new linked list element            *)
begin
  new(ptr);                           (* get memory space for a coefficient  *)
  ptr^.coeff := czero;                (* set the coefficient to zero         *)
  ptr^.link := nil;                   (* next element in the list is
                                         nonexistant                         *)
end;

function polyorder (z : polyptr) : byte; (* order of a polynomial            *)
var
  orderctr      : byte;               (* maximum order is 255                *)

begin
  orderctr := 0;                      (* return 0 for polynomial with one
                                         element                             *)
  while z^.link <> nil do             (* last element in list ?              *)
    begin
      inc(orderctr);                  (* count number of times through loop  *)
      z := z^.link;                   (* go to next coefficient              *)
    end;
  polyorder := orderctr;
end;

procedure polynew(n : byte;           (* create a zero polynomial of length n>0
                                                                             *)
                   var z : polyptr);  (* ** z must be an existing polynomial **
                                                                             *)
var
  i             : byte;               (* maximum order is 255                *)
  ztemp         : polyptr;            (* to move through coefficient list    *)

begin
  polyclear(z);                       (* free existing polynomial location   *)
  polynext(z);                        (* get zeroth coefficient              *)
  ztemp := z;                         (* z stays at first element of list    *)
  for i := 1 to n do                  (* add other coefficients to the list  *)
    begin
      polynext(ztemp^.link);
      ztemp := ztemp^.link;
    end;
end;

procedure polyassign(x : polyptr;     (* generate new polynomial at y with   *)
                   var y : polyptr);  (* same coefficients as poly at x      *)
var
  i             : byte;               (* length of polynomial x              *)
  ytemp, ytstart : polyptr;           (* to move through the list            *)
  (* maximum order is 255                                                    *)

begin
  if x <> nil then
    begin
      i := polyorder(x);              (* order of x                          *)
      ytemp := nil;                   (* initialize ytemp                    *)
      polynew(i, ytemp);              (* get new poly of same order          *)
      ytstart := ytemp;               (* remember first element of list      *)
      while x <> nil do               (* go through x                        *)
        begin
          ytemp^.coeff := x^.coeff;   (* assign x coef to y coef             *)
          ytemp := ytemp^.link;       (* locate next element of y            *)
          x := x^.link;               (* locate next element of x            *)
        end;
      polyclear(y);                   (* in case polyassign(p1,p1)           *)
      y := ytstart;
    end
  else polyclear(y);
end;

procedure root_poly(root : complex;   (* form polynomial s-root              *)
                   var result : polyptr);
var
  resulttemp    : polyptr;            (* to move through two element list    *)

begin
  polynew(1, result);                 (* generate two element list           *)
  resulttemp := result;               (* keep result at 1st element of list  *)
  resulttemp^.coeff.im := - root.im;  (* zeroth coefficient                  *)
  resulttemp^.coeff.re := - root.re;
  resulttemp := resulttemp^.link;     (* move to s*1 coefficient             *)
  resulttemp^.coeff := cone;          (* set it equal to 1 + j0              *)
end;

procedure polymult(xx, yy : polyptr;
                   var z : polyptr);
var
  x, y, ypt, zpt, zptsave : polyptr;
  result        : complex;
  i             : byte;               (* maximum order is 255                *)

begin
  x := nil;                           (* don't give polyassign trash         *)
  y := nil;                           (* don't give polyassign trash         *)
  polyassign(xx, x);                  (* copy xx, in case polymult(a,a,a)    *)
  polyassign(yy, y);                  (* copy yy, in case polymult(a,a,a)    *)
  i := polyorder(x) + polyorder(y);   (* resultant polynomial order          *)
  polyclear(z);                       (* release existing z                  *)
  polynew(i, z);                      (* make a list of length i             *)
  zptsave := z;                       (* keep z at start of the list         *)
  while x <> nil do                   (* for each element of x               *)
    begin
      zpt := zptsave;                 (* remember start of list 2nd loop     *)
      ypt := y;                       (* remember start of list 2nd loop     *)
      while ypt <> nil do             (* 2nd loop goes over elements of y    *)
        begin                         (* scale y polynomial by x coeff       *)
          cmult(x^.coeff, ypt^.coeff, result);
          cadd(result, zpt^.coeff, zpt^.coeff);
          ypt := ypt^.link;           (* next element in y                   *)
          zpt := zpt^.link;           (* next element in z                   *)
        end;
      zptsave := zptsave^.link;       (* begin at next higher element in z   *)
      x := x^.link;                   (* by multiplying by next x element    *)
    end;
  polyclear(x);                       (* release x storage                   *)
  polyclear(y);                       (* release y storage                   *)
end;

procedure polyform(a : rootstack;     (* form a polynomial b from the
                                                        roots of rootstack a *)
                   var b : polyptr);
var
  tply          : polyptr;             (* will hold the 1st order polynomial *)
  duproots      : rootstack;           (* get a duplicate rootstack *)
  troot         : complex;

begin
  polyclear(b);                        (* erase b *)
  if a <> nil then
  begin
   duproots := nil;                    (* initialize duproots *)
   rootcopy(a,duproots);               (* don't destroy the contents of a *)
   rootpop(duproots,troot);            (* get first root *)
   root_poly(troot,b);                 (* form 1st order poly *)
   tply := nil;                        (* initialize tply *)
   while duproots <> nil do            (* for other each root *)
         begin
         rootpop(duproots,troot);
         root_poly(troot,tply);       (* form 1st order poly *)
         polymult(tply,b,b);               (* multiply by current b *)
         end;
   polyclear(tply);                        (* free temporary polynomial *)
   rootclear(duproots);                    (* free temporary rootlist *)
  end;
end;

procedure polyprint(x : polyptr);
begin
  while x <> nil do
    begin
      writeln(x^.coeff.re, x^.coeff.im);
      x := x^.link;
    end;
end;

procedure polypower(i : byte;           (* raise a polynomial x to power i *)
                   x  : polyptr;
                   var y : polyptr);    (* assign to polynomial y *)
var
  n             : byte;
  xtemp         : polyptr;

begin
  if i = 0 then                         (* expression to the 0 power is 1 *)
    begin
      polyclear(y);
      polynext(y);
      y^.coeff.re := 1.0;
    end
  else                                  (* not 0 power *)
    begin
      xtemp := nil;                     (* initialize xtemp *)
      polyassign(x, xtemp);             (* in case called polypwr(3,a,a) *)
      polyassign(xtemp, y);             (* first power *)
      n := 1;
      while n < i do                    (* continuing powers *)
        begin
          polymult(xtemp, y, y);        (* multiply by x *)
          inc(n);                       (* current power *)
        end;                          (* while                               *)
      polyclear(xtemp);
    end                               (* if                                  *)
end;

procedure polyeval(x : polyptr;       (* evaluate polynomial x in s          *)
                   s : complex;       (* at complex value s                  *)
                   var result : complex); (* assign to result                *)
var
  tempr, temps  : complex;

begin
  temps := s;                         (* in generating powers of s           *)
  if x <> nil then                    (* any coefficients in x               *)
    begin
      result := x^.coeff;             (* add the constant of the polynomial  *)
      x := x^.link;                   (* go to s*1 coefficient               *)
      while x <> nil do               (* continue for each coefficient       *)
        begin
          cmult(x^.coeff, temps, tempr); (* multiply by s*n                  *)
          cadd(result, tempr, result); (* add to running sum                 *)
          cmult(s, temps, temps);     (* form s*(n+1)                        *)
          x := x^.link;               (* next order                          *)
        end;                          (* while                               *)
    end;
end;

procedure polyadd(x, y : polyptr;     (* add polynomials x and y             *)
                   var z : polyptr);  (* assign to polynomial z              *)
var
  xtemp, ytemp, tptr1, tptr2, tptr3 : polyptr;

begin
  xtemp := nil;                       (* initialize undefined polynomials    *)
  ytemp := nil;
  polyassign(x, xtemp);               (* temporary working polynomials       *)
  polyassign(y, ytemp);
  polyclear(z);                       (* in case of polyadd(p1,p2,p2)        *)
  if polyorder(xtemp) > polyorder(ytemp) then (* want to add the smaller to
                                         larger                              *)
    begin                             (* z will be same order of the larger  *)
      tptr1 := xtemp;
      tptr2 := ytemp;
    end
  else
    begin
      tptr1 := ytemp;
      tptr2 := xtemp;
    end;
  polyassign(tptr1, z);               (* z is 0 + the larger                 *)
  tptr3 := z;                         (* keep z at start of polynomial       *)
  while tptr2 <> nil do               (* for each coeff of the smaller       *)
    begin
      cadd(tptr3^.coeff, tptr2^.coeff, tptr3^.coeff); (* z + smaller         *)
      tptr3 := tptr3^.link;           (* next z coef                         *)
      tptr2 := tptr2^.link;           (* next smaller coef                   *)
    end;
  polyclear(xtemp);                   (* free xtemp and ytemp storage        *)
  polyclear(ytemp);
end;

procedure polynegate(x : polyptr);    (* change poly in s to poly in -s      *)
var
  temp          : complex;            (* to be 1+j0 or -1+j0                 *)

begin
  temp := cone;                       (* initially 1+j0                      *)
  while x <> nil do                   (* for each coefficient                *)
    begin
      cmult(x^.coeff, temp, x^.coeff); (* multiply by 1 or -1                *)
      temp.re := - temp.re;           (* change 1 to -1 or -1 to 1           *)
      x := x^.link;                   (* next coefficient                    *)
    end;
end;

procedure polyscale(x : polyptr;      (* multiply polynomial x by            *)
                   scalar : complex); (* complex number scalar               *)
begin
  while x <> nil do                   (* go through each element of x        *)
    begin
      cmult(scalar, x^.coeff, x^.coeff); (* scale the coefficient            *)
      x := x^.link;                   (* locate next element of x            *)
    end;
end;

procedure polyunary(x : polyptr);     (* make the polynomial x unary         *)
(* i.e. the leading coef = 1                                                 *)
var
  xtemp         : polyptr;
  scalar        : complex;

begin
  xtemp := x;                         (* remember the start of the list      *)
  while x <> nil do                   (* go through each element of x        *)
    begin                             (* to locate last element              *)
      scalar := x^.coeff;             (* looking for the last coefficient    *)
      x := x^.link;                   (* locate next element of x            *)
    end;                              (* while                               *)
  cinv(scalar, scalar);               (* inverse of last element of x        *)
  polyscale(xtemp, scalar);           (* will make last element = 1.0        *)
end;

procedure polydivide(num, denom : polyptr; (* synthetic division *)
                     var quotient, remainder: polyptr);
var
  tempn, tempd, tempq, tempr : polyptr;
  ordernum, orderdenom, orderquo  : byte;
  leadingcoef, leadingcoefd : complex;
begin
  ordernum := polyorder(num);
  orderdenom := polyorder(denom);
  if ordernum > orderdenom then
    begin
      tempn := nil;                   (* initialize temporary numerator     *)
      tempd := nil;                   (* initialize temporary denominator   *)
      polyassign(num,tempn);          (* in case polydivide(a,b,a,b)        *)
      polyassign(denom,tempd);        (* in case polydivide(a,b,a,b)        *)
      while tempn <> nil do           (* find the leading coef of the num   *)
        begin
          leadingcoef := tempn^.coeff;
          tempn       := tempn^.link;
        end;
      while tempd <> nil do           (* find the leading coef of the denom *)
        begin
          leadingcoefd:= tempd^.coeff;
          tempd       := tempd^.link;
        end;
      cdiv(leadingcoef,leadingcoefd,leadingcoef);  (* quotient leading coef *)
      tempq := nil;                   (* initialize temporary quotient      *)
      polyclear(quotient);
      polynew((ordernum-orderdenom),quotient);
      tempr := nil;                   (* initialize temporary remainder     *)

      polyclear(quotient);
      polyclear(remainder);

    end
  else  (* denominator cannot divide into numerator *)
    begin
      polyassign(num,remainder);
      polyclear(quotient);
    end;
end;

procedure rootpush(r : complex;       (* add root r to a rootstack l         *)
                   var l : rootstack);
var
  newspace : rootstack;
begin
  new(newspace);                      (* get memory space for new root       *)
  newspace^.coeff := r;               (* set the coefficient to r            *)
  newspace^.link  := l;               (* next element in the list is l       *)
  l               := newspace;        (* new top of stack                    *)
end;

procedure rootpop(var l : rootstack;      (* get root from a rootstack l *)
                  var r : complex);
var
  ltemp : rootstack;
begin
  if l <> nil then
    begin
      r := l^.coeff;                  (* assign r from first stack element   *)
      ltemp := l;                     (* remember top stack element location *)
      l := l^.link;                   (* move l to second member of stack    *)
      dispose(ltemp);                 (* free memory at old top of stack     *)
    end;
end;

procedure rootclear(var l : rootstack);   (* clear a rootstack l             *)
var
  dummy : complex;
begin
  while l <> nil do rootpop(l,dummy); (* pop until empty                     *)
end;

procedure rootrotate(n : byte;var l : rootstack);(* rotate rootstack l by n  *)
                                            (* so that last moves toward 1st *)
var
  marktop, temp  : rootstack;
  count : byte;
begin
  if (l <> nil) and (n <> 0) then
    begin                                   (* make the stack a ring *)
      marktop := l;                         (* link to top of l *)
      while l <> nil do                     (* search to the end of the list *)
        begin
          temp := l;                        (* previous element *)
          l    := l^.link;
        end;
      temp^.link := marktop;           (* wrap the last element to the first *)
      temp := marktop;                 (* move temp back to top of the list  *)

(* in the following we locate the bottom of the list which is currently      *)
(* linked to the first element of the list.  set the link at the bottom to   *)
(* nil, and its link (being the top) to l                                    *)

      for count := 1 to n do           (* will locate bottom of list *)
          temp := temp^.link;
      l := temp^.link;                 (* pointer to the top of list *)
      temp^.link := nil;               (* split the ring *)
    end;
end;

procedure rootcopy(s : rootstack;     (* copy a rootstack from s to d        *)
                   var d: rootstack);
var
  dtemp, dtempprev : rootstack;
begin
  if s <> d then                        (* if = then exit *)
  begin
    if d <> nil then rootclear(d);      (* clear existing stack *)
    if s <> nil then
    begin
      new(dtemp);                       (* first element *)
      d := dtemp;                       (* is at top of new stack *)
      d^.coeff := s^.coeff;             (* copy the first root *)
      d^.link  := nil;                  (* don't know if another element *)
      s := s^.link;                     (* move to second coeff *)
      while s <> nil do
        begin
        writeln('rootcopy');
        dtempprev := dtemp;
        new(dtemp);
        dtemp^.coeff := s^.coeff;       (* copy the root *)
        dtempprev^.link := dtemp;       (* tie to previous stack element *)
        dtemp^.link := nil;
        s := s^.link;
        end; (* while *)
    end; (* if *)
  end;   (* if *)
end; (* rootcopy *)
begin
  randomize;
  ln10 := ln(10.0)
end.

