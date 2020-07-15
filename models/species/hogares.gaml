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
	float wip_workers;
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

	action subsistence_LUC {
		switch livelihood_strategy {
			match "SP1.1" {
				let needs <- subcrops_needs - my_predio.subcrops_amount;
				let stop <- false;
				let new_SC3 <- 0;
				loop while: (one_matches(my_predio.cells_inside, each.is_deforest = false)) and (needs > 0) and (stop = false) { //TODO: s'il y a au moins un pixel à déforester mais rajotuer aussi les friches longues!
					if available_workers > (laborcost_SC3_1 + laborcost_install_SC3) {
						ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC3.1';
							new_SC3 <- new_SC3 + 1;
							predio.subcrops_amount <- predio.subcrops_amount + 1;
							write "new deforestation for subsistence at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC3_1 + laborcost_install_SC3));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

						needs <- subcrops_needs - my_predio.subcrops_amount;
					} else {
						write "pas assez de main d'oeuvre pour faire du subsistence LUC";
						stop <- true;
					}

				}

				if new_SC3 > 0 {
					available_workers <- (available_workers + (new_SC3 * laborcost_install_SC3));
				}

			}

			match "SP1.2" {
				let needs <- subcrops_needs - my_predio.subcrops_amount;
				let stop <- false;
				let new_SC4 <- 0;
				loop while: (one_matches(my_predio.cells_inside, each.is_deforest = false)) and (needs > 0) and (stop = false) {
					if available_workers > (laborcost_SC4_1 + laborcost_install_SC4) {
						ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC4.1';
							new_SC4 <- new_SC4 + 1;
							predio.subcrops_amount <- predio.subcrops_amount + 1;
							write "new deforestation for HUNGER at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC4_1 + laborcost_install_SC4));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

						needs <- subcrops_needs - my_predio.subcrops_amount;
					} else {
						if available_workers > (laborcost_SC4_2 + laborcost_install_SC4) {
							ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'SC4.2';
								new_SC4 <- new_SC4 + 1;
								predio.subcrops_amount <- predio.subcrops_amount + 1;
								write "new deforestation for HUNGER at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC4_2 + laborcost_install_SC4));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

							needs <- subcrops_needs - my_predio.subcrops_amount;
						} else {
							write "pas assez de main d'oeuvre pour faire du subsistence LUC";
							stop <- true;
						}

					}

				}

				if new_SC4 > 0 {
					available_workers <- (available_workers + (new_SC4 * laborcost_install_SC4));
				}

			}

			match "SP1.3" {
				let needs <- subcrops_needs - my_predio.subcrops_amount;
				let stop <- false;
				let new_SC4 <- 0;
				loop while: (one_matches(my_predio.cells_inside, each.is_deforest = false)) and (needs > 0) and (stop = false) {
					if available_workers > (laborcost_SC4_1 + laborcost_install_SC4) {
						ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC4.1';
							new_SC4 <- new_SC4 + 1;
							predio.subcrops_amount <- predio.subcrops_amount + 1;
							write "new deforestation for HUNGER at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC4_1 + laborcost_install_SC4));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

						needs <- subcrops_needs - my_predio.subcrops_amount;
					} else {
						if available_workers > (laborcost_SC4_2 + laborcost_install_SC4) {
							ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'SC4.2';
								new_SC4 <- new_SC4 + 1;
								predio.subcrops_amount <- predio.subcrops_amount + 1;
								write "new deforestation for HUNGER at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC4_2 + laborcost_install_SC4));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

							needs <- subcrops_needs - my_predio.subcrops_amount;
						} else {
							write "pas assez de main d'oeuvre pour faire du subsistence LUC";
							stop <- true;
						}

					}

				}

				if new_SC4 > 0 {
					available_workers <- (available_workers + (new_SC4 * laborcost_install_SC4));
				}

			}

			match "SP2" {
				let money_missing <- (Total_Personas * $_ANFP) - estimated_annual_inc;
				let stop <- false;
				let new_SE1_2 <- 0;
				loop while: (one_matches(my_predio.cells_inside, each.is_deforest = false)) and (money_missing > 0) and (stop = false) {
					if available_workers > (laborcost_SE1_2 + laborcost_install_SE1) {
						ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SE1.2';
							new_SE1_2 <- new_SE1_2 + 1;
							write "new deforestation for MONEY at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

						money_missing <-
						(Total_Personas * $_ANFP) - (estimated_annual_inc + ((yld_veaux * price_veaux) + (yld_vachereforme * price_vachereforme) + (yld_cheese * price_cheese) - costmaint_cattle_2));
					} else {
						if available_workers > (laborcost_SE1_2 + (laborcost_install_SE1 / 2)) {
							ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.2';
								wip <- 1; //signification : on termine de planter le mois prochain
								starting_wip <- true;//on vient de démarrer un wip ce tour-ci
								wip_division <- 2;
								wip_laborforce <- laborcost_install_SE1;
								write "deforestation in progress for MONEY at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
								add landuse to: land_use_hist;
							}

						} else {
							write "pas assez de main d'oeuvre pour faire du money LUC";
							stop <- true;
						}

					}

				}

				if new_SE1_2 > 0 {
					available_workers <- (available_workers + (new_SE1_2 * laborcost_install_SE1));
				}

			}

			match "SP3" {
				let money_missing <- (Total_Personas * $_ANFP) - estimated_annual_inc;
				let stop <- false;
				let new_SE1_1 <- 0;
				loop while: (one_matches(my_predio.cells_inside, each.is_deforest = false)) and (money_missing > 0) and (stop = false) {
					if available_workers > (laborcost_SE1_1 + laborcost_install_SE1) {
						ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SE1.1';
							new_SE1_1 <- new_SE1_1 + 1;
							write "new deforestation for MONEY at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_1 + laborcost_install_SE1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

						money_missing <-
						(Total_Personas * $_ANFP) - (estimated_annual_inc + ((yld_veaux * price_veaux) + (yld_vachereforme * price_vachereforme) + (yld_cheese * price_cheese) - costmaint_cattle_2));
					} else {
						if available_workers > (laborcost_SE1_1 + (laborcost_install_SE1 / 2)) {
							ask closest_to (my_predio.cells_inside where (each.is_deforest = false), one_of (my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.1';
								wip <- 1; //signification : on termine de planter le mois prochain
								starting_wip <- true;//on vient de démarrer un wip ce tour-ci
								wip_division <- 2;
								wip_laborforce <- laborcost_install_SE1;
								write "deforestation in progress for MONEY at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
								add landuse to: land_use_hist;
							}

						} else {
							write "pas assez de main d'oeuvre pour faire du money LUC";
							stop <- true;
						}

					}

				}

				if new_SE1_1 > 0 {
					available_workers <- (available_workers + (new_SE1_1 * laborcost_install_SE1));
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
