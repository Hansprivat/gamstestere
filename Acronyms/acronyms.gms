*
$oneolcom
$oninline

set gdataset / gdacronym, gdnumber /;
set g /g1*g4/;
acronym typeA, typeB, typeC;
table gdata(g,gdataset)
     gdacronym   gdnumber
g1     typeA        1
g2                  2
g3     typeC
g4
;

display "original input", gdata;

gdata(g,'gdacronym')$(not gdata(g,'gdacronym')) = gdata(g,'gdnumber');

display "adjusted input: missing gdacronym value replaced by gdnumber value", gdata;






* -------------  NOGET HELT ANDET ----------------------------------------------
acronym const, varisum  ;
set a/a1*a3/;
set b/b1*b3/;
parameter pa1(a,b,*)
/
  a1 . b1 .  const  0.6
  a1 . b1 .  soren varisum
  a1 . b2 .  const  0.95
  a1 . b2 .  soren varisum

/;

display pa1;

acronym varisumin, varisumout;
set constorsum /const, varisumin, varisumout/;
parameter pa2(a,b,constorsum)
/
  a1 . b1 .  const     0.6
  a1 . b1 .  varisumin varisumin
  a1 . b2 .  const     0.95
  a1 . b2 .  varisumin varisumin
  a1 . b3 .  const     1.2
  a2 . b1 .  const     0.53
  a3 . b1 .  const     0.6
  a3 . b1 .  varisumout varisumout
  a3 . b2 .  const     0.95
  a3 . b2 .  varisumout varisumout
/;
display pa2;

parameter pa3(a,b,constorsum)
/
  a1 . b1 .  const     0.6
  a1 . b1 .  varisumin 1
  a1 . b2 .  const     0.95
  a1 . b2 .  varisumin 1
  a1 . b3 .  const     1.2
  a2 . b1 .  const     0.53
  a3 . b1 .  const     0.6
  a3 . b1 .  varisumout 1
  a3 . b2 .  const     0.95
  a3 . b2 .  varisumout 1
/;
display "lidt anden version end p1: " , pa3;

set constandvari /const, vari/;

parameter pa4(a,b,constandvari)
/
  a1 . b1 .  const     0.6
  a1 . b1 .  vari varisumin
  a1 . b2 .  const     0.95
  a1 . b2 .  vari varisumin
  a1 . b3 .  const     1.2
  a2 . b1 .  const     0.53
  a3 . b1 .  const     0.6
  a3 . b1 .  vari varisumout
  a3 . b2 .  const     0.95
  a3 . b2 .  vari varisumout
/;
display "lidt anden version end p : " , pa4;
