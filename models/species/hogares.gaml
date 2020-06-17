/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/ model hogares_def //
//
// DEFINITION OF HOGARES (households)
//
//
import "../species_def.gaml"
species hogares {
	string sec_id;
	string hog_id;
	string viv_id;
	int Total_Personas;
	int Total_Hombres;
	int Total_Mujeres;
	predios my_predio;
	cell my_house;
	list<personas> membres_hogar;
	personas chef_hogar;
	string chef_auto_id;
	float labor_force;
	float occupied_workers;
	float available_workers;
	int employees_workers <- 0;
	float subcrops_needs;
	float gross_monthly_inc;
	float income;
	float estimated_annual_inc;
	string livelihood_strategy <- 'none';
	bool needs_alert <- false;
	bool hunger_alert <- false;
	bool money_alert <- false;
	bool labor_alert <- false;
	int oil_workers <- 0;

	action init_values {
		labor_force <- (sum(membres_hogar collect each.labor_value) * 30);
		available_workers <- labor_force;
		subcrops_needs <- (sum(membres_hogar collect each.food_needs));
	}

	//action update_values {
	//labor_force <- (sum(membres_hogar collect each.labor_value) * 30) + (employees_workers * 30) - (oil_workers * 14.0);
	//}
	action head_and_ethnicity {
		chef_hogar <- membres_hogar with_min_of each.orden_en_hogar;
		chef_auto_id <- chef_hogar.auto_id;
		if chef_auto_id = "indigena" {
			ask my_predio {
				indigena <- 100;
			}

		} else {
			ask my_predio {
				indigena <- 0;
			}

		}

	}

	action calcutility {
	}

	action subsistence_LUC {
		if hunger_alert {
			switch livelihood_strategy {
				match "SP1.1" {
					let needs <- subcrops_needs - my_predio.subcrops_amount;
					let stop <- false;
					loop while: (one_matches(my_predio.cells_inside, each.is_deforest = false)) and (needs > 0) and (stop = false) { //TODO: s'il y a au moins un pixel à déforester mais rajotuer aussi les friches longues!
						if available_workers > (laborcost_SC3_1) {
							ask 1 among (my_predio.cells_inside where (each.is_deforest = false)) {
								is_deforest <- true;
								landuse <- 'SC3.1';
								predio.subcrops_amount <- predio.subcrops_amount + 1;
								write "new deforestation for subsistence at " + location;
								myself.available_workers <- (myself.available_workers - laborcost_SC3_1);
								nb_months <- 0;
								add landuse to: land_use_hist;
							}
							needs <- subcrops_needs - my_predio.subcrops_amount;

						} else {
							write "pas assez de main d'oeuvre pour faire du subsistence LUC";
							stop <- true;
						}

					}

					//TODO: chantier en cours


					//					let possibility_SC2 <- false;
					//					let possibility_SC3_1 <- false;
					//					//let correspondence <- create_map ([possibility_SC2, possibility_SC3_1], ['yld_SC2', 'yld_SC3_1']);
					//					let possibilities <- [];
					//					//step 1: possibilities are identified
					//					if available_workers > laborcost_install_SC2 {
					//						possibility_SC2 <- true;
					//						add possibility_SC2 to: possibilities;
					//					}
					//
					//					if available_workers > laborcost_install_SC3 {
					//						possibility_SC3_1 <- true;
					//						add possibility_SC3_1 to: possibilities;
					//					}
					//					//step 2: determining the best possibility
					//					switch length(possibilities) {
					//						match 0 {
					//							write "no possibility...";
					//						}
					//
					//						match 1 {
					//							if possibility_SC2 in possibilities {
					//								ask one_of(my_predio.cells_inside where (each.is_deforest = false)) {
					//									is_deforest <- true;
					//									landuse <- 'SC2';
					//									write "new deforestation for subsistence at " + location;
					//									//TODO: penser à gérer le cout en MOF
					//									nb_months <- 0;
					//									add landuse to: land_use_hist;
					//								}
					//
					//							}
					//
					//							if possibilities contains possibility_SC3_1 {
					//								ask one_of(my_predio.cells_inside where (each.is_deforest = false)) {
					//									is_deforest <- true;
					//									landuse <- 'SC3.1';
					//									write "new deforestation for subsistence at " + location;
					//									//TODO: penser à gérer le cout en MOF
					//									nb_months <- 0;
					//									add landuse to: land_use_hist;
					//								}
					//
					//							}
					//
					//						}
					//
					//						match 2 {
					//							//let test1 <- possibilities at 0;
					//							//let test2 <- possibilities at 1;
					//							
					//							
					//
					//						}
					//
					//					}

				}

				match "SP1.2" {
				}

				match "SP1.3" {
				}

				match "SP2" {
				}

				match "SP3" {
				}

			}

		}

	}

	action profit_LUC {
		switch livelihood_strategy {
			match "SP1.2" {
			}

			match "SP1.3" {
			}

			match "SP2" {
			}

			match "SP3" {
			}

		}

	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}
