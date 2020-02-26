/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model model_core

import "init_core.gaml"
import "model_simulations.gaml"

global {
	bool stop_simulation <- false;
	float $_ANFP <- 250.0; //AMOUNT NEEDED TO FEED A PERSON - à établir
	float step <- 1 #month update: step + 1;
	//
	//INIT
	//
	init {
		write "START OF INITIALIZATION";
		do init_cells;
		do init_vias;
		do init_predios; //do init_comunas;
		do init_pop; //do init_LS;
		do init_LS_EMC;
		do init_ALG;
		do init_revenu;
		init_end <- true;
		write "END OF INITIALIZATION";
	}
	
	reflex dynamic when: (stop_simulation = false) {
		write "-------------------------------------------";
		write "Months elapsed: " + cycle;
		if cycle = 96 {
			stop_simulation <- true;
			write "END OF SIMULATION";
		}
	}

}