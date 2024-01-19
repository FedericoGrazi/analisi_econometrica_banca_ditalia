
version 17

log using "C:\Users\Feder\Download & log"

macro def folder_risultati "D:\Uni\3.1 - ECNA\Progetto_ECNA\risultati"
macro def folder_datioriginali "D:\Uni\3.1 - ECNA\Progetto_ECNA\dati_originali"
macro def folder_dati "D:\Uni\3.1 - ECNA\Progetto_ECNA\dati"

clear all
set more off

use "$folder_dati\datawaves1to6_cross.dta", replace

* ******* *
*   DATI  *
* ******* *
bys wave: summarize

**gen 	education = d3d 	if wave==1
replace education = titolo 	if wave>=2 & wave<=6
table education

recode d1 d2 d3 d4 (9 = 6)
 
* ********** *
*   PUNTO 1  *
* ********** *

*gen explavoro, expprezzi, prezzipast 

**gen  expeconomia = d1   if wave==1 
replace expeconomia = a01   if wave==2 
replace expeconomia = sitgen  if wave>=3 & wave<=6 
 
**gen     explavoro = .     if wave==1 
replace explavoro = a02   if wave==2  
replace explavoro = mlav  if wave>=3 & wave<=6 

**gen     expprezzi = d4   if wave==1 
replace expprezzi = a05  if wave==2 
replace expprezzi = prezzif if wave>=3 & wave<=6 

**gen     prezzipast = d3   if wave==1 
replace prezzipast = .    if wave==2 
replace prezzipast = prezzip if wave>=3 & wave<=6

* creiamo delle variabili dummy per ogni intervallo di età 
 
**gen     eta1830 = 1 if eta<=30 
replace eta1830 = 0 if eta>30 
 
**gen     eta3140 = 1 if (eta>30 & eta<=40)
replace eta3140 = 0 if eta3140 !=1
 
**gen     eta4150 = 1 if (eta>40 & eta<=50 )
replace eta4150 = 0 if eta4150 !=1
 
**gen     eta5160 = 1 if (eta>50 & eta<=60 )
replace eta5160 = 0 if eta5160 !=1
 
**gen     eta6170 = 1 if (eta>60 & eta<=70 )
replace eta6170 = 0 if eta6170 !=1
 
gen     eta71xx = 1 if eta>=71 
replace eta71xx = 0 if eta71xx !=1

*ulteriori dummy
**gen 	occupazione = 1		if wave==1 & d1d==1 & d1d<=4
replace occupazione = 2		if wave==1 & d1d==5
replace occupazione = 3		if wave==1 & d1d==6
replace occupazione = 4		if wave==1 & d1d==7
replace occupazione = 5		if wave==1 & d1d==8
replace occupazione = 6		if wave==1 & d1d==98
replace occupazione = a10 	if wave==2
replace occupazione = occ 	if wave>=3 & wave<=6

**gen 	contratto = 1		if wave==1 & d1d==1
replace contratto = 2		if wave==1 & d1d==3
replace contratto = 3		if wave==1 & d1d==2
replace contratto = 4		if wave==1 & d1d==4
replace contratto = a11 	if wave==2
replace contratto = contr 	if wave>=3 & wave<=6

**gen 	settore = d2d		if wave==1
replace settore = a12	 	if wave==2
replace settore = sett		if wave>=3 & wave<=6

*perditalav
**gen 	pperditalav = a13	 	if wave==2
replace pperditalav = probperd	if wave>=3 & wave<=6

**gen 	plavoro = a14	 	if wave==2
replace plavoro = problav	if wave>=3 & wave<=6

**gen 	pperditalavf = a15	 		if wave==2
replace pperditalavf = probperdf	if wave>=3 & wave<=6

* dummies da tab:
tab wave
tab area5
*gen dfemmina = (sesso==2)
tab occupazione
tab contratto
tab settore
tab expeconomia
tab explavoro

* ********** *
*   PUNTO 2  *
* ********** *
/*2.1*/ bys wave: sum expeconomia explavoro expprezzi
/*2.2*/ tab2 wave expeconomia, row
/*2.4*/ tab2 wave explavoro, row
/*2.3*/ tab2 wave expprezzi, row
/*2.5*/ table wave, stat(mean expeconomia explavoro expprezzi) stat(sd expeconomia explavoro expprezzi)
/*2.6*/ cor expeconomia explavoro expprezzi

