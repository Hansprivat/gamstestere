* Compare with FlexDemandStorage

$ontext
Hans 20150330

Flexible demand with energy constraint.
The hourly demand (MW) is flexible (up to a certain amount VDEFTIMEFLEX_bound).
However, over a certain time interval the accumulated activated flexibility is zero.
(E.g., over such period a certain energy must be consumed).
Example of application: electric vehicles (with or without vehicle-to-grid); electric freezer; ..
The present implementation does not require explicit data for 'base' demand, so this is assumed part of DE_VAR_T;
some care between VDEFTIMEFLEX_lo/_up and the assumed hourly nominal demand is required??

Example:
Assume a cooling storage with a default consumption during night-time (17.00 - 7.00, an interval of 14 hours) of 56 MWh.
This load is included in the Region's electricity demand DE, assuming that the consumption during night-time constant, i.e., 4 MWh per hour.
By appropriate action, this consumption can be shifted somewhat between the hours.
More specifically, assume that the consumption will be 28 MWh during the period 17.00 - 24.00 and 28 MWh during the period 24.00 - 7.00.
With set T(TTT) /T001*T168/ representing the hours of the week (with T001 being the hour 0.00-1.00 etc.) and the IDs given below this may be modelled as follows.
PARAMETER  VDEFTIMEFLEXSUM(T) ""
/
T001  EPS, T008  EPS, T018  EPS
T025  EPS, T032  EPS, T042  EPS
etc.
/
and so on for T042, T049, T059, T066, T073, T080, T090, T097, T104, T114, T121, T128, T138, T145, T152, T162.
Further input data IVDEFTIMEFLEX_lo and IVDEFTIMEFLEX_up may be assumed to be e.g. -4 and 8, respectively.
With the above input data there will be fTIMEFLEX demand during night-time as described.
However, there will be fTIMEFLEX demand during daytime (7.00 - 17.00 i.e., T008 - T017 the first day of the week).
If this is not intended, then let VDEFTIMEFLEXSUM be eps for corresponding T (T008-T017, T032-T041 and so on).

??: Additional refinement may be achieved by appropriate values in VDEFTIMEFLEXSUM.
Thus, for instance it may be required that the temperature in the cooling storge is lowered from the first hour in the nigt to that last hour.
This may be achieved by having a larger value for VDEFTIMEFLEXSUM at the last moment of the night than at the first moment,
e.g., neeeej, det er sværere - for det betyder så, at der blive lavere temperatur i slutningen af dagen end i begiyndelsen
(hvilket kan være ok, skall lige tænke; og der er jo samsil med den antagne DE-profil):??


$offtext


$oninline
$oneolcom
option limrow = 300;



SCALAR ISCALAR1 "Absolute value of integer part",ISCALAR2 "Fractional remainder of abs-value if postive, 1 otherwise";
*set s /S01*s01/;  not in use
set t / T001*t168/;

scalar ihoursinst "Proxy for time segment length (h)" /1/

parameter elpricehelper(t) "";

parameter DEFTIMEFLEXSUM(t) "The T for which there is energy balance between two consecutive start-of-T (indicated by non-zero values) (%)";

free variable vobj "";
free variable VDEFTIMEFLEX(t)    "The activated time-flexible demand (MW)";
free variable VDEFTIMEFLEXSUM(t) "The start-of-T accumulated activated time-flexible demand (MWh)";

equation qobj;
equation QDEFTIMEFLEXSUM(t);

model DEFTIMEFLEX /all/;

qobj..
 vobj =E= sum(t, elpricehelper(t) * VDEFTIMEFLEX(t)*ihoursinst);

QDEFTIMEFLEXSUM(t)..
      VDEFTIMEFLEXSUM(t++1) =E= VDEFTIMEFLEXSUM(t) + VDEFTIMEFLEX(t)*ihoursinst;


* DATA -------------------------------------------------------------------------

elpricehelper(t) = sin(ord(t)/(2*3.14159)) + 2;

scalar IVDEFTIMEFLEX_lo   /-2/;
scalar IVDEFTIMEFLEX_up   /4/;

