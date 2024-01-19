version 17

macro def folder_risultati "D:\Uni\3.1 - ECNA\Stata\Esercitazione - ISF\risultati"

macro def folder_dati_originali "D:\Uni\3.1 - ECNA\Stata\Esercitazione - ISF\dati_originali"

macro def folder_dati "D:\Uni\3.1 - ECNA\Stata\Esercitazione - ISF\dati"

clear all
set more off

forval num = 1/6 {

	u "$folder_dati_originali\isf_w`num'"
	gen wave = `num'
	save "$folder_dati\wave`num'", replace
}

u "$folder_dati\wave1.dta", clear
append using "$folder_dati\wave2.dta"
append using "$folder_dati\wave3.dta"
append using "$folder_dati\wave4.dta"
append using "$folder_dati\wave5.dta"
append using "$folder_dati\wave6.dta"
sort id wave
save "$folder_dati\datawaves1to6", replace


browse panel id wave eta sesso ncomp if panel !=0 & panel!=.