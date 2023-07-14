***************************
*** LFP 20/21 			***
*** Name: Fynn Lohre	***
*** Matr. Nr.: 3035850	***
***************************

/*

Titel: Der Effekt einer Mindestlohnerhöhung

Daten: Lohre.dta

Abgabedatum: 15/03/2021

Prüfer: Prof. Dr. Boris Hirsch

*/




* 1 Vorbereitungen *

version 14.0
clear all
set more off
set rmsg on

* Verzeichnis
cd /Users/fynnlohre/Desktop/Datensaetze
use Lohre.dta, replace

* Log File
set linesize 255
capture log close, replace
log using 3035850_Abgabe.log, replace




* 2 Generelles * 


* 2.1 Deskriptive Statistiken *
describe 
codebook 
sum ,detail


* 2.2 Erstellung Graph Einleitung * 




* 3 Leitfrage I * 

/* Betrachten Sie zunächst deskriptiv die Einstiegslöhne in Schnellrestaurants
in New Jersey und Pennsylvania. Gab es vor der Mindestlohnerhöhung signifikante 
Lohnunterschiede zwischen Schnellrestaurants in New Jersey und Pennsylvania? 
Wie ändert sich das Bild nach der Mindestlohnerhöhung New Jersey ? */ 


* 3.1 Stat. Vorgehen (Mittelwertvgl.) * 
bysort NewJersey Time: sum EntryWage
ttest EntryWage if Time==0, by(NewJersey)
ttest EntryWage if Time==1, by(NewJersey)


* 3.2 Graph. Vorgehen (combined Boxplot) * 

generate EntryWageT0 = EntryWage if Time==0
generate EntryWageT1 = EntryWage if Time==1

label variable EntryWageT0 "TO (Pre-Mindestlohn)"
label variable EntryWageT1 "T1 (Post-Mindestlohn)"
label define NewJersey_lbl 0 "Pennsylvania (Kontrollgruppe)" 1 "New Jersey"
label values NewJersey NewJersey_lbl

graph box EntryWageT0 EntryWageT1, over(NewJersey) ytitle(Einstiegslohn ///
(US-$)) yline(5.05, lwidth(medium) lpattern(shortdash_dot_dot) lcolor(black)) ///
title(Einstiegslöhne Pre and Post Mindestlohnerhöhung in New Jersey) 

graph export Boxplot.pdf, replace

/* => Sowohl graphisches als auch stat. Vorgehen bzw. die deskriptiven Daten
lassen einen Zusammenhang vermuten. Ob dieser kausaler Natur ist, ist im 
weiteren Verlauf zu bestimmen */


/* 3.3 Auffälligkeiten in der Komplianz (vgl. Boxplot unter Mindestlohn) 
- Test: */

sum EntryWageT1 if NewJersey==1, detail 

/* => 3 FF-Restaurants Entry Wage von = 5 (<w(min)) */




* 4 Leitrage II *

/* Ermitteln Sie auf Grundlage eines geeigneten Regressionsmodells den prozen-
tualen Lohnunterschied zwischen den Staaten und überprüfen Sie, ob sich das 
prozentuale Lohnwachstum zwischen den Staaten signifikant unterschieden hat. */


* 4.1 Regression * 
generate lnwage = ln(EntryWage)
label variable lnwage "Log. Einstiegslohn"
eststo: quietly reg lnwage NewJersey Time, cluster (Store)
eststo: reg lnwage NewJersey Time 1.Time#1.NewJersey, cluster(Store)
eststo: reg lnwage NewJersey Time 1.Time#0.NewJersey, cluster(Store)

/* => Die Regression gibt erste Hinweise darauf, dass die Löhne von T0 zu T1 in 
P gesunken sind (vermutlich Rezession), die Löhne in NJ jedoch höher sind & 
durch die Mindestlohnerhöhung die mittleren Löhne von T0 zu T1 gestiegen sind */


* 4.2 Regression mit Aufnahme der Fast-Food Ketten *
bysort NewJersey: tabulate Chain

generate BK = Chain == 1 
generate Roys = Chain == 3
generate Wendys = Chain == 4
generate KFC = Chain == 2

label define NewJersey_lbl2 0 "Pennsylvania" 1 "New Jersey"
label values NewJersey NewJersey_lbl2
graph hbar KFC Roys Wendys BK, over(NewJersey) stack percent ///
title(Verteilung der Schnellrestaurantketten) ytitle(Prozent) ///
legend(label(1 "KFC") label(2 "Roys") label(3 "Wendys") label (4 "Burgerking"))
graph export StackedBar.pdf, replace