* "The energy balance between two consecutive start-of-T with non-zero values is zero (%)"
* Use 0 or empty entry to indicate unconstrained this T. Use Eps to indicate 0 'SUM'/'VOLUME' this T.
* Using INF or -INF will generate an error.

parameter DEFTIMEFLEXSUM(t)
/
/*
t024 EPS
t048 eps
t072 11
t096 1
   t100 7
t120 EPS
t144 0
t168 1
*/
T001  EPS, T008  EPS
T018  EPS
T025  EPS
T032  EPS
T042  EPS
T049  EPS
T056  EPS
T066  EPS
T073  EPS
T080  EPS
T090  EPS
T097  EPS
T104  EPS
T114  EPS
T121  EPS
T128  EPS
T138  EPS
T145  EPS
T152  EPS
T162  EPS
/;


* WITH DO FLEX DURING day 1 (ONLY):
  DEFTIMEFLEXSUM('T008') = eps;
  DEFTIMEFLEXSUM('T009') = eps;
  DEFTIMEFLEXSUM('T010') = eps;
  DEFTIMEFLEXSUM('T011') = eps;
  DEFTIMEFLEXSUM('T012') = eps;
  DEFTIMEFLEXSUM('T013') = eps;
  DEFTIMEFLEXSUM('T014') = eps;
  DEFTIMEFLEXSUM('T015') = eps;
  DEFTIMEFLEXSUM('T016') = eps;
  DEFTIMEFLEXSUM('T017') = eps;



* error2.inc:
LOOP(T$((DEFTIMEFLEXSUM(t) EQ INF) OR (DEFTIMEFLEXSUM(t) EQ -INF)),
   DISPLAY "Error: DEFTIMEFLEXSUM cannot be INF or -INF";
);


VDEFTIMEFLEX.up(t) = IVDEFTIMEFLEX_up;
VDEFTIMEFLEX.lo(t) = IVDEFTIMEFLEX_lo;

* Set VDEFTIMEFLEXSUM.fx to zero for the t for which balanceinterval has a value.
* Version 1:
* Since VDEFTIMEFLEXSUM is a free variable and subject to no upper or lower bound its is possible to use the arbitrary value 0
*VDEFTIMEFLEXSUM.fx(t)$DEFTIMEFLEXSUM(t) = 0;
* Version 2:
* Permitting requirement that net energy balance between two consequtive T with values is non-zero.
VDEFTIMEFLEXSUM.fx(t)$DEFTIMEFLEXSUM(t) = DEFTIMEFLEXSUM(t);
display VDEFTIMEFLEXSUM.l, VDEFTIMEFLEX.LO, VDEFTIMEFLEX.UP;



* SOLVE: -----------------------------------------------------------------------
SOLVE DEFTIMEFLEX MAXIMIZING vobj using lp;


EXECUTE_UNLOAD "all1.gdx";

* ===================================================================================================================================================
* ===================================================================================================================================================
* ===================================================================================================================================================
* ===================================================================================================================================================
* Prøver lige noget andet:
* Compare with FlexDemandStorage - maybe better there?
* ===================================================================================================================================================
* ===================================================================================================================================================
* ===================================================================================================================================================
* ===================================================================================================================================================
* RYD LIGE OP I OVENSTÅENDE:
VDEFTIMEFLEXSUM.lo(t)=0;
VDEFTIMEFLEXSUM.up(t)=inf;
VDEFTIMEFLEXSUM.l(t)=0;
VDEFTIMEFLEXSUM.m(t)=0;


display "============================= Alternative model ================================";
* NB: The additional information is in GDATASET, but may of course be anywhere.

SET GDATASET
/
  GDSTOFULLT "Specifies compactly the T at which the storage is empty (negative value) or has a specified positive loading level (positive value); if larger/smaller than 900/-900 then repeated (-)"
  !! If value is integer and positive/negative then plus/minus full storage loading level.
  !! If value is fractional and  positive/negative then fractional value of plus/minus full storage loading level.
  !! If abs(value) is larger than 900 then every (abs(value)-900) T
  !! If value is 0 or if abs(value) is larger than card(T) then no value is set for any T