/*2.7*/ bys education: sum expeconomia explavoro expprezzi
/*2.8*/ tab2 education explavoro, row
/*2.9*/ table education, stat(mean expeconomia explavoro expprezzi)
 
/*2.10*/ bys area5: sum expeconomia explavoro expprezzi
/*2.11*/ bys dfemmina: sum expeconomia explavoro expprezzi
/*2.12*/ bys occupazione: sum expeconomia explavoro expprezzi

/*2.13*/ bys modoint: sum expeconomia explavoro expprezzi
/*2.14*/ tab2 modoint expeconomia, col


* ********** *
*   PUNTO 3  *
* ********** *

/*1*/ reg pperditalav dwave3-dwave6, cluster(id) 
test dwave3=dwave4=dwave5=dwave6

/*2*/ reg pperditalav dwave3-dwave6 eta , cluster(id)
test dwave3=dwave4=dwave5=dwave6

/*3*/ reg pperditalav dwave3-dwave6 eta3140-eta5160, cluster(id) 
test eta3140=eta4150=eta5160

/*4*/ reg pperditalav dwave3-dwave6 eta3140-eta5160 if eta<60, cluster(id)
test dwave3=dwave4=dwave5=dwave6
test eta3140=eta4150=eta5160

/*5*/ reg pperditalav dwave3-dwave6 eta3140-eta5160 doccupazione2-doccupazione6 dcontratto2-dcontratto4 dsettore2-dsettore10 dfemmina if eta<60, cluster(id)
predict pperditalav_hat if e(sample)
test eta3140=eta4150=eta5160
test dwave3=dwave4=dwave5=dwave6
test dcontratto2 = dcontratto3 = dcontratto4
test dsettore2=dsettore3=dsettore4=dsettore5=dsettore6=dsettore7=dsettore8=dsettore9=dsettore10



*gen plav = 1 if pperditalav>=50
replace plav=0 if pperditalav<50

* BONTà 3.1
gen PREDplav=0 if pperditalav_hat <50
replace PREDplav=1 if pperditalav_hat >=50

tab PREDplav plav
dis (8414+3906)/14860 * 100

* PLAV E CONTRATTO - 3.2
tab2 plav contratto, col 
bys plav: sum dcontratto1-dcontratto4
cor dcontratto1-dcontratto4 pperditalav

* PLAV E SETTORE - 3.3
tab2 plav settore, col
bys plav: sum dsettore1-dsettore10

* PLAV E SESSO - 3.4
tab2 plav dfemmina, col


/*3.5 - Perdita Lavoro condizionata alla Wave*/ 
table wave, stat(mean pperditalav_hat)
by wave, sort: egen pperditalav_hat_wave = mean(pperditalav_hat)
twoway (connected pperditalav_hat_wave wave), name("Perdita_Lavoro_condizionata_Wave")

/*3.6 - Perdita Lavoro condizionata alla Wave e al tipo di contratto*/ 
table wave contratto, stat(mean pperditalav_hat)
by wave contratto, sort: egen pperditalav_hat_wave_contratto = mean(pperditalav_hat)
twoway (connected pperditalav_hat_wave_contratto wave if contratto==1, sort) (connected pperditalav_hat_wave_contratto wave if contratto==2, sort) (connected pperditalav_hat_wave_contratto wave if contratto==3, sort) (connected pperditalav_hat_wave_contratto wave if contratto==4, sort), name("Contratto")

/*3.7 - Perdita Lavoro condizionata all'età'*/ 
tab2 eta1830-eta5160 plav
by eta, sort: egen pperditalav_eta = mean(pperditalav_hat)
twoway (connected pperditalav_eta eta, sort) (lfit pperditalav_eta eta) if eta<60, name("Età2")
 twoway (lfitci pperditalav_eta eta if eta>20 & eta<31) (lfitci pperditalav_eta eta if eta>30 & eta<50) (lfitci pperditalav_eta eta if eta>=50 & eta<60) (connected pperditalav_eta eta if eta>20 & eta<31) (connected pperditalav_eta eta if eta>30 & eta<50) (connected pperditalav_eta eta if eta>=50 & eta<60), name("Perdita_Lavoro_condizionata_Età")

 
