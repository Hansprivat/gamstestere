* Compare with FlexDemandTimeFlex

$ontext
First version 201503xx.
Flexible demand with energy constraint.
The hourly demand (MW) is flexible (up to a certain amount VDEFENERGY_bound).
However, over a certain time interval the accumulated activaled flexibility is zero.
(E.g., over such period a certain energy must be consumed).
Example of application: electric vehicles (with or without vehicle-to-grid); electric freezer; ..
The present implementation does not require explicit data for 'base' demand, so this is assumed part of DE_VAR_T; some care between VDEFENERGY_lo/_lo and the assumed hourly 'base' demand is required?

Example:
Assume a fleet of electric vehicles with a daily loading from the electricity grid of 48 MWh.
The loading is assumed to take place durning the period 7.00-17.00 (an interal of 10 hours) every day of the week.
This loading is initially added to the other component in electricity demand with a flat rate consumption of 4.8 MWh each of those hours, and no loading the remaining part of the day.
Now assume that the total daily loading of 48 MWh may be distributed over the period 7.00-17.00 in the best way (according to qobj).
This may be modelled as follows.
...



Man kan let generalise short term storage..........

Vi har muligheder for short term storage:
  - (1): som i dag: fast maxvol, frie, men identiske, start- og slutvol på hvert S
  - (2): Flex-ideen: tilføj til (1): skabe sekvenser over hvilke der er energibalance, evt med angivelse af niveauet. Se DEFENERGYbalance m.v. nedenfor.  [Og se GAMStestere/FlexDemandTimeFlex]
  - (3): Variabel .up: tilføj til (1): profil for maxvol relativt til maxvol fra (1) (så defaultværdi er 1, der antages hvis intet andet er angivet; EPS for 0).
         Denne kan bruges til at tvinge lageret til at være tomt i angivne perioder. (Terminologi e.g. STORATE(AAA,GGG,TTT)).
         Evt. kan den mere simplet bare sættes til forskellig fra 1 (f.eks. eps) i visse T; evt. med STORATE lig INF i øvrige T, så haves min Flexide.
         En lidt mere generel (men mere realistisk for visse anvendelser) mulighed ligger i at tilføje også en profil for minvol, så kan der specificeres et vilkårligt fast niveau, ikke kun 0.   [Og se GAMStestere/FlexDemandTimeFlex]
  - (4): og for længere perioder end ét S: Se C:\$_HansC\GAMStestere\BalmorelSto_linkS.

Noget helt andet ......
I øvrigt kunne (1) - (3) være inspiration til default data håndtering hvad angår STORAGE, e.g.:
$ifi     exist data\storage.inc $include data\storate.inc          !! eksisterer med vilje ikke
$ifi not exist data\storage.inc PUT ERRORFILE/LOGFILE "File data\STORATE.inc not found. Applying default value 1. (Not an error)"/;
$ifi not exist data\storage.inc STORATE(T) = 1; !! Default value
* ... men jeg har jo en vis modvilje mod sådanne implicitte data...


$offtext



$oninline
$oneolcom
option limrow = 300;


set s /S01*s01/;
set t / T001*t168/;


parameter elpricehelper(t) "";

* The activated DEF energy over a period must be zero. The following parameter specifies beging/end T for such periods.
parameter DEFENERGYbalance(t) "The energy balance of DEF between two consecutive T with non-zero values is zero (-)";
SCALAR DEFENERGYbalanceMinMax  "The maximal deviation of DEFENERGYbalance the from zero (MWh)";
scalar DEFENERGY_lo  "Lower limit of flexibility (svarer til DEFSTEPS) ((MW)";
scalar DEFENERGY_up  "Upper limit of flexibility (svarer til DEFSTEPS)  MW)";
PARAMETER IHOURSINST(S,T);

free variable vobj "";
free variable VDEFENERGY(T)    "The activated flexible-energy demand (svarer til VDEF) (MW)";
free variable VDEFENERGYVOL(T) "The accumulated activated flexible-energy demand (MWh)";

equation qobj;
equation QDEFENERGYVOL(T);

model flexdemsto /all/;

qobj..
 vobj =E= sum(t, elpricehelper(t) * VDEFENERGY(t));

QDEFENERGYVOL(t)..
      VDEFENERGYVOL(t++1) =E= VDEFENERGYVOL(t) + VDEFENERGY(t);


* DATA -------------------------------------------------------------------------

elpricehelper(t) = sin(ord(t)/(2*3.14159)) + 2;

scalar DEFENERGY_lo   /-2/;
scalar DEFENERGY_up   /3/;
SCALAR DEFENERGYbalanceMinMax  "The maximal deviation (positive or negative) of DEFENERGYbalance from zero any hour (MWh)" /5.5/;



parameter DEFENERGYbalance(t)              !! Mere avanceret og kompakt håndtering findes i GAMStestere/FlexDemandTimeFlex
/
t024 1
t048 eps
t072 1
t096 1
   t100 27
t120 1
t144 inf
t168 1
/;

VDEFENERGY.up(t) = DEFENERGY_up;
VDEFENERGY.lo(t) = DEFENERGY_lo;

VDEFENERGYVOL.LO(t) = -DEFENERGYbalanceMinMax;
VDEFENERGYVOL.UP(t) = +DEFENERGYbalanceMinMax;
* Set VDEFENERGYVOL.fx to zero for the T for which balanceinterval has a value.    !! Mere avanceret og kompakt håndtering findes i GAMStestere/FlexDemandTimeFlex
VDEFENERGYVOL.fx(t)$DEFENERGYbalance(t) = 0;   !! Must be later than .LO(t)= and .UP(t)=  !    (hvad menes der?)
* Alternatively: use the value in DEFENERGYbalance, to get some kind of net accumulation between two consecutive t with elements in DEFENERGYbalance:
*VDEFENERGYVOL.fx(t)$DEFENERGYbalance(t) = DEFENERGYbalance;


* SOLVE: -----------------------------------------------------------------------
SOLVE FLEXDEMSTO MAXIMIZING vobj using lp;




