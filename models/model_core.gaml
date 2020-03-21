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
//Time aspects
	bool stop_simulation <- false;
	date starting_date <- date("2008-01-01");
	date current_date <- starting_date;
	string current_month;
	float step <- 1 #month update: step + 1;
	//Other variables
	float $_ANFP <- 5000.0; //AMOUNT NEEDED TO FEED A PERSON - à établir

	//
	//INIT
	//
	init {
		write "START OF INITIALIZATION";
		do init_cells;
		do init_vias;
		do init_predios;
		//do init_comunas;
		do init_pop;
		do init_LS_EMC;
		do init_ALG;
		do init_revenu;
		init_end <- true;
		write "END OF INITIALIZATION";
	}
	//
	//MODEL DYNAMICS
	//
	reflex time when: (stop_simulation = false) {
		current_date <- plus_months(current_date, 1);
		current_month <- string(current_date, "MMMM", 'es');
		write "-------------------------------------------";
		write "Current date at cycle " + cycle + ":" + current_date;
		write "Current month is " + current_month;
		write "Months elapsed: " + months_between(starting_date, current_date);
		write "time (seconds): " + time;
		write "labor mean for step is: " + labor_mean;
		write "area deforest mean for is: " + area_deforest_mean;
		if current_date > date("2016-01-01") {
			stop_simulation <- true;
			do pause;
			write "END OF SIMULATION";
		}

	}

	reflex demography {
		ask personas {
			do aging;
			do values_calc;
		}
		ask hogares {
			do values_calc;
		}

	}
	
	reflex LUC_decision_making {
		ask predios {
			do update_needs;
			do map_eminent_LUC;
		}
	}

}