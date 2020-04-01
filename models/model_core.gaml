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

import "init/init_core.gaml"
import "init/load_saved_init.gaml"
import "model_simulations.gaml"

global {
//Time aspects
	bool stop_simulation <- false;
	bool new_init <- true;
	date starting_date <- date("2008-01-01");
	date current_date <- starting_date;
	string current_month;
	float step <- 1 #month update: step + 1;
	//Other variables
	float $_ANFP <- 10000.0; //AMOUNT NEEDED TO FEED A PERSON - à établir

	//
	//INIT
	//
	init {
		if new_init = true {
			write "START OF INITIALIZATION FROM SCRATCH";
			do init_cells;
			do init_vias;
			do init_predios;
			//do init_comunas;
			do init_pop;
			do init_LS_EMC;
			do init_ALG;
			do NA_assessment;
			init_end <- true;
			write "END OF INITIALIZATION";
		} else {
			write "START OF INITIALIZATION FROM A SAVED INIT";
			do init_saved_files;
			do load_saved_cells;
			do load_saved_vias;
			do load_saved_predios;
			do load_saved_hogares;
			do load_saved_personas;
			do NA_assessment;
			write "END OF INITIALIZATION";
		}

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
			do labour_value_and_needs;
		}

		ask hogares {
			do values_calc;
		}

	}

	reflex agronomy {
		ask cell {
			do update_yields;
			do crop_cycle;
		}

	}

	reflex decision_making {
		do NA_assessment;
		
		ask hogares {
			if needs_alert = true {
			}

		}

	}

	action NA_assessment {
		write "Needs & assets assessment...";
		ask hogares {
			do update_needs;
			
			do update_assets;
			
		}
		ask predios where (each.is_free = false) {
			do map_needs_alert;
			do map_assets_alert;
			
		}

		write "... done!";
		write "Households don't have their needs met:" + length(hogares where (each.needs_alert = true));
		write "Households understaffed:" + length(hogares where (each.MOF_alert = true));
	}

}