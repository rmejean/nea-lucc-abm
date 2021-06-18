/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/ model model_core

import "init/init_core.gaml"
import "init/load_saved_init.gaml"
import "model_simulations.gaml"

global { //Time aspects
	bool stop_simulation <- false;
	bool new_init <- false;
	date starting_date <- date("2008-01-01");
	date current_date <- starting_date;
	string current_month;
	float step <- 1 #month update: step + 1;
	//Other variables
	float $_ANFP <- 3900.0; //AMOUNT NEEDED TO FEED A PERSON
	//
	//INIT
	//
	init {
		if new_init = true {
			write "START OF INITIALIZATION FROM SCRATCH";
			do init_cells;
			do init_vias;
			do init_empresas;
			do init_predios; 
			do init_comunas;
			do init_pop_predios;
			do init_pop_comunas;
			do init_LS_EMC;
			do init_ALG;
			do init_farm_jobs;
			do init_oil_jobs;
//			ask hogares {
//				do assess_income_needs;
//				do setting_alerts;
//			}

			ask predios {
				do deforestation_rate_calc;
				}
			ask comunas {
				do deforestation_rate_calc;
			}
			do init_control;
			init_end <- true;
			write "END OF INITIALIZATION";
//			write "Households don't have their needs met:" + length(hogares where (each.needs_alert = true));
		} else {
			write "START OF INITIALIZATION FROM A SAVED INIT";
			do init_saved_files;
			do load_saved_cells;
			do init_vias;
			do load_saved_empresas;
			do load_saved_predios;
			do load_saved_comunas;
			do load_saved_hogares;
			do load_saved_personas;
			do load_saved_landscape;
			ask hogares where (each.type = "predio") {
				do assess_income_needs;
				do setting_alerts;
			}
			ask comunas {
				do assess_income_needs;
				do setting_alerts;
			}

			ask predios {
				do deforestation_rate_calc;
				//do map_deforestation_rate;
			}
			ask comunas {
				do deforestation_rate_calc;
			}
			do init_control;
			init_end <- true;
			write "END OF INITIALIZATION";
			write "Households don't have their needs met:" + length(hogares where (each.needs_alert = true));
		}

	}
	//////////////////
	//MODEL DYNAMICS//
	//////////////////
	reflex time when: (stop_simulation = false) {
		current_date <- plus_months(current_date, 1);
		current_month <- string(current_date, "MMMM", 'es');
		write "-------------------------------------------";
		write "Current date at cycle " + cycle + ":" + current_date;
		write "Current month is " + current_month;
		write "Months elapsed: " + months_between(starting_date, current_date);
		write "time since the beginning of the simulation: " + total_duration;
		write "labor mean for step is: " + labor_mean;
		write "area deforest mean for is: " + area_deforest_mean;
		if current_date > date("2016-01-01") {
			stop_simulation <- true;
			do pause;
			write "END OF SIMULATION";
		}

	}
	//////////////////
	//////UPDATE//////
	//////////////////
	reflex update {
		step_end <- false;
		ask personas {
			do update;
		}
		//
		write "---PERSONAS UPDATED";
		//
		ask empresas {
			do generate_jobs;
		}
		//
		write "---NEW JOBS GENERATED";
		//
		if one_matches(cell, each.starting_wip = true) {
			ask cell where (each.starting_wip = true) {
				starting_wip <- false;
			}

		}

		ask cell where (each.grid_value = 3.0) {
			do crop_cycle;
			do update_yields;
		}
		//
		write "---CELLS UPDATED";
		//
		ask hogares {
			do assess_income_needs;
			do setting_alerts;
		}

	}
	//////////////////
	////////LUC///////
	//////////////////
	reflex LUC {

		ask hogares {
			if needs_alert = true {
				do looking_for_job;
				do assess_income_needs;
				do setting_alerts;
			}

		}

		ask hogares {
			if needs_alert = true {
				do subsistence_LUC;
			} else {
			//do profit_LUC;
			}

		}

		write "--START address work in progress";
		ask cell {
		//do update_yields;
			do address_wip;
			do color_activities;
		}

		write "--END address work in progress";
		write "END OF TURN/MONTH " + months_between(starting_date, current_date);
	}
	//////////////////
	/////Scenarios////
	//////////////////
	reflex launch_scenarios {
		if scenarios {
		}

		step_end <- true;
	}
	
	//////////////////
	/////Outputs//////
	//////////////////
	
	reflex when: every(5 #cycles) and save_years {
		save cell to: ("../exports/simu_month" + cycle + ".asc") type: "asc";
		write "EXPORT CLASSIF";
	}

}