/;
PARAMETER GDATA(GDATASET)
/
GDSTOFULLT   eps !!   -9025.9  !!  1  !!  9005.4   !!
/;

SCALAR STOVOLUME "Storage volume (MWh)" /7.0/;
display GDATA, STOVOLUME ;


VDEFTIMEFLEX.up(t) = IVDEFTIMEFLEX_up;
VDEFTIMEFLEX.lo(t) = IVDEFTIMEFLEX_lo;
*display VDEFTIMEFLEX.LO, VDEFTIMEFLEX.UP;

*displAY  GDATA, "OG HER ABS(GDATA('GDSTOFULLT')-9000)" ,ISCALAR1, "Frac",iscalar2 ;


ISCALAR1 = FLOOR(ABS(GDATA('GDSTOFULLT')));      !! Absolute value of integer part.
* Version 1 for ISCALAR2:
*ISCALAR2 = 1;
*ISCALAR2$FRAC(ABS(GDATA('GDSTOFULLT'))) = FRAC(ABS(GDATA('GDSTOFULLT'))); !! Fractional remainder if postive, 1 otherwise.
* Version 2 for ISCALAR2:
ISCALAR2 = FRAC(ABS(GDATA('GDSTOFULLT')));  !! Fractional remainder
ISCALAR2$(NOT ISCALAR2) = 1;                !! 1 if fractional remainder is 0

$ONTEXT
* Old version, relating to this specification:
  !! If value is positive and integer then full storage loading level.
  !! If value is positive and fractional then fractional value of full storage loading level.
  !! If value is larger than 900 then every (value-900) T, if smaller than -900 then every (900-value) T

IF(GDATA('GDSTOFULLT'),
  IF((ABS(GDATA('GDSTOFULLT')) LT 9000),
    VDEFTIMEFLEXSUM.FX(T)$(ORD(T) EQ ISCALAR1) = 0 + ISCALAR2*STOVOLUME$(GDATA('GDSTOFULLT') GT 0);
  ELSE
    LOOP(T$((MOD(ORD(T),(ISCALAR1-9000))) EQ 0), VDEFTIMEFLEXSUM.FX(T) = 0 + ISCALAR2*STOVOLUME$(GDATA('GDSTOFULLT') GT 0));
));
DISPLAY "PREVIOUS VERSION: Her VDEFTIMEFLEXSUM.fx repræsenteret ved VDEFTIMEFLEXSUM.LO, .UP:", VDEFTIMEFLEXSUM.LO, VDEFTIMEFLEXSUM.UP;
$OFFTEXT

* Revideret version:
  !! If value is integer and positive/negative then plus/minus full storage level.
  !! If value is fractional and  positive/negative then fractional value of plus/minus full storage level.
  !! If abs(value) is larger than 900 then every (abs(value)-900) T
  !! If value is 0 or if abs(value) is larger than card(T) then no value is set for any T
* cLEAN VALUES:
VDEFTIMEFLEXSUM.LO(T) = -INF;
VDEFTIMEFLEXSUM.UP(T) = INF;

IF(GDATA('GDSTOFULLT'),
display "GDATA('GDSTOFULLT') has some value";
  IF((ABS(GDATA('GDSTOFULLT')) LT 9000),
    VDEFTIMEFLEXSUM.FX(T)$(ORD(T) EQ ISCALAR1) = 0 + SIGN(GDATA('GDSTOFULLT'))*ISCALAR2*STOVOLUME;
  ELSE
    LOOP(T$((MOD(ORD(T),(ISCALAR1-9000))) EQ 0), VDEFTIMEFLEXSUM.FX(T) = 0 + SIGN(GDATA('GDSTOFULLT'))*ISCALAR2*STOVOLUME);
));



DISPLAY "LATEST VERSION: Her VDEFTIMEFLEXSUM.fx repræsenteret ved VDEFTIMEFLEXSUM.LO, .UP:", STOVOLUME, GDATA, ISCALAR1, ISCALAR2, VDEFTIMEFLEXSUM.LO, VDEFTIMEFLEXSUM.UP;


EXECUTE_UNLOAD "all2.gdx";

