/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
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
	float $_ANFP <- 3900.0; //AMOUNT NEEDED TO FEED A PERSON = 3900 / 12
	//
	//INIT
	//
	init {
		if new_init = true {
			write "START OF INITIALIZATION FROM SCRATCH";
			do init_cells;
			do init_vias;
			do init_empresas;
			do init_predios; //do init_comunas;
			do init_pop;
			do init_LS_EMC;
			do init_ALG;
			do init_farm_jobs;
			do init_oil_jobs;
			do init_social_network;
			ask hogares {
				do assess_income_needs;
				do setting_alerts;
			}

			init_end <- true;
			write "END OF INITIALIZATION";
			write "Households don't have their needs met:" + length(hogares where (each.needs_alert = true));
		} else {
			write "START OF INITIALIZATION FROM A SAVED INIT";
			do init_saved_files;
			do init_cells;
			do init_vias;
			do load_saved_empresas;
			do load_saved_predios;
			do load_saved_hogares;
			do load_saved_personas;
			do load_saved_landscape;
			ask hogares {
				do assess_income_needs;
				do setting_alerts;
			}

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
		write "time (seconds): " + time;
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
		if social_network_inf {
			ask hogares {
				do update_social_network; //Car le contrat de travail de certains est terminé donc on enlève les collègues de travail du RS

			}
			//
			write "---SOCIAL NETWORKS UPDATED";
		}

		ask empresas {
			do generate_jobs;
		}
		//
		write "---NEW JOBS GENERATED";
		//
		ask cell {
			if starting_wip {
				starting_wip <- false;
			}

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
		if social_network_inf {
			ask hogares {
				do update_social_network; //car il faut rajouter au RS les collègues de travail de ceux qui viennent de trouver un job
			}
			//
			write "---SOCIAL NETWORKS UPDATED";
			//
		}

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

}