* ******** *
*   REG3   *
* ******** *
bys wave: sum pperditalav

sum dfemmina
sum eta1830-eta5160
sum doccupazione2-doccupazione6

* 3.8 - GENERAZIONE ULTERIORI VARIABILI

* EDUCAZIONE TRONCATA
replace education = 5 if education>5
tab education, gen(deducation)
sum deducation1-deducation5
* 1 = Nessun Titolo // 5+ = Universitario

* CONDIZIONE GENERRALE
gen 	congen = d7 if wave==1
replace congen = a23 if wave==2
replace congen = condgen if wave>3
tab congen, gen(dcongen)
sum dcongen1-dcongen6
*1 = difficoltà // 6 = facilmente

* PRESO IN CONSIDERAZIONE CHIEDERE UN PRESTITO
gen 	prestito = a37 if wave==2
replace prestito = 6 if prestito ==4
tab prestito
replace prestito = ricpres if wave>2
replace prestito = 1 if prestito<6
tab prestito, gen(dprestito)
sum dprestito1-dprestito2
* 1 = si // 6 = no

* DEBITI SU FINALITà DI CONSUMO
gen 	debiti = d11 if wave==1
replace debiti = a26 if wave==2
replace debiti = debiti_3 if wave>=3 
tab debiti, gen(ddebiti)
sum ddebiti1-ddebiti3
* 1 = Ha debiti // 2 = Non ha debiti

*  3.9 - PROBIT
probit pperditalav eta3140-eta5160 dcongen2-dcongen6 dprestito1 ddebiti1 dcontratto2-dcontratto4 if eta<60, cluster(id)

* TEST E BONTà
test eta3140 = eta4150 = eta5160
test eta3140 = eta4150
test dcongen2=dcongen3=dcongen4=dcongen5=dcongen6
predict pperc_hat if e(sample)
lstat


by eta, sort: egen phe = mean(pperc_hat)
twoway (connected phe eta) if eta<60, name("Età31")

by eta congen, sort: egen phec = mean(pperc_hat)
twoway (connected phec eta if congen == 1 & eta<60 )  (connected phec eta if congen == 6 & eta<60 )  (lfit phec eta if congen == 1 & eta<60) (lfit phec eta if congen == 6 & eta<60), name("età_congen1")

by eta contratto, sort: egen phen = mean(pperc_hat)
twoway (lfit phen eta if eta<60 & contratto ==1) (lfit phen eta if eta<60 & contratto ==2) (lfit phen eta if eta<60 & contratto ==3) (connected phen eta if eta<60 & contratto ==1) (connected phen eta if eta<60 & contratto ==2) (connected phen eta if eta<60 & contratto ==1) (connected phen eta if eta<60 & contratto ==3), name("età_contratto1")


table ( eta1830-eta5160 ) ( contratto ) () if eta1830==1 | eta3140 ==1 | eta4150 ==1 | eta5160==1, nototals




* ******* *
*  PANEL  *
* ******* *

* nota: collegamento panel tramite "id" e "panel==1"; in wave 3, 5 e 6 tutti gli intervistati erano stati intervistati nella wave precedente (sono tutti intervistati panel)
* quindi, osservazioni: W1 3079, W2 2346 (di cui 881 in W1), W3 2077 (tutti in W2), W4 2806 (di cui 1781 in W3), W5 2489 (tutti in W4), W6 2063 (tutti in W5)

* genero variabile per riconoscere gli intervistati della wave 1 che vengono reintervistati in wave 2 (componente panel tra wave 1 e 2)

sort id wave
by id: gen panel1=1 if wave==1 & (panel[_n+1]==1 & wave[_n+1]==2)

* tengo solo osservazioni panel:
keep if panel==1 | wave==3 | wave==5 | wave==6 | panel1==1

u "$folder_dati\datawaves1to6_panel.dta", replace

/*4.1*/ xtset id wave, delta(1)
/*4.2*/ xtsum expeconomia pperditalav


