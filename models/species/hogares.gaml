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
	list<hogares> neighbors;
	list<hogares> social_network;
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
	int oil_workers_max <- round(Total_Personas / 3);
	list best_profit_LUC;

	action init_values {
		labor_force <- (sum(membres_hogar collect each.labor_value) * 30);
		available_workers <- labor_force;
		subcrops_needs <- (sum(membres_hogar collect each.food_needs));
	}

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
	
	//////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////
	///////////////////////////// SUBSISTENCE LUCC ///////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////

	action subsistence_LUC {
		switch livelihood_strategy {
			match "SP1.1" {
				let needs <- subcrops_needs - my_predio.subcrops_amount;
				let stop <- false;
				let new_SC3 <- 0;
				loop while: (one_matches(my_predio.cells_inside, each.is_deforest = false)) and (needs > 0) and (stop = false) { //TODO: s'il y a au moins un pixel à déforester mais rajotuer aussi les friches longues!
					if available_workers > (laborcost_SC3_1 + laborcost_install_SC3) {
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
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
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
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
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
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
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
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
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
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
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SE1.2';
							new_SE1_2 <- new_SE1_2 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

						money_missing <-
						(Total_Personas * $_ANFP) - (estimated_annual_inc + ((yld_veaux2 * price_veaux) + (yld_vachereforme2 * price_vachereforme) + (yld_cheese2 * price_cheese) - costmaint_cattle_2));
					} else {
						if available_workers > (laborcost_SE1_2 + (laborcost_install_SE1 / 2)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SE1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
								add landuse to: land_use_hist;
							}

						} else {
							if available_workers > (laborcost_SE1_2 + (laborcost_install_SE1 / 3)) {
								ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
									is_deforest <- true;
									landuse <- 'wip';
									future_landuse <- 'SE1.2';
									wip <- 2; //meaning: we will finish planting next month
									starting_wip <- true; //we just started planting
									wip_division <- 3;
									wip_laborforce <- wip_laborforce + laborcost_install_SE1;
									write "deforestation in progress for PROFIT at " + location;
									myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
									add landuse to: land_use_hist;
								}

							} else {
								write "pas assez de main d'oeuvre pour faire du money LUC";
								stop <- true;
							}

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
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SE1.1';
							new_SE1_1 <- new_SE1_1 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_1 + laborcost_install_SE1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

						money_missing <-
						(Total_Personas * $_ANFP) - (estimated_annual_inc + ((yld_veaux1 * price_veaux) + (yld_vachereforme1 * price_vachereforme) + (yld_cheese1 * price_cheese) - costmaint_cattle_2));
					} else {
						if available_workers > (laborcost_SE1_1 + (laborcost_install_SE1 / 2)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.1';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SE1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
								add landuse to: land_use_hist;
							}

						} else {
							if available_workers > (laborcost_SE1_1 + (laborcost_install_SE1 / 3)) {
								ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
									is_deforest <- true;
									landuse <- 'wip';
									future_landuse <- 'SE1.1';
									wip <- 2; //meaning: we will finish planting next month
									starting_wip <- true; //we just started planting
									wip_division <- 3;
									wip_laborforce <- wip_laborforce + laborcost_install_SE1;
									write "deforestation in progress for PROFIT at " + location;
									myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
									add landuse to: land_use_hist;
								}

							} else {
								write "pas assez de main d'oeuvre pour faire du money LUC";
								stop <- true;
							}

						}

					}

				}

				if new_SE1_1 > 0 {
					available_workers <- (available_workers + (new_SE1_1 * laborcost_install_SE1));
				}

			}

		}

	}
	
	//////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////// PROFIT LUC /////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////

	action profit_LUC {
		switch livelihood_strategy {
		//TODO: programmer le choix entre SC1 et SC2 : rajouter l'influence du voisinage ?
		// 
		//no instructions for SP1 as it doesn't make a profit LUC
		//
			match "SP1.2" {
				let new_SC1 <- 0;
				let new_SC2 <- 0;
				if index_of(profits_SP1_2, max(profits_SP1_2)) = 0 {//if the most profitable cash crop is SC1_1
					if (available_workers > (laborcost_SC1_1 + laborcost_install_SC1)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC1.1';
							new_SC1 <- new_SC1 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC1_1 + laborcost_install_SC1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if (available_workers > (laborcost_SC1_1 + (laborcost_install_SC1 / 2))) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC1.1';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC1_1 + laborcost_install_SC1 / wip_division));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						}

					}

				}

				if index_of(profits_SP1_2, max(profits_SP1_2)) = 1 {//if the most profitable cash crop is SC1_2
					if (available_workers > (laborcost_SC1_2 + laborcost_install_SC1)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC1.2';
							new_SC1 <- new_SC1 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC1_2 + laborcost_install_SC1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if (available_workers > (laborcost_SC1_2 + (laborcost_install_SC1 / 2))) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC1.2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC1_2 + laborcost_install_SC1 / wip_division));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						}

					}

				}

				if index_of(profits_SP1_2, max(profits_SP1_2)) = 2 {//if the most profitable cash crop is SC2
					if (available_workers > (laborcost_SC2 + laborcost_install_SC2)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC2';
							new_SC2 <- new_SC2 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if (available_workers > (laborcost_SC2 + (laborcost_install_SC2 / 2))) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC2;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2 / wip_division));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						}

					}

				}

				if new_SC1 > 0 {
					available_workers <- (available_workers + (new_SC1 * laborcost_install_SC1));
				}

				if new_SC2 > 0 {
					available_workers <- (available_workers + (new_SC2 * laborcost_install_SC2));
				}

			}

			match "SP1.3" {
				let new_SC1 <- 0;
				let new_SC2 <- 0;
				let new_SE1 <- 0;
				if index_of(profits_SP1_3, max(profits_SP1_3)) = 0 {
					if (available_workers > (laborcost_SC1_1 + laborcost_install_SC1)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC1.2';
							new_SC1 <- new_SC1 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC1_2 + laborcost_install_SC1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if (available_workers > (laborcost_SC1_1 + (laborcost_install_SC1 / 2))) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC1.1';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC1_1 + laborcost_install_SC1 / wip_division));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						}

					}

				}

				if index_of(profits_SP1_3, max(profits_SP1_3)) = 1 {
					if (available_workers > (laborcost_SC2 + laborcost_install_SC2)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SC2';
							new_SC2 <- new_SC2 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if (available_workers > (laborcost_SC2 + (laborcost_install_SC2 / 2))) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC2;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2 / wip_division));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						}

					}

				}

				if index_of(profits_SP1_3, max(profits_SP1_3)) = 2 {
					if (available_workers > (laborcost_SE1_2 + laborcost_install_SE1)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
						ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
							is_deforest <- true;
							landuse <- 'SE1.2';
							new_SE1 <- new_SE1 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1));
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if (available_workers > (laborcost_SE1_2 + (laborcost_install_SE1 / 2))) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
							ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SE1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1 / wip_division));
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						}

					}

				}

				if new_SC1 > 0 {
					available_workers <- (available_workers + (new_SC1 * laborcost_install_SC1));
				}

				if new_SC2 > 0 {
					available_workers <- (available_workers + (new_SC2 * laborcost_install_SC2));
				}

				if new_SE1 > 0 {
					available_workers <- (available_workers + (new_SE1 * laborcost_install_SE1));
				}

			}

			match "SP2" {
				let new_SE1 <- 0;
				if (available_workers > (laborcost_SE1_2 + laborcost_install_SE1)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
					ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
						is_deforest <- true;
						landuse <- 'SE1.2';
						new_SE1 <- new_SE1 + 1;
						write "new deforestation for PROFIT at " + location;
						myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1));
						nb_months <- 0;
						add landuse to: land_use_hist;
					}

				}

				if new_SE1 > 0 {
					available_workers <- (available_workers + (new_SE1 * laborcost_install_SE1));
				}

			}

			match "SP3" {
				let new_SE1 <- 0;
				if (available_workers > (laborcost_SE1_1 + laborcost_install_SE1)) and (one_matches(my_predio.cells_inside, each.is_deforest = false)) {
					ask closest_to(my_predio.cells_inside where (each.is_deforest = false), one_of(my_predio.cells_inside where (each.is_deforest = true)), 1) {
						is_deforest <- true;
						landuse <- 'SE1.1';
						new_SE1 <- new_SE1 + 1;
						write "new deforestation for PROFIT at " + location;
						myself.available_workers <- (myself.available_workers - (laborcost_SE1_1 + laborcost_install_SE1));
						nb_months <- 0;
						add landuse to: land_use_hist;
					}

				}

				if new_SE1 > 0 {
					available_workers <- (available_workers + (new_SE1 * laborcost_install_SE1));
				}

			}

		}

	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}
