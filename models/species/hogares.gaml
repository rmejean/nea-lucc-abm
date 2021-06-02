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
	list<personas> job_candidates -> membres_hogar where (each.Age < 40 and each.oil_worker = false);
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
	float income_crops_annual;
	int income_oil_annual;
	string livelihood_strategy <- 'none';
	bool needs_alert <- false;
	bool hunger_alert <- false;
	bool money_alert <- false;
	bool labor_alert <- false;
	int oil_workers <- 0;
	int oil_workers_max <- round(Total_Personas / 3);
	list best_profit_LUC;
	string last_decision;

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

	action looking_for_job {
		let no_more_jobs <- false;
		loop while: (available_workers >= 14.0) and (length(job_candidates) > 0) and (oil_workers < oil_workers_max) and (no_more_jobs = false) {
			if one_matches(empresas at_distance (5 #km), each.free_jobs > 0) { //look for a job within 5km
				ask first(job_candidates) {
					empresa <- empresas where (each.free_jobs > 0) closest_to self;
					write "" + empresa.name + " found a worker";
					oil_worker <- true;
					work_pace <- 14;
					job_wages <- 350;
					contract_term <- rnd(5, 7);
					working_months <- 0;
					annual_inc <- contract_term * job_wages;
					ask empresa {
						free_jobs <- free_jobs - 1;
						add myself to: workers;
					}

					ask my_hogar {
						occupied_workers <- occupied_workers + myself.work_pace;
						available_workers <- available_workers - myself.work_pace;
						oil_workers <- oil_workers + 1;
					}

				}

			} else {
				no_more_jobs <- true;
			}

		}

	}

	action assess_income_needs { //calculation of cash income (does not include food crops)
		switch livelihood_strategy {
			match "SP1.1" {
				income_crops_annual <- (sum(my_predio.cells_inside where (each.landuse = "SC2") collect each.rev) * 12) - (employees_workers * cost_employees * 12);
				income_oil_annual <- sum(membres_hogar collect (each.job_wages * each.contract_term));
				estimated_annual_inc <- income_crops_annual + income_oil_annual;
			}

			match "SP1.2" {
				income_crops_annual <- (sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.1" or each.landuse = "SC1.2") collect
				each.rev) * 12) - (employees_workers * cost_employees * 12);
				income_oil_annual <- sum(membres_hogar collect (each.job_wages * each.contract_term));
				estimated_annual_inc <- income_crops_annual + income_oil_annual;
			}

			match "SP1.3" {
				income_crops_annual <- (sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.2" or each.landuse = "SE1.2" or each.landuse = "SE2.3") collect
				each.rev) * 12) - (employees_workers * cost_employees * 12);
				income_oil_annual <- sum(membres_hogar collect (each.job_wages * each.contract_term));
				estimated_annual_inc <- income_crops_annual + income_oil_annual;
			}

			match "SP2" {
				income_crops_annual <- (sum(my_predio.cells_inside collect each.rev) * 12) - (employees_workers * cost_employees * 12);
				income_oil_annual <- sum(membres_hogar collect (each.job_wages * each.contract_term));
				estimated_annual_inc <- income_crops_annual + income_oil_annual;
			}

			match "SP3" {
				income_crops_annual <- (sum(my_predio.cells_inside collect each.rev) * 12) - (employees_workers * cost_employees * 12);
				income_oil_annual <- sum(membres_hogar collect (each.job_wages * each.contract_term));
				estimated_annual_inc <- income_crops_annual + income_oil_annual;
			}

		}

		ask my_predio {
			do crops_calc;
		}

	}

	action setting_alerts {
		if (subcrops_needs > my_predio.subcrops_amount) {
			hunger_alert <- true;
		}

		if (($_ANFP * Total_Personas) > estimated_annual_inc) {
			money_alert <- true;
		}

		if hunger_alert and money_alert {
			needs_alert <- true;
		}

	}

	action update_social_network {
		ask personas {
			my_hogar.social_network <- nil;
			add all: co_workers_hog to: my_hogar.social_network;
		}

		add all: neighbors to: social_network;
	}

	action update_needs {
		subcrops_needs <- (sum(membres_hogar collect each.food_needs));
	}

	//////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////
	///////////////////////////// SUBSISTENCE LUCC ///////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////
	action subsistence_LUC {
		switch livelihood_strategy {

		///////////////////////////////////
		//////////////SP 1.1///////////////
		///////////////////////////////////
			match "SP1.1" {
				let needs <- subcrops_needs - my_predio.subcrops_amount;
				let stop <- false;
				loop while: length(my_predio.cells_forest) > 0 and (needs > 0) and (stop = false) { //TODO: s'il y a au moins un pixel à déforester mais rajouter aussi les friches longues!
					if available_workers > (laborcost_SC3_1 + laborcost_install_SC3) {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC3.1';
							grid_value <- 3.0;
							new_SC3 <- new_SC3 + 1;
							predio.subcrops_amount <- predio.subcrops_amount + 1;
							my_hogar.last_decision <- 'SC3.1';
							write "new SC3.1 for SUBSISTENCE at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC3_1 + laborcost_install_SC3));
							nb_months <- 0;
						}

						needs <- subcrops_needs - my_predio.subcrops_amount;
					} else {
						if available_workers > (laborcost_SC3_1 + (laborcost_install_SC3 / 2)) {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC3.1';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC3;
								predio.subcrops_amount <- predio.subcrops_amount + 1;
								my_hogar.last_decision <- 'SC3.1';
								write "SC3.1 in progress for SUBSISTENCE at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_install_SC3 / wip_division));
							}

							needs <- subcrops_needs - my_predio.subcrops_amount;
						} else {
							if available_workers > (laborcost_SC3_1 + (laborcost_install_SC3 / 3)) {
								ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
									is_deforest <- true;
									landuse <- 'wip';
									future_landuse <- 'SC3.1';
									wip <- 2; //meaning: we will finish planting in 2 months
									starting_wip <- true; //we just started planting
									wip_division <- 3;
									wip_laborforce <- wip_laborforce + laborcost_install_SC3;
									predio.subcrops_amount <- predio.subcrops_amount + 1;
									my_hogar.last_decision <- 'SC3.1';
									write "SC3.1 in progress for SUBSISTENCE at " + location;
									myself.available_workers <- (myself.available_workers - (laborcost_install_SC3 / wip_division));
								}

								needs <- subcrops_needs - my_predio.subcrops_amount;
							} else {
								if available_workers > (laborcost_SC3_1 + (laborcost_install_SC3 / 4)) {
									ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
										is_deforest <- true;
										landuse <- 'wip';
										future_landuse <- 'SC3.1';
										wip <- 3; //meaning: we will finish planting in 3 months
										starting_wip <- true; //we just started planting
										wip_division <- 4;
										wip_laborforce <- wip_laborforce + laborcost_install_SC3;
										predio.subcrops_amount <- predio.subcrops_amount + 1;
										my_hogar.last_decision <- 'SC3.1';
										write "SC3.1 in progress for SUBSISTENCE at " + location;
										myself.available_workers <- (myself.available_workers - (laborcost_install_SC3 / wip_division));
									}

									needs <- subcrops_needs - my_predio.subcrops_amount;
								} else {
									write "pas assez de main d'oeuvre pour faire du SUBSISTENCE LUC";
									stop <- true;
								}

							}

						}

					}

				}

			}

			///////////////////////////////////
			//////////////SP 1.2///////////////
			///////////////////////////////////
			match "SP1.2" {
				let needs <- subcrops_needs - my_predio.subcrops_amount;
				let stop <- false;
				loop while: length(my_predio.cells_forest) > 0 and (needs > 0) and (stop = false) {
					if available_workers > (laborcost_SC4_1 + laborcost_install_SC4) {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC4.1';
							grid_value <- 3.0;
							new_SC4 <- new_SC4 + 1;
							predio.subcrops_amount <- predio.subcrops_amount + 1;
							my_hogar.last_decision <- 'SC4.1';
							write "new SC4.1 for SUBSISTENCE at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC4_1 + laborcost_install_SC4));
							nb_months <- 0;
						}

						needs <- subcrops_needs - my_predio.subcrops_amount;
					} else {
						if available_workers > (laborcost_SC4_2 + laborcost_install_SC4) {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'SC4.2';
								grid_value <- 3.0;
								new_SC4 <- new_SC4 + 1;
								predio.subcrops_amount <- predio.subcrops_amount + 1;
								my_hogar.last_decision <- 'SC4.2';
								write "new SC4.2 for SUBSISTENCE at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC4_2 + laborcost_install_SC4));
								nb_months <- 0;
							}

							needs <- subcrops_needs - my_predio.subcrops_amount;
						} else {
							if available_workers > (laborcost_SC4_1 + (laborcost_install_SC4 / 2)) {
								ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
									is_deforest <- true;
									landuse <- 'wip';
									future_landuse <- 'SC4.1';
									wip <- 1; //meaning: we will finish planting next month
									starting_wip <- true; //we just started planting
									wip_division <- 2;
									wip_laborforce <- wip_laborforce + laborcost_install_SC4;
									predio.subcrops_amount <- predio.subcrops_amount + 1;
									my_hogar.last_decision <- 'SC4.1';
									write "SC4.1 in progress for SUBSISTENCE at " + location;
									myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
								}

								needs <- subcrops_needs - my_predio.subcrops_amount;
							} else {
								if available_workers > (laborcost_SC4_2 + (laborcost_install_SC4 / 2)) {
									ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
										is_deforest <- true;
										landuse <- 'wip';
										future_landuse <- 'SC4.2';
										wip <- 1; //meaning: we will finish planting next month
										starting_wip <- true; //we just started planting
										wip_division <- 2;
										wip_laborforce <- wip_laborforce + laborcost_install_SC4;
										predio.subcrops_amount <- predio.subcrops_amount + 1;
										my_hogar.last_decision <- 'SC4.2';
										write "SC4.2 in progress for SUBSISTENCE at " + location;
										myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
									}

									needs <- subcrops_needs - my_predio.subcrops_amount;
								} else {
									if available_workers > (laborcost_SC4_1 + (laborcost_install_SC4 / 3)) {
										ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
											is_deforest <- true;
											landuse <- 'wip';
											future_landuse <- 'SC4.1';
											wip <- 2; //meaning: we will finish planting in 2 months
											starting_wip <- true; //we just started planting
											wip_division <- 3;
											wip_laborforce <- wip_laborforce + laborcost_install_SC4;
											predio.subcrops_amount <- predio.subcrops_amount + 1;
											my_hogar.last_decision <- 'SC4.1';
											write "SC4.1 in progress for SUBSISTENCE at " + location;
											myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
										}

										needs <- subcrops_needs - my_predio.subcrops_amount;
									} else {
										if available_workers > (laborcost_SC4_2 + (laborcost_install_SC4 / 3)) {
											ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
												is_deforest <- true;
												landuse <- 'wip';
												future_landuse <- 'SC4.2';
												wip <- 2; //meaning: we will finish planting in 2 months
												starting_wip <- true; //we just started planting
												wip_division <- 3;
												wip_laborforce <- wip_laborforce + laborcost_install_SC4;
												predio.subcrops_amount <- predio.subcrops_amount + 1;
												my_hogar.last_decision <- 'SC4.2';
												write "SC4.2 in progress for SUBSISTENCE at " + location;
												myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
											}

											needs <- subcrops_needs - my_predio.subcrops_amount;
										} else {
											if available_workers > (laborcost_SC4_1 + (laborcost_install_SC4 / 4)) {
												ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
													is_deforest <- true;
													landuse <- 'wip';
													future_landuse <- 'SC4.1';
													wip <- 3; //meaning: we will finish planting in 3 months
													starting_wip <- true; //we just started planting
													wip_division <- 4;
													wip_laborforce <- wip_laborforce + laborcost_install_SC4;
													predio.subcrops_amount <- predio.subcrops_amount + 1;
													my_hogar.last_decision <- 'SC4.1';
													write "SC4.1 in progress for SUBSISTENCE at " + location;
													myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
												}

												needs <- subcrops_needs - my_predio.subcrops_amount;
											} else {
												if available_workers > (laborcost_SC4_2 + (laborcost_install_SC4 / 4)) {
													ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
														is_deforest <- true;
														landuse <- 'wip';
														future_landuse <- 'SC4.2';
														wip <- 3; //meaning: we will finish planting in 3 months
														starting_wip <- true; //we just started planting
														wip_division <- 4;
														wip_laborforce <- wip_laborforce + laborcost_install_SC4;
														predio.subcrops_amount <- predio.subcrops_amount + 1;
														my_hogar.last_decision <- 'SC4.2';
														write "SC4.2 in progress for SUBSISTENCE at " + location;
														myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
													}

													needs <- subcrops_needs - my_predio.subcrops_amount;
												} else {
													write "pas assez de main d'oeuvre pour faire du SUBSISTENCE LUC";
													stop <- true;
												}

											}

										}

									}

								}

							}

						}

					}

				}

			}

			///////////////////////////////////
			//////////////SP 1.3///////////////
			///////////////////////////////////
			match "SP1.3" {
				let needs <- subcrops_needs - my_predio.subcrops_amount;
				let stop <- false;
				loop while: length(my_predio.cells_forest) > 0 and (needs > 0) and (stop = false) {
					if available_workers > (laborcost_SC4_1 + laborcost_install_SC4) {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC4.1';
							grid_value <- 3.0;
							new_SC4 <- new_SC4 + 1;
							predio.subcrops_amount <- predio.subcrops_amount + 1;
							my_hogar.last_decision <- 'SC4.1';
							write "new SC4.1 for SUBSISTENCE at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC4_1 + laborcost_install_SC4));
							nb_months <- 0;
						}

						needs <- subcrops_needs - my_predio.subcrops_amount;
					} else {
						if available_workers > (laborcost_SC4_2 + laborcost_install_SC4) {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'SC4.2';
								grid_value <- 3.0;
								new_SC4 <- new_SC4 + 1;
								predio.subcrops_amount <- predio.subcrops_amount + 1;
								my_hogar.last_decision <- 'SC4.2';
								write "new SC4.2 for SUBSISTENCE at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC4_2 + laborcost_install_SC4));
								nb_months <- 0;
							}

							needs <- subcrops_needs - my_predio.subcrops_amount;
						} else {
							if available_workers > (laborcost_SC4_1 + (laborcost_install_SC4 / 2)) {
								ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
									is_deforest <- true;
									landuse <- 'wip';
									future_landuse <- 'SC4.1';
									wip <- 1; //meaning: we will finish planting next month
									starting_wip <- true; //we just started planting
									wip_division <- 2;
									wip_laborforce <- wip_laborforce + laborcost_install_SC4;
									predio.subcrops_amount <- predio.subcrops_amount + 1;
									my_hogar.last_decision <- 'SC4.1';
									write "SC4.1 in progress for SUBSISTENCE at " + location;
									myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
								}

								needs <- subcrops_needs - my_predio.subcrops_amount;
							} else {
								if available_workers > (laborcost_SC4_2 + (laborcost_install_SC4 / 2)) {
									ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
										is_deforest <- true;
										landuse <- 'wip';
										future_landuse <- 'SC4.2';
										wip <- 1; //meaning: we will finish planting next month
										starting_wip <- true; //we just started planting
										wip_division <- 2;
										wip_laborforce <- wip_laborforce + laborcost_install_SC4;
										predio.subcrops_amount <- predio.subcrops_amount + 1;
										my_hogar.last_decision <- 'SC4.2';
										write "SC4.2 in progress for SUBSISTENCE at " + location;
										myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
									}

									needs <- subcrops_needs - my_predio.subcrops_amount;
								} else {
									if available_workers > (laborcost_SC4_1 + (laborcost_install_SC4 / 3)) {
										ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
											is_deforest <- true;
											landuse <- 'wip';
											future_landuse <- 'SC4.1';
											wip <- 2; //meaning: we will finish planting in 2 months
											starting_wip <- true; //we just started planting
											wip_division <- 3;
											wip_laborforce <- wip_laborforce + laborcost_install_SC4;
											predio.subcrops_amount <- predio.subcrops_amount + 1;
											my_hogar.last_decision <- 'SC4.1';
											write "SC4.1 in progress for SUBSISTENCE at " + location;
											myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
										}

										needs <- subcrops_needs - my_predio.subcrops_amount;
									} else {
										if available_workers > (laborcost_SC4_2 + (laborcost_install_SC4 / 3)) {
											ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
												is_deforest <- true;
												landuse <- 'wip';
												future_landuse <- 'SC4.2';
												wip <- 2; //meaning: we will finish planting in 2 months
												starting_wip <- true; //we just started planting
												wip_division <- 3;
												wip_laborforce <- wip_laborforce + laborcost_install_SC4;
												predio.subcrops_amount <- predio.subcrops_amount + 1;
												my_hogar.last_decision <- 'SC4.2';
												write "SC4.2 in progress for SUBSISTENCE at " + location;
												myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
											}

											needs <- subcrops_needs - my_predio.subcrops_amount;
										} else {
											if available_workers > (laborcost_SC4_1 + (laborcost_install_SC4 / 4)) {
												ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
													is_deforest <- true;
													landuse <- 'wip';
													future_landuse <- 'SC4.1';
													wip <- 3; //meaning: we will finish planting in 3 months
													starting_wip <- true; //we just started planting
													wip_division <- 4;
													wip_laborforce <- wip_laborforce + laborcost_install_SC4;
													predio.subcrops_amount <- predio.subcrops_amount + 1;
													my_hogar.last_decision <- 'SC4.1';
													write "SC4.1 in progress for SUBSISTENCE at " + location;
													myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
												}

												needs <- subcrops_needs - my_predio.subcrops_amount;
											} else {
												if available_workers > (laborcost_SC4_2 + (laborcost_install_SC4 / 4)) {
													ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
														is_deforest <- true;
														landuse <- 'wip';
														future_landuse <- 'SC4.2';
														wip <- 3; //meaning: we will finish planting in 3 months
														starting_wip <- true; //we just started planting
														wip_division <- 4;
														wip_laborforce <- wip_laborforce + laborcost_install_SC4;
														predio.subcrops_amount <- predio.subcrops_amount + 1;
														my_hogar.last_decision <- 'SC4.2';
														write "SC4.2 in progress for SUBSISTENCE at " + location;
														myself.available_workers <- (myself.available_workers - (laborcost_install_SC4 / wip_division));
													}

													needs <- subcrops_needs - my_predio.subcrops_amount;
												} else {
													write "pas assez de main d'oeuvre pour faire du SUBSISTENCE LUC";
													stop <- true;
												}

											}

										}

									}

								}

							}

						}

					}

				}

			}

			///////////////////////////////////
			///////////////SP 2////////////////
			///////////////////////////////////
			match "SP2" {
				let money_missing <- (Total_Personas * $_ANFP) - estimated_annual_inc;
				let stop <- false;
				loop while: length(my_predio.cells_forest) > 0 and (money_missing > 0) and (stop = false) {
					if available_workers > (laborcost_SE1_2 + laborcost_install_SE1) {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SE1.2';
							grid_value <- 3.0;
							new_SE1_2 <- new_SE1_2 + 1;
							my_hogar.last_decision <- 'SE1.2';
							write "new SE1.2 for SUBSISTENCE at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1));
							nb_months <- 0;
						}

						money_missing <-
						(Total_Personas * $_ANFP) - ((estimated_annual_inc + ((yld_veaux2 * price_veaux) + (yld_vachereforme2 * price_vachereforme) + (yld_cheese2 * price_cheese) - costmaint_cattle_2)) * 12);
					} else {
						if available_workers > (laborcost_SE1_2 + (laborcost_install_SE1 / 2)) {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SE1;
								my_hogar.last_decision <- 'SE1.2';
								write "SE1.2 in progress for SUBSISTENCE at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
							}

							money_missing <-
							(Total_Personas * $_ANFP) - ((estimated_annual_inc + ((yld_veaux2 * price_veaux) + (yld_vachereforme2 * price_vachereforme) + (yld_cheese2 * price_cheese) - costmaint_cattle_2)) * 12);
						} else {
							if available_workers > (laborcost_SE1_2 + (laborcost_install_SE1 / 3)) {
								ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
									is_deforest <- true;
									landuse <- 'wip';
									future_landuse <- 'SE1.2';
									wip <- 2; //meaning: we will finish planting in 2 months
									starting_wip <- true; //we just started planting
									wip_division <- 3;
									wip_laborforce <- wip_laborforce + laborcost_install_SE1;
									my_hogar.last_decision <- 'SE1.2';
									write "SE1.2 in progress for SUBSISTENCE at " + location;
									myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
								}

								money_missing <-
								(Total_Personas * $_ANFP) - ((estimated_annual_inc + ((yld_veaux2 * price_veaux) + (yld_vachereforme2 * price_vachereforme) + (yld_cheese2 * price_cheese) - costmaint_cattle_2)) * 12);
							} else {
								write "pas assez de main d'oeuvre pour faire du SUBSISTENCE LUC";
								stop <- true;
							}

						}

					}

				}

			}

			///////////////////////////////////
			///////////////SP 3////////////////
			///////////////////////////////////
			match "SP3" {
				let money_missing <- (Total_Personas * $_ANFP) - estimated_annual_inc;
				let stop <- false;
				loop while: length(my_predio.cells_forest) > 0 and (money_missing > 0) and (stop = false) {
					if available_workers > (laborcost_SE1_1 + laborcost_install_SE1) {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SE1.1';
							grid_value <- 3.0;
							new_SE1_1 <- new_SE1_1 + 1;
							my_hogar.last_decision <- 'SE1.1';
							write "new SE1.1 for SUBSISTENCE at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_1 + laborcost_install_SE1));
							nb_months <- 0;
						}

						money_missing <-
						(Total_Personas * $_ANFP) - ((estimated_annual_inc + ((yld_veaux1 * price_veaux) + (yld_vachereforme1 * price_vachereforme) + (yld_cheese1 * price_cheese) - costmaint_cattle_1)) * 12);
					} else {
						if available_workers > (laborcost_SE1_1 + (laborcost_install_SE1 / 2)) {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.1';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SE1;
								my_hogar.last_decision <- 'SE1.1';
								write "SE1.1 in progress for SUBSISTENCE at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
							}

							money_missing <-
							(Total_Personas * $_ANFP) - ((estimated_annual_inc + ((yld_veaux1 * price_veaux) + (yld_vachereforme1 * price_vachereforme) + (yld_cheese1 * price_cheese) - costmaint_cattle_1)) * 12);
						} else {
							if available_workers > (laborcost_SE1_1 + (laborcost_install_SE1 / 3)) {
								ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
									is_deforest <- true;
									landuse <- 'wip';
									future_landuse <- 'SE1.1';
									wip <- 2; //meaning: we will finish planting in 2 months
									starting_wip <- true; //we just started planting
									wip_division <- 3;
									wip_laborforce <- wip_laborforce + laborcost_install_SE1;
									my_hogar.last_decision <- 'SE1.1';
									write "SE1.1 in progress for SUBSISTENCE at " + location;
									myself.available_workers <- (myself.available_workers - (laborcost_install_SE1 / wip_division));
								}

								money_missing <-
								(Total_Personas * $_ANFP) - ((estimated_annual_inc + ((yld_veaux1 * price_veaux) + (yld_vachereforme1 * price_vachereforme) + (yld_cheese1 * price_cheese) - costmaint_cattle_1)) * 12);
							} else {
								write "pas assez de main d'oeuvre pour faire du SUBSISTENCE LUC";
								stop <- true;
							}

						}

					}

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
				if index_of(profits_SP1_2, max(profits_SP1_2)) = 0 { //if the most profitable cash crop is SC1_1
					if (available_workers > (laborcost_SC1_1 + laborcost_install_SC1)) and length(my_predio.cells_deforest) > 0 {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC1.1';
							grid_value <- 3.0;
							new_SC1 <- new_SC1 + 1;
							my_hogar.last_decision <- 'SC1.1';
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC1_1 + laborcost_install_SC1));
							nb_months <- 0;
						}

					} else {
						if (available_workers > (laborcost_SC1_1 + (laborcost_install_SC1 / 2))) and length(my_predio.cells_deforest) > 0 {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC1.1';
								my_hogar.last_decision <- 'SC1.1';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC1_1 + laborcost_install_SC1 / wip_division));
								nb_months <- 0;
							}

						}

					}

				}

				if index_of(profits_SP1_2, max(profits_SP1_2)) = 1 { //if the most profitable cash crop is SC1_2
					if (available_workers > (laborcost_SC1_2 + laborcost_install_SC1)) and length(my_predio.cells_deforest) > 0 {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC1.2';
							grid_value <- 3.0;
							new_SC1 <- new_SC1 + 1;
							my_hogar.last_decision <- 'SC1.2';
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC1_2 + laborcost_install_SC1));
							nb_months <- 0;
						}

					} else {
						if (available_workers > (laborcost_SC1_2 + (laborcost_install_SC1 / 2))) and length(my_predio.cells_deforest) > 0 {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC1.2';
								my_hogar.last_decision <- 'SC1.2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC1_2 + laborcost_install_SC1 / wip_division));
								nb_months <- 0;
							}

						}

					}

				}

				if index_of(profits_SP1_2, max(profits_SP1_2)) = 2 { //if the most profitable cash crop is SC2
					if (available_workers > (laborcost_SC2 + laborcost_install_SC2)) and length(my_predio.cells_deforest) > 0 {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC2';
							grid_value <- 3.0;
							my_hogar.last_decision <- 'SC2';
							new_SC2 <- new_SC2 + 1;
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2));
							nb_months <- 0;
						}

					} else {
						if (available_workers > (laborcost_SC2 + (laborcost_install_SC2 / 2))) and length(my_predio.cells_deforest) > 0 {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC2';
								my_hogar.last_decision <- 'SC2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC2;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2 / wip_division));
								nb_months <- 0;
							}

						}

					}

				}

			}

			match "SP1.3" {
				if index_of(profits_SP1_3, max(profits_SP1_3)) = 0 {
					if (available_workers > (laborcost_SC1_1 + laborcost_install_SC1)) and length(my_predio.cells_deforest) > 0 {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC1.2';
							grid_value <- 3.0;
							new_SC1 <- new_SC1 + 1;
							my_hogar.last_decision <- 'SC1.2';
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC1_2 + laborcost_install_SC1));
							nb_months <- 0;
						}

					} else {
						if (available_workers > (laborcost_SC1_1 + (laborcost_install_SC1 / 2))) and length(my_predio.cells_deforest) > 0 {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC1.2';
								my_hogar.last_decision <- 'SC1.2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC1_1 + laborcost_install_SC1 / wip_division));
								nb_months <- 0;
							}

						}

					}

				}

				if index_of(profits_SP1_3, max(profits_SP1_3)) = 1 {
					if (available_workers > (laborcost_SC2 + laborcost_install_SC2)) and length(my_predio.cells_deforest) > 0 {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SC2';
							grid_value <- 3.0;
							new_SC2 <- new_SC2 + 1;
							my_hogar.last_decision <- 'SC2';
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2));
							nb_months <- 0;
						}

					} else {
						if (available_workers > (laborcost_SC2 + (laborcost_install_SC2 / 2))) and length(my_predio.cells_deforest) > 0 {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SC2';
								my_hogar.last_decision <- 'SC2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SC2;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SC2 + laborcost_install_SC2 / wip_division));
								nb_months <- 0;
							}

						}

					}

				}

				if index_of(profits_SP1_3, max(profits_SP1_3)) = 2 {
					if (available_workers > (laborcost_SE1_2 + laborcost_install_SE1)) and length(my_predio.cells_deforest) > 0 {
						ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
							is_deforest <- true;
							landuse <- 'SE1.2';
							grid_value <- 3.0;
							new_SE1 <- new_SE1 + 1;
							my_hogar.last_decision <- 'SE1.2';
							write "new deforestation for PROFIT at " + location;
							myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1));
							nb_months <- 0;
						}

					} else {
						if (available_workers > (laborcost_SE1_2 + (laborcost_install_SE1 / 2))) and length(my_predio.cells_deforest) > 0 {
							ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
								is_deforest <- true;
								landuse <- 'wip';
								future_landuse <- 'SE1.2';
								my_hogar.last_decision <- 'SE1.2';
								wip <- 1; //meaning: we will finish planting next month
								starting_wip <- true; //we just started planting
								wip_division <- 2;
								wip_laborforce <- wip_laborforce + laborcost_install_SE1;
								write "deforestation in progress for PROFIT at " + location;
								myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1 / wip_division));
								nb_months <- 0;
							}

						}

					}

				}

			}

			match "SP2" {
				if (available_workers > (laborcost_SE1_2 + laborcost_install_SE1)) and length(my_predio.cells_deforest) > 0 {
					ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
						is_deforest <- true;
						landuse <- 'SE1.2';
						grid_value <- 3.0;
						new_SE1 <- new_SE1 + 1;
						my_hogar.last_decision <- 'SE1.2';
						write "new deforestation for PROFIT at " + location;
						myself.available_workers <- (myself.available_workers - (laborcost_SE1_2 + laborcost_install_SE1));
						nb_months <- 0;
					}

				}

			}

			match "SP3" {
				if (available_workers > (laborcost_SE1_1 + laborcost_install_SE1)) and length(my_predio.cells_deforest) > 0 {
					ask closest_to(my_predio.cells_forest, one_of(my_predio.cells_deforest), 1) {
						is_deforest <- true;
						landuse <- 'SE1.1';
						grid_value <- 3.0;
						new_SE1 <- new_SE1 + 1;
						my_hogar.last_decision <- 'SE1.1';
						write "new deforestation for PROFIT at " + location;
						myself.available_workers <- (myself.available_workers - (laborcost_SE1_1 + laborcost_install_SE1));
						nb_months <- 0;
					}

				}

			}

		}

	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}