*OLS e fe 
/*4.3.1*/ reg pperditalav expeconomia, r
/*4.3.1*/ xtreg pperditalav expeconomia, fe cluster(id)


*OLS e fe con dwave 
/*4.4.1*/ reg pperditalav expeconomia dwave3-dwave6, r
test dwave3=dwave4=dwave5=dwave6

/*4.4.2*/ xtreg pperditalav expeconomia dwave3-dwave6, fe cluster(id)
test dwave3=dwave4=dwave5=dwave6

tab expeconomia

* OLS e fe con dwave e dexpeconomia
/*4.5.1*/reg pperditalav dexpeconomia3-dexpeconomia6 dwave3-dwave6,r 
test dexpeconomia3=dexpeconomia4=dexpeconomia5
test dwave3=dwave4=dwave5=dwave6

/*4.5.2*/xtreg pperditalav dexpeconomia3-dexpeconomia6 dwave3-dwave6, fe cluster(id)
test dexpeconomia3=dexpeconomia4=dexpeconomia5
test dwave3=dwave4=dwave5=dwave6


* ********** *
*   PUNTO 5  *
* ********** *

* CONDIZIONE GENERALE AD ORA
sum condgennow
gen connow = 1 if condgennow<3
replace connow = 2 if condgennow==3 | condgennow==4
replace connow = 3 if condgennow>4
tab connow
* 1 = Difficolta // 2 = Media // 3 = Facilmente

* DUMMY
gen dconnow = 0 if condgennow<4
replace dconnow = 1 if condgennow>3 
* 0 = Difficolta // 1 = Facilmente


* VARI SUSSIDI
gen reddcid = 1 if misure_3 == 1
replace reddcid= 0 if misure_3==2
sum reddcid

gen reddemerg = 1 if misure_4 == 1
replace reddemerg= 0 if misure_4==2
sum reddemerg
* 1 = Sostegno presente // 0 = Nessun sostegno

bys reddcid: tab condgennow
bys contratto: tab condgennow

* DUMMY AREA GEOGRAFICA
tab area5, gen(dzona)


* VARIAZIONE DEL REDDITO
gen reddvar = d9 if wave== 1 
replace reddvar = 3 if d9<4
replace reddvar = 2 if d9==4
replace reddvar = 1 if d9 ==5
replace reddvar = a24 if wave==2
replace reddvar = varredm if wave > 2
tab reddvar, gen(dreddvar)
* 1 = Aumentato // 3 = Diminuito

* COMPONENTI DELLA FAMIGLIA OCCUPATI
gen  famocc = .   if wave==1 
replace a09 = a09 +1 if occupazione <3
replace famocc = a09   if wave==2 
replace famocc = noccnow  if wave>=3 & wave<=6 
sum famocc

tab explavoro, gen(dexplavoro)

* Regr Base
/*5.1.1*/reg connow dzona2-dzona5 dcontratto2-dcontratto4  dexplavoro2-dexplavoro5 dreddvar2-dreddvar3, r cluster(id)
 
/*5.1.2*/ probit dconnow dzona2-dzona5 dcontratto2-dcontratto4 dexplavoro2-dexplavoro5 dreddvar2-dreddvar3  , r cluster(id)

lstat

* Effetto delle Famiglie
/*5.2.1*/xtreg connow dzona2-dzona5 dcontratto2-dcontratto4  dexplavoro2-dexplavoro5 dreddvar2-dreddvar3 ncomp famocc, fe cluster(id)
 
/*5.2.2*/probit dconnow dzona2-dzona5 dcontratto2-dcontratto4 dexplavoro2-dexplavoro5 dreddvar2-dreddvar3  ncomp famocc, r cluster(id)

lstat


* con sussidi
/*5.3.1*/reg connow dzona2-dzona5 dcontratto2-dcontratto4  dexplavoro2-dexplavoro5 dreddvar2-dreddvar3 ncomp famocc reddcid reddemerg, r cluster(id)

/*5.3.2*/probit dconnow dzona2-dzona5 dcontratto2-dcontratto4  dexplavoro2-dexplavoro5 dreddvar2-dreddvar3 ncomp famocc reddcid reddemerg, r cluster(id)


lstat



 log close