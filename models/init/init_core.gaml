/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/ model init_core

import "init_data_import.gaml"
import "init_MCA_criteria.gaml"
import "../species_def.gaml"

global { //Lists
	list<string> echelle_pop <- (list<string>(range(95)));
	list<string> echelle_ages <- (list<string>(range(105)));
	list<string> echelle_GLOBALE <- (list<string>(range(150)));
	list<string> list_id <- ([]);
	//-----------------------------------------------------------------------------------------------
	//--------------------------------------INITIALIZATION-------------------------------------------
	//-----------------------------------------------------------------------------------------------
	action init_cells { //Cells init
		write "---START OF INIT CELLS";
		ask cell {
			if grid_value = 0.0 {
				do die; //TODO: peut-être pas utile, ça a l'air de perturber les charts
			}

			if grid_value = 2 {
				is_deforest <- false;
				landuse <- 'forest';
				add 'forest' to: land_use_hist;
			}

			if grid_value = 3 {
				is_deforest <- true;
			}

			if grid_value = 4 {
				is_deforest <- nil;
				landuse <- 'urban';
				add 'urban' to: land_use_hist;
			}

			if grid_value = 1 {
				is_deforest <- nil;
				landuse <- 'water';
				add 'water' to: land_use_hist;
			}

		}

		write "---END OF INIT CELLS";
	}

	action init_predios { //Plots init
		write "---START OF INIT PLOTS";
		create predios from: predios_con_def_shp with: [clave_cata::string(read('clave_cata'))] {
			if length(cells_deforest) = 0 { //Delete any plots with no deforestation
				do die;
			}

			do deforestation_rate_calc;
			do map_deforestation_rate;
		}

		write "---END OF INIT PLOTS";
	}

	action init_vias { //Roads init
		write "---START OF INIT ROADS";
		create vias from: vias_shp with: [orden::int(get("orden"))];
		write "---END OF INIT ROADS";
	}

	action init_empresas { //Oil companies init
		write "---START OF INIT OIL COMPANIES";
		create empresas from: plataformas_shp {
			nb_jobs <- rnd(0, 10); //number of jobs held by agents of the model by firm at init
			free_jobs <- nb_jobs;
		}

		write "---END OF INIT OIL COMPANIES";
	}

	action init_pop { //Population init with GENSTAR
		write "---START OF INIT POPULATION";
		write "------START OF SETUP HOUSEHOLDS";
		// --------------------------
		// Setup HOGARES
		// --------------------------
		gen_population_generator hog_gen;
		hog_gen <- hog_gen with_generation_algo "US";
		hog_gen <- add_census_file(hog_gen, f_HOGARES_predios.path, "Sample", ",", 1, 1);
		// --------------------------
		// Setup Attributs
		// --------------------------	
		hog_gen <- hog_gen add_attribute ("sec_id", string, list_id);
		hog_gen <- hog_gen add_attribute ("hog_id", string, list_id);
		hog_gen <- hog_gen add_attribute ("viv_id", string, list_id);
		hog_gen <- hog_gen add_attribute ("Total_Personas", int, echelle_pop);
		hog_gen <- hog_gen add_attribute ("Total_Hombres", int, echelle_pop);
		hog_gen <- hog_gen add_attribute ("Total_Mujeres", int, echelle_pop);
		// -------------------------
		// Spatialization 
		// -------------------------
		hog_gen <- hog_gen localize_on_geometries (predios_con_def_shp.path);
		hog_gen <- hog_gen add_capacity_constraint (1);
		hog_gen <- hog_gen localize_on_census (sectores_shp.path);
		hog_gen <- hog_gen add_spatial_match (stringOfCensusIdInCSVfile, stringOfCensusIdInShapefile, 35 #km, 1 #km, 1); //à préciser
		create hogares from: hog_gen {
			my_predio <- first(predios overlapping self);
			my_house <- first(my_predio.cells_deforest closest_to (vias closest_to self));
			location <- my_house.location;
			ask my_house {
				landuse <- 'house';
				is_free <- false;
				is_deforest <- nil;
			}

			ask my_predio {
				is_free <- false;
				is_free_MCA <- true;
				my_hogar <- myself;
			}

			ask my_predio.cells_inside {
				predio <- myself.my_predio;
			}

		}

		write "------END OF SETUP HOUSEHOLDS";
		write "------START OF SETUP PEOPLE"; //
		// --------------------------
		// Setup PERSONAS
		// --------------------------
		gen_population_generator pop_gen;
		pop_gen <- pop_gen with_generation_algo "US";
		pop_gen <- add_census_file(pop_gen, f_PERSONAS_predios.path, "Sample", ",", 1, 1);
		// --------------------------
		// Setup Attributs
		// --------------------------	
		//pop_gen <- pop_gen add_attribute ("sec_id", string, list_id);
		pop_gen <- pop_gen add_attribute ("hog_id", string, list_id);
		//pop_gen <- pop_gen add_attribute ("viv_id", string, list_id);
		pop_gen <- pop_gen add_attribute ("Sexo", string, ["Hombre", "Mujer"]);
		pop_gen <- pop_gen add_attribute ("Age", int, echelle_ages);
		pop_gen <- pop_gen add_attribute ("mes_nac", string, []);
		pop_gen <- pop_gen add_attribute ("orden_en_hogar", int, echelle_GLOBALE);
		pop_gen <- pop_gen add_attribute ("auto_id", string, []);
		// --------------------------
		create personas from: pop_gen {
			my_hogar <- first(hogares where (each.hog_id = self.hog_id));
			my_house <- my_hogar.my_house;
			if my_hogar != nil {
				location <- my_hogar.location;
				my_predio <- my_hogar.my_predio;
				do labour_value_and_needs;
			} else {
				do die;
			}

		}

		write "------END OF SETUP PEOPLE";
		// --------------------------
		// Instructions post-génération
		// --------------------------
		ask hogares {
			neighbors <- hogares closest_to (self, 5);
			membres_hogar <- personas where (each.hog_id = self.hog_id);
			do head_and_ethnicity;
			do init_values;
			ask my_predio.cells_inside {
				my_hogar <- myself;
			}

		}

		ask sectores {
			do carto_pop;
		}

		write "---END OF INIT POPULATION";
	}

	action init_LS_EMC { //Création des 5 agents-LS
		write "---START OF INIT LS with EMC";
		create LS_agents number: 1 {
			code_LS <- '1.1';
		}

		create LS_agents number: 1 {
			code_LS <- '1.2';
		}

		create LS_agents number: 1 {
			code_LS <- '1.3';
		}

		create LS_agents number: 1 {
			code_LS <- '2';
		}

		create LS_agents number: 1 {
			code_LS <- '3';
		}

		ask LS_agents {
			do ranking_MCA;
			do apply_MCA;
		}

		write "---END OF INIT LS WITH EMC";
		ask predios where (each.is_free = false) {
			do map_livelihood_strategies;
		}

	}

	action init_ALG {
		write "---START OF INIT ALG";
		list<string> list_farming_activities <- (["SC1.1", "SC1.2", "SC2", "SC3.1", "SC4.1", "SC4.2", "SE1.1", "SE1.2", "SE2.1", "SE2.2", "SE2.3", "SE3", "fallow"]); //------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//---------------------------- SP 1.1 ------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		write "------START OF INIT ALG SP1.1";
		ask predios where (each.LS = 'SP1.1') {
			let pxl_generated <- 0;
			let pxl_subcrops <- 0;
			let pxl_coffee_max <- rnd(1);
			let pxl_coffee <- 0;
			save ("type,months") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: true;
			loop while: pxl_generated != length(cells_deforest) {
				if my_hogar.subcrops_needs > pxl_subcrops and my_hogar.available_workers >= laborcost_SC3_1 {
					save ("SC3.1" + "," + rnd(30)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_subcrops <- pxl_subcrops + 1;
					pxl_generated <- pxl_generated + 1;
					ask my_hogar {
						available_workers <- available_workers - laborcost_SC3_1;
						occupied_workers <- occupied_workers + laborcost_SC3_1;
					}

				} else { //if food requirements are OK:
					if my_hogar.available_workers >= laborcost_SC2 and (pxl_coffee != pxl_coffee_max) {
						save ("SC2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_generated <- pxl_generated + 1;
						pxl_coffee <- pxl_coffee + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SC2;
							occupied_workers <- occupied_workers + laborcost_SC2;
						}

					} else {
						save ("fallow" + "," + rnd(125)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_generated <- pxl_generated + 1;
					}

				}

			} //generate the pixels from the written file
			gen_population_generator AL_genSP1_1;
			AL_genSP1_1 <- AL_genSP1_1 with_generation_algo "US";
			AL_genSP1_1 <- add_census_file(AL_genSP1_1, ("/init/ALG/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_1 <- AL_genSP1_1 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_1 <- AL_genSP1_1 add_attribute ("months", int, []);
			create patches from: AL_genSP1_1 {
				if length(myself.cells_deforest where (each.is_free = true)) != 0 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						landuse <- myself.type;
						nb_months <- myself.months;
						add landuse to: land_use_hist;
						do color_activities; //TODO: pas à répéter à chaque fois!
						do update_yields; //TODO: idem!
					}

				}

				do die;
			}

		}

		write "------END OF INIT ALG SP1.1";
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//---------------------------- SP 1.2 ------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		write "------START OF INIT ALG SP1.2";
		ask predios where (each.LS = 'SP1.2') {
			let pxl_generated <- 0;
			let pxl_subcrops <- 0;
			let pxl_cacao_max <- rnd(2);
			let pxl_coffee_max <- rnd(1);
			let pxl_cacao <- 0;
			let pxl_coffee <- 0;
			let pxl_chicken <- 0;
			let pxl_pig <- 0;
			save ("type,months") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: true;
			loop while: pxl_generated != length(cells_deforest) {
				if my_hogar.subcrops_needs > pxl_subcrops and my_hogar.available_workers >= laborcost_SC4_1 {
					if flip(0.5) = true {
						save ("SC4.1" + "," + rnd(30)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_subcrops <- pxl_subcrops + 1;
						pxl_generated <- pxl_generated + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SC4_1;
							occupied_workers <- occupied_workers + laborcost_SC4_1;
						}

					} else {
						save ("SC4.2" + "," + rnd(30)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_subcrops <- pxl_subcrops + 1;
						pxl_generated <- pxl_generated + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SC4_2;
							occupied_workers <- occupied_workers + laborcost_SC4_2;
						}

					}

				} else { //if food requirements are OK:
					if my_hogar.available_workers >= laborcost_SE3 and pxl_chicken < 1 { //chicken farming
						save ("SE3" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_chicken <- pxl_chicken + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SE3;
							occupied_workers <- occupied_workers + laborcost_SE3;
						}

					}

					if my_hogar.available_workers >= laborcost_SE2_1 and pxl_pig < 1 { //pig farming
						save ("SE2.1" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_pig <- pxl_pig + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SE2_1;
							occupied_workers <- occupied_workers + laborcost_SE2_1;
						}

					}

					if my_hogar.labor_force >= (pxl_cacao_max * laborcost_SC1_1) { //if I have enough labor to run the cocoa crop with inputs...
						if (my_hogar.available_workers >= laborcost_SC1_1) and (pxl_cacao != pxl_cacao_max) {
							save ("SC1.1" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
							pxl_generated <- pxl_generated + 1;
							pxl_cacao <- pxl_cacao + 1;
							ask my_hogar {
								available_workers <- available_workers - laborcost_SC1_1;
								occupied_workers <- occupied_workers + laborcost_SC1_1;
							}

						} else {
							if (my_hogar.available_workers >= laborcost_SC2) and (pxl_coffee != pxl_coffee_max) {
								save ("SC2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
								pxl_generated <- pxl_generated + 1;
								pxl_coffee <- pxl_coffee + 1;
								ask my_hogar {
									available_workers <- available_workers - laborcost_SC2;
									occupied_workers <- occupied_workers + laborcost_SC2;
								}

							} else {
								save ("fallow" + "," + rnd(65)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
								pxl_generated <- pxl_generated + 1;
							}

						}

					} else { //if I don't have enough labor to run the cocoa crop with inputs...
						if (my_hogar.available_workers >= laborcost_SC1_2) and (pxl_cacao != pxl_cacao_max) {
							save ("SC1.2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
							pxl_generated <- pxl_generated + 1;
							pxl_cacao <- pxl_cacao + 1;
							ask my_hogar {
								available_workers <- available_workers - laborcost_SC1_2;
								occupied_workers <- occupied_workers + laborcost_SC1_2;
							}

						} else {
							if (my_hogar.available_workers >= laborcost_SC2) and (pxl_coffee != pxl_coffee_max) {
								save ("SC2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
								pxl_generated <- pxl_generated + 1;
								pxl_coffee <- pxl_coffee + 1;
								ask my_hogar {
									available_workers <- available_workers - laborcost_SC2;
									occupied_workers <- occupied_workers + laborcost_SC2;
								}

							} else {
								save ("fallow" + "," + rnd(65)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
								pxl_generated <- pxl_generated + 1;
							}

						}

					}

				}

			} //generate the pixels from the written file
			gen_population_generator AL_genSP1_2;
			AL_genSP1_2 <- AL_genSP1_2 with_generation_algo "US";
			AL_genSP1_2 <- add_census_file(AL_genSP1_2, ("/init/ALG/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_2 <- AL_genSP1_2 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_2 <- AL_genSP1_2 add_attribute ("months", int, []);
			create patches from: AL_genSP1_2 {
				if type != "SE3" and type != "SE2.1" {
					if length(myself.cells_deforest where (each.is_free = true)) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
						ask pxl_cible {
							is_free <- false;
						}

						location <- pxl_cible.location;
						ask pxl_cible {
							landuse <- myself.type;
							nb_months <- myself.months;
							add landuse to: land_use_hist;
							do color_activities;
							do update_yields;
						}

					}

					do die;
				} else {
					if type = "SE3" { //chicken farming on the house pixel
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse2 <- myself.type;
								add landuse2 to: land_use_hist;
								do color_activities;
								do update_yields;
							}

						}

						do die;
					}

					if type = "SE2.1" { //chicken farming on the house pixel
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse3 <- myself.type;
								add landuse3 to: land_use_hist;
								do color_activities;
								do update_yields;
							}

						}

						do die;
					}

				}

			}

		}

		write "------END OF INIT ALG 1.2";
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//---------------------------- SP 1.3 ------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		write "------START OF INIT ALG SP1.3";
		ask predios where (each.LS = 'SP1.3') {
			let pxl_generated <- 0;
			let pxl_subcrops <- 0;
			let pxl_cacao_max <- rnd(3);
			let pxl_coffee_max <- rnd(1);
			let pxl_cacao <- 0;
			let pxl_coffee <- 0;
			let pxl_chicken <- 0;
			let pxl_pig <- 0;
			save ("type,months") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: true;
			loop while: pxl_generated != length(cells_deforest) {
				if my_hogar.subcrops_needs > pxl_subcrops and my_hogar.available_workers >= laborcost_SC4_1 {
					if flip(0.5) = true {
						save ("SC4.1" + "," + rnd(30)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_subcrops <- pxl_subcrops + 1;
						pxl_generated <- pxl_generated + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SC4_1;
							occupied_workers <- occupied_workers + laborcost_SC4_1;
						}

					} else {
						save ("SC4.2" + "," + rnd(30)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_subcrops <- pxl_subcrops + 1;
						pxl_generated <- pxl_generated + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SC4_2;
							occupied_workers <- occupied_workers + laborcost_SC4_2;
						}

					}

				} else { //if food requirements are OK:
					if my_hogar.available_workers >= laborcost_SE3 and pxl_chicken < 1 { //chicken farming
						save ("SE3" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_chicken <- pxl_chicken + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SE3;
							occupied_workers <- occupied_workers + laborcost_SE3;
						}

					}

					if my_hogar.available_workers >= laborcost_SE2_3 and pxl_pig < 1 { //pigs farming TODO: attribution à revoir (pas frocément prioritaire sur café/cacao et/ou gros élevage
						save ("SE2.3" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_pig <- pxl_pig + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SE2_3;
							occupied_workers <- occupied_workers + laborcost_SE2_3;
						}

					}

					if (my_hogar.available_workers >= laborcost_SC1_2) and (pxl_cacao != pxl_cacao_max) {
						save ("SC1.2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_generated <- pxl_generated + 1;
						pxl_cacao <- pxl_cacao + 1;
						ask my_hogar {
							available_workers <- available_workers - laborcost_SC1_2;
							occupied_workers <- occupied_workers + laborcost_SC1_2;
						}

					} else {
						if (my_hogar.available_workers >= laborcost_SC2) and (pxl_coffee != pxl_coffee_max) {
							save ("SC2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
							pxl_generated <- pxl_generated + 1;
							pxl_coffee <- pxl_coffee + 1;
							ask my_hogar {
								available_workers <- available_workers - laborcost_SC2;
								occupied_workers <- occupied_workers + laborcost_SC2;
							}

						} else {
							if (my_hogar.available_workers >= laborcost_SE1_2) {
								save ("SE1.2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
								pxl_generated <- pxl_generated + 1;
								ask my_hogar {
									available_workers <- available_workers - laborcost_SE1_2;
									occupied_workers <- occupied_workers + laborcost_SE1_2;
								}

							} else {
								save ("fallow" + "," + rnd(60)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
								pxl_generated <- pxl_generated + 1;
							}

						}

					}

				}

			} //generate the pixels from the written file
			gen_population_generator AL_genSP1_3;
			AL_genSP1_3 <- AL_genSP1_3 with_generation_algo "US";
			AL_genSP1_3 <- add_census_file(AL_genSP1_3, ("/init/ALG/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_3 <- AL_genSP1_3 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_3 <- AL_genSP1_3 add_attribute ("months", int, []);
			create patches from: AL_genSP1_3 {
				if type != "SE3" and type != "SE2.3" {
					if length(myself.cells_deforest where (each.is_free = true)) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
						ask pxl_cible {
							is_free <- false;
						}

						location <- pxl_cible.location;
						ask pxl_cible {
							landuse <- myself.type;
							nb_months <- myself.months;
							add landuse to: land_use_hist;
							do color_activities;
							do update_yields;
						}

					}

					do die;
				} else {
					if type = "SE3" {
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse2 <- myself.type;
								add landuse2 to: land_use_hist;
								do color_activities;
								do update_yields;
							}

						}

						do die;
					}

					if type = "SE2.3" {
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse3 <- myself.type;
								add landuse3 to: land_use_hist;
								do color_activities;
								do update_yields;
							}

						}

						do die;
					}

				}

			}

		}

		write "------END OF INIT ALG 1.3";
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//---------------------------- SP 2 --------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		write "------START OF INIT ALG SP2";
		ask predios where (each.LS = 'SP2') {
			let pxl_generated <- 0;
			let pxl_subcrops <- 0;
			let pxl_cash <- 0;
			let pxl_chicken <- 0;
			save ("type,months") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: true;
			loop while: pxl_generated != length(cells_deforest) {
				if my_hogar.available_workers >= laborcost_SE3 and pxl_chicken < 1 { //chicken farming
					save ("SE3" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_chicken <- pxl_chicken + 1;
					ask my_hogar {
						available_workers <- available_workers - laborcost_SE3;
						occupied_workers <- occupied_workers + laborcost_SE3;
					}

				}

				if flip(0.05) = false {
					save ("SE1.2" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
					ask my_hogar {
						available_workers <- available_workers - laborcost_SE1_2;
						occupied_workers <- occupied_workers + laborcost_SE1_2;
					}

				} else {
					save ("fallow" + "," + rnd(60)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
				}

			} //generate the pixels from the written file
			gen_population_generator AL_genSP2;
			AL_genSP2 <- AL_genSP2 with_generation_algo "US";
			AL_genSP2 <- add_census_file(AL_genSP2, ("/init/ALG/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP2 <- AL_genSP2 add_attribute ("type", string, list_farming_activities);
			AL_genSP2 <- AL_genSP2 add_attribute ("months", int, []);
			create patches from: AL_genSP2 {
				if type != "SE3" {
					if length(myself.cells_deforest where (each.is_free = true)) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
						ask pxl_cible {
							is_free <- false;
						}

						location <- pxl_cible.location;
						ask pxl_cible {
							landuse <- myself.type;
							nb_months <- myself.months;
							add landuse to: land_use_hist;
							do color_activities;
							do update_yields;
						}

					}

					do die;
				} else { //chicken farming on the house pixel
					if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
						location <- pxl_cible.location;
						ask pxl_cible {
							landuse2 <- myself.type;
							add landuse2 to: land_use_hist;
							do color_activities;
							do update_yields;
						}

					}

					do die;
				}

			}

		}

		write "------END OF INIT ALG SP2";
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//---------------------------- SP 3 --------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		write "------START OF INIT ALG SP3";
		ask predios where (each.LS = 'SP3') {
			let pxl_generated <- 0;
			let pxl_subcrops <- 0;
			let pxl_cash <- 0;
			save ("type,months") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: true;
			loop while: pxl_generated != length(cells_deforest) {
				if flip(0.05) = false {
					save ("SE1.1" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
					ask my_hogar {
						available_workers <- available_workers - laborcost_SE1_1;
						occupied_workers <- occupied_workers + laborcost_SE1_1;
					}

				} else {
					save ("fallow" + "," + rnd(60)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
				}

			} //generate the pixels from the written file
			gen_population_generator AL_genSP3;
			AL_genSP3 <- AL_genSP3 with_generation_algo "US";
			AL_genSP3 <- add_census_file(AL_genSP3, ("/init/ALG/" + name + "_ldsp.csv"), "Sample", ",", 1, 0); // --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP3 <- AL_genSP3 add_attribute ("type", string, list_farming_activities);
			AL_genSP3 <- AL_genSP3 add_attribute ("months", int, []);
			create patches from: AL_genSP3 {
				if length(myself.cells_deforest where (each.is_free = true)) != 0 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						landuse <- myself.type;
						nb_months <- myself.months;
						add landuse to: land_use_hist;
						do color_activities;
						do update_yields;
					}

				}

				do die;
			}

		}

		write "------END OF INIT ALG SP3";
		write "---END OF INIT ALG";
	}

	action init_farm_jobs {
		write "---START OF INIT FARM JOBS";
		ask hogares {
			if available_workers < 0 { //manage the employed labor force
				if (livelihood_strategy = "SP2") or (livelihood_strategy = "SP3") {
					employees_workers <- round(((0 - available_workers) / 30) + 0.5); //rounded up to the nearest whole number because workers are indivisible
					labor_force <- labor_force + (employees_workers * 30);
					available_workers <- labor_force - occupied_workers;
				}

				if (livelihood_strategy = "SP1.1") or (livelihood_strategy = "SP1.2") or (livelihood_strategy = "SP1.3") {
					labor_alert <- true;
				}

			}

		}

		write "---END OF INIT FARM JOBS";
	}

	action init_oil_jobs {
		write "---START OF INIT OIL JOBS";
		ask hogares {
			let no_more_jobs <- false;
			loop while: (available_workers >= 14.0) and (one_matches(membres_hogar, each.Age < 40 and each.oil_worker = false)) and (oil_workers < oil_workers_max) and
			(no_more_jobs = false) {
				ask first(membres_hogar where (each.Age < 40 and each.oil_worker = false)) {
					if one_matches(empresas, each.free_jobs > 0) {
						empresa <- empresas where (each.free_jobs > 0) closest_to self;
						write "" + empresa.name + " found a worker";
						oil_worker <- true;
						work_pace <- 14;
						job_wages <- 350;
						contract_term <- rnd(5, 7);
						working_months <- rnd(0, contract_term);
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

					} else {
						no_more_jobs <- true;
					}

				}

			}

		}

		ask personas where (each.oil_worker = true) { //co-worker's households (to be added to the social network)
			co_workers_hog <- empresa.workers collect each.my_hogar;
			co_workers_hog <- remove_duplicates(co_workers_hog);
			remove all: my_hogar from: co_workers_hog;
		}

		write "---END OF INIT OIL JOBS";
	}

	action init_social_network {
		write "---START OF INIT SOCIAL NETWORKS";
		ask personas {
			add all: co_workers_hog to: my_hogar.social_network;
		}

		ask hogares {
			add all: neighbors to: social_network;
		}

		write "---END OF INIT SOCIAL NETWORKS";
	}

	action assess_income_needs { //calculation of cash income (does not include food crops)
		write "---START OF INIT INCOMES AND ASSESS NEEDS SATISFACTION";
		ask hogares {
			if livelihood_strategy = "SP1.1" {
				gross_monthly_inc <- sum(my_predio.cells_inside where (each.landuse = "SC2") collect each.rev) + sum(membres_hogar collect each.job_wages);
				income <- gross_monthly_inc - (employees_workers * cost_employees);
				estimated_annual_inc <- (sum(my_predio.cells_inside where (each.landuse = "SC2") collect each.rev) * 12) + sum(membres_hogar collect
				each.annual_inc) - ((employees_workers * cost_employees) * 12);
				//TODO: corriger la perception du revenu annuel selon les cultures qui VONT entrer en production (le WIP)
			}
			//TODO: penser aux chèques des autorités pour le SP1
			if livelihood_strategy = "SP1.2" {
				gross_monthly_inc <- sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.1" or each.landuse = "SC1.2") collect each.rev + sum(membres_hogar collect
				each.job_wages));
				income <- gross_monthly_inc - (employees_workers * cost_employees);
				estimated_annual_inc <- (sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.1" or each.landuse = "SC1.2") collect
				each.rev) * 12) + sum(membres_hogar collect each.annual_inc) - ((employees_workers * cost_employees) * 12);
			}

			if livelihood_strategy = "SP1.3" {
				gross_monthly_inc <- sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.2" or each.landuse = "SE1.2" or each.landuse = "SE2.3") collect
				each.rev + sum(membres_hogar collect each.job_wages));
				income <- gross_monthly_inc - (employees_workers * cost_employees);
				estimated_annual_inc <- (sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.2" or each.landuse = "SE1.2" or each.landuse = "SE2.3") collect
				each.rev) * 12) + sum(membres_hogar collect each.annual_inc) - ((employees_workers * cost_employees) * 12);
			}

			if livelihood_strategy = "SP2" {
				gross_monthly_inc <- sum(my_predio.cells_inside collect each.rev) + sum(membres_hogar collect each.job_wages);
				income <- gross_monthly_inc - (employees_workers * cost_employees);
				estimated_annual_inc <- (sum(my_predio.cells_inside collect each.rev) * 12) + sum(membres_hogar collect each.annual_inc) - ((employees_workers * cost_employees) * 12);
			}

			if livelihood_strategy = "SP3" {
				gross_monthly_inc <- sum(my_predio.cells_inside collect each.rev) + sum(membres_hogar collect each.job_wages);
				income <- gross_monthly_inc - (employees_workers * cost_employees);
				estimated_annual_inc <- (sum(my_predio.cells_inside collect each.rev) * 12) + sum(membres_hogar collect each.annual_inc) - ((employees_workers * cost_employees) * 12);
			}

			ask my_predio {
				do crops_calc;
			}

		}

		write "---END OF INIT INCOMES AND ASSESS NEEDS SATISFACTION";
	}

	action setting_alerts {
		write "---START OF SETTING ALERTS";
		ask hogares {
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

		write "---END OF SETTING ALERTS";
	}

}

