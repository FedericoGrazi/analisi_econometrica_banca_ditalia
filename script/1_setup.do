* file studenti

version 17
u "D:\Uni\3.1 - ECNA\Progetto_ECNA\dati\datawaves1to6.dta", replace


* quali variabili in quali waves?
bys wave: summarize

* info about education: wave 1 --> D3d (only in wave 1), waves 2-6: TITOLO; --> gen new variable "education"
gen 	education = d3d 	if wave==1
replace education = titolo 	if wave>=2 & wave<=6

table education

* mettiamo ordine tra le variabili inerenti le "opinioni sull'economia italiana": cambiano i nomi delle variabili tra wave 1, 2 e 3-6; cambiano i valori che assumono: da 1 a 6 in wave 1, da 1 a 5 e 9 in waves 2-6
recode d1 d2 d3 d4 (9 = 6)

summarize expeconomia, d
bys wave: summarize expeconomia
bys area5: summarize expeconomia
bys modoint: summarize expeconomia

gen 	occupazione = 1		if wave==1 & d1d==1 & d1d<=4
replace occupazione = 2		if wave==1 & d1d==5
replace occupazione = 3		if wave==1 & d1d==6
replace occupazione = 4		if wave==1 & d1d==7
replace occupazione = 5		if wave==1 & d1d==8
replace occupazione = 6		if wave==1 & d1d==98
replace occupazione = a10 	if wave==2
replace occupazione = occ 	if wave>=3 & wave<=6

gen 	contratto = 1		if wave==1 & d1d==1
replace contratto = 2		if wave==1 & d1d==3
replace contratto = 3		if wave==1 & d1d==2
replace contratto = 4		if wave==1 & d1d==4
replace contratto = a11 	if wave==2
replace contratto = contr 	if wave>=3 & wave<=6

gen 	settore = d2d		if wave==1
replace settore = a12	 	if wave==2
replace settore = sett		if wave>=3 & wave<=6

* aspettative occupazione/disoccupazione: waves 2-6, variabili cambiano nome tra wave 2 e quelle successive
gen 	pperditalav = a13	 	if wave==2
replace pperditalav = probperd	if wave>=3 & wave<=6

gen 	plavoro = a14	 	if wave==2
replace plavoro = problav	if wave>=3 & wave<=6

gen 	pperditalavf = a15	 		if wave==2
replace pperditalavf = probperdf	if wave>=3 & wave<=6

* gen dummies:
tab wave, gen(dwave)
tab area5, gen(darea5)
gen dfemmina = (sesso==2)
tab occupazione, gen(doccupazione)
tab contratto, gen(dcontratto)
tab settore, gen(dsettore)
tab expeconomia, gen(dexpeconomia)
tab explavoro, gen(dexplavoro)

*gen dummies per intervalli di età:

save "$folder_dati\datawaves1to6_cross.dta", replace




save "$folder_dati\datawaves1to6_panel.dta", replace