/* Aufnahme der Ketten, da mögliche Korrelation mit Störterm (durch untersch.
Entwicklung */

eststo: quietly reg lnwage NewJersey Time 1.Time#1.NewJersey i.Chain, ///
cluster(Store)

eststo: quietly reg lnwage NewJersey Time 1.Time#1.NewJersey i.Chain, ///
vce(robust)

/* => Keine Verbesserung der Schätzung , eher zu vernachlässigen, 
Präzisere Schätzung durch die verwendeten (notwendigen) cluster 
robusten Standardfehler */

esttab using Regression.tex , replace nocons r2
eststo clear 



* 5 Leitfrage III * 

/* Führen Sie – zunächst ohne Aufnahme von Kontrollvariablen – eine 
Differenz-von-Differenzen-Schätzung des mittleren kausalen Effekts der 
Mindestlohnerhöhung auf die in Ihrem Datensatz vorhandene Ergebnisvariable 
durch. Ist der ermittelte Effekt ökonomisch und statistisch signifikant? */
xtset Store Time
xtdescribe


eststo: xtreg Employment Time i.NewJersey##i.Time, fe vce(cluster Store)

/* Effek ökonom und Stat. Signifikant*/




* 6 Leitfrage IV * 

/* Da die Mindestlohnerhöhung – wie in Card und Krueger (1994) beschrieben – 
mit einer Rezession zusammenfiel, soll die Auslastung der Schnellrestaurants 
kontrolliert werden. Führen Sie daher eine weitere DvD-Schätzung mit 
entsprechenden Kontrollvariablen durch. Welche Änderungen ergeben sich durch 
Aufnahme dieser Kontrollvariablen? 
Diskutieren Sie darüber hinaus, warum die Aufnahme der Kontrollvariablen eine 
Verzerrung Ihrer Schätzung bewirken kann. */


* 6.1 DvD *
eststo: xtreg Employment Time HoursOpen Registers i.NewJersey##i.Time, ///
fe vce(cluster Store)

/* Decken sich die Ergebnisse mit den deskriptiven Statistiken? */
bysort NewJersey: sum Employment if Time == 0
bysort NewJersey: sum Employment if Time == 1

* => Ja *


* 6.2 Exkurs: Vergleich Areg Xtreg (LSDE vs ZT) *

eststo: areg Employment Time HoursOpen Registers i.NewJersey##i.Time, ///
absorb(Store) vce(cluster Store)

/* => Areg, wie zu erwarten, niedrigere Standardfehler, da asymptotisch 
über Cluster läuft*/

esttab using DvD.tex, replace 
eststo clear 

* 7 Leitfrage V * 

/* Diskutieren Sie die identifizierenden Annahmen des von Ihnen genutzten DvD-
Ansatzes und erläutern Sie, ausgehend von Dube et al. (2010), das Kernproblem
Ihres Vorgehens und wie ein überzeugender DvD-Ansatz aussehen könnte. */

/* => Antwort siehe Abschnitt 5 "Dikussion" */ 




* 8 Leitfrage VI *

/* Überprüfen Sie (in einem geeigneten Regressionsmodell), ob sich der Mindest-
lohneffekt für Franchisenehmer und von den Ketten selbst betriebene Schnell-
restaurants signifikant unterscheidet. Ergeben sich für beide Gruppen ökonomisch
und statistisch signifikante Mindestlohneffekte? */ 


eststo: xtreg Employment Time HoursOpen Registers i.NewJersey##i.Time ///
if Franchise == 0 , fe vce(cluster Store)

eststo: xtreg Employment Time HoursOpen Registers i.NewJersey##i.Time ///
if Franchise == 1 , fe vce(cluster Store)


eststo: xtreg Employment Time HoursOpen Registers i.NewJersey##i.Time ///
 i.NewJersey##i.Time##1.Franchise, fe vce(cluster Store)
 
 esttab using Franchise.tex, replace 
 
/* => Unterschied nicht stat signifikant, mit Blick auf das Konfidenzintervall, 
lässt sich nicht sicher sagen, dass der Unterschied nicht auch Null (oder 
positiv ist), was auf geringe Schätzpräizision und und kleinen Unterschied 
zurückzuführen ist. 

Beide Einzelne DvD-Schätzungen (für F == 0 // 1 ) ergeben, dass es einen ökon.
und sat. gesicherten Effekte für beide Gruppen gibt, also ist bei beiden etwas. 
Ob sich das nun mit Sicherheit unterscheidet, oder nicht, kann an dieser Stelle 
nur vermutet werden*/ 

log close


