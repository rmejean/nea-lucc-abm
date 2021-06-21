/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
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
			switch grid_value {
				match 0.0 {
				//do die; //TODO: peut-être pas utile, ça a l'air de perturber les charts
				}

				match 1.0 {
					is_deforest <- nil;
					landuse <- 'water';
				}

				match 2.0 {
					is_deforest <- false;
					landuse <- 'forest';
				}

				match 3.0 {
					is_deforest <- true;
				}

				match 4.0 {
					is_deforest <- nil;
					landuse <- 'urban';
				}

			}

		}

		write "---END OF INIT CELLS";
	}

	action init_predios { //Plots init
		write "---START OF INIT PLOTS";
		create predios from: predios_con_def_shp;
		write "---END OF INIT PLOTS";
	}

	action init_comunas { //Comunas init
		write "---START OF INIT COMUNAS";
		create comunas from: comunas_shp with: [clave_cata::string(read('clave_cata'))];
		write "---END OF INIT COMUNAS";
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

	action init_pop_predios { //Population init with GENSTAR
		write "---START OF INIT PREDIOS POPULATION";
		write "------START OF SETUP PREDIOS HOUSEHOLDS";
		// --------------------------
		// Setup PREDIOS HOGARES
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
			type <- "predio";
			my_predio <- first(predios overlapping self);
			my_house <- first(my_predio.cells_deforest closest_to (vias closest_to self));
			location <- my_house.location;
			ask my_house {
				landuse <- 'house';
				grid_value <- 4.0;
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

		write "------END OF SETUP PREDIOS HOUSEHOLDS";
		write "------START OF SETUP PREDIOS PEOPLE"; //
		// --------------------------
		// Setup PREDIOS PERSONAS
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
			if my_hogar != nil {
				my_house <- my_hogar.my_house;
				location <- my_hogar.location;
				my_predio <- my_hogar.my_predio;
				do labour_value_and_needs;
			} else {
				do die;
			}

		}

		write "------END OF SETUP PREDIOS PEOPLE";
		write "---END OF INIT PREDIOS POPULATION";
	}

	action init_pop_comunas {
		write "---START OF INIT COMUNAS POPULATION";
		write "------START OF SETUP COMUNAS HOUSEHOLDS";
		// --------------------------
		// Setup COMUNAS HOGARES
		// --------------------------
		gen_population_generator hog_com_gen;
		hog_com_gen <- hog_com_gen with_generation_algo "US";
		hog_com_gen <- add_census_file(hog_com_gen, f_HOGARES_comunas.path, "Sample", ",", 1, 1);
		// --------------------------
		// Setup Attributs
		// --------------------------	
		hog_com_gen <- hog_com_gen add_attribute ("sec_id", string, list_id);
		hog_com_gen <- hog_com_gen add_attribute ("hog_id", string, list_id);
		hog_com_gen <- hog_com_gen add_attribute ("viv_id", string, list_id);
		hog_com_gen <- hog_com_gen add_attribute ("Total_Personas", int, echelle_pop);
		hog_com_gen <- hog_com_gen add_attribute ("Total_Hombres", int, echelle_pop);
		hog_com_gen <- hog_com_gen add_attribute ("Total_Mujeres", int, echelle_pop);
		// -------------------------
		// Spatialization 
		// -------------------------
		hog_com_gen <- hog_com_gen localize_on_geometries (comunas_shp.path);
		//hog_com_gen <- hog_com_gen add_capacity_constraint (1);//les comunas ne sont pas limitées à 1 ménage
		hog_com_gen <- hog_com_gen localize_on_census (sectores_shp.path);
		hog_com_gen <- hog_com_gen add_spatial_match (stringOfCensusIdInCSVfile, stringOfCensusIdInShapefile, 10 #km, 1 #km, 1); //à préciser
		create hogares from: hog_com_gen {
			type <- "comuna";
			livelihood_strategy <- "SP1.1";
			my_comuna <- first(comunas overlapping self);
			my_house <- first(my_comuna.cells_deforest);
			location <- my_house.location;
			ask my_house {
				landuse <- 'house';
				grid_value <- 4.0;
				is_free <- false;
				is_deforest <- nil;
			}

		}

		write "------END OF SETUP COMUNAS HOUSEHOLDS";
		write "------START OF SETUP COMUNAS PEOPLE"; //

		// --------------------------
		// Setup COMUNAS PERSONAS
		// --------------------------
		gen_population_generator pop_com_gen;
		pop_com_gen <- pop_com_gen with_generation_algo "US";
		pop_com_gen <- add_census_file(pop_com_gen, f_PERSONAS_comunas.path, "Sample", ",", 1, 1);
		// --------------------------
		// Setup Attributs
		// --------------------------	
		//pop_gen <- pop_gen add_attribute ("sec_id", string, list_id);
		pop_com_gen <- pop_com_gen add_attribute ("hog_id", string, list_id);
		//pop_gen <- pop_gen add_attribute ("viv_id", string, list_id);
		pop_com_gen <- pop_com_gen add_attribute ("Sexo", string, ["Hombre", "Mujer"]);
		pop_com_gen <- pop_com_gen add_attribute ("Age", int, echelle_ages);
		pop_com_gen <- pop_com_gen add_attribute ("mes_nac", string, []);
		pop_com_gen <- pop_com_gen add_attribute ("orden_en_hogar", int, echelle_GLOBALE);
		pop_com_gen <- pop_com_gen add_attribute ("auto_id", string, []);
		// --------------------------
		create personas from: pop_com_gen {
			my_hogar <- first(hogares where (each.hog_id = self.hog_id));
			if my_hogar != nil {
				my_house <- my_hogar.my_house;
				location <- my_hogar.location;
				my_comuna <- my_hogar.my_comuna;
				ask my_comuna {
					add myself to: membres_comuna;
				}

				do labour_value_and_needs;
			} else {
				do die;
			}

		}

		write "------END OF SETUP COMUNAS PEOPLE";
		write "---END OF INIT COMUNAS POPULATION";
		// --------------------------
		// Instructions post-génération
		// --------------------------
		ask hogares {
			membres_hogar <- personas where (each.hog_id = self.hog_id);
			if type = "predio" {
				do head_and_ethnicity;
			}

			do init_values;
		}

		ask comunas {
			com_labor_force <- (sum(membres_comuna collect each.labor_force));
			com_available_workers <- com_labor_force;
			com_occupied_workers <- com_labor_force - com_available_workers;
		}

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
		//		ask predios where (each.is_free = false) {
		//			do map_livelihood_strategies;
		//		}

	}

	action init_ALG {
		write "---START OF INIT PREDIOS ALG";
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
			let pxl_livestock <- 0;
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
					pxl_livestock <- pxl_livestock + 1;
				} else {
					save ("fallow" + "," + rnd(60)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
				}

				ask my_hogar {
					available_workers <- available_workers - (pxl_livestock * (pxl_livestock * laborcost_SE1_2 / 15)); //car calculs pour 15ha dans le mémoire de Lucie. Donc on adapte en fonction des ha générés
					occupied_workers <- occupied_workers + (pxl_livestock * (pxl_livestock * laborcost_SE1_2 / 15)); //donc on cherche le coût d'un pixel, qui dépend des pixels totaux qu'on a, puis ensuite on multiplie ce coût pour 1 px au nb de px qu'on a 
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
			let pxl_livestock <- 0;
			save ("type,months") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: true;
			loop while: pxl_generated != length(cells_deforest) {
				if flip(0.05) = false {
					save ("SE1.1" + "," + "0") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
					pxl_livestock <- pxl_livestock + 1;
				} else {
					save ("fallow" + "," + rnd(60)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
				}

				ask my_hogar {
					available_workers <- available_workers - (pxl_livestock * (pxl_livestock * laborcost_SE1_1 / 70)); //idem
					occupied_workers <- occupied_workers + (pxl_livestock * (pxl_livestock * laborcost_SE1_1 / 70)); //idem
				}

			}

		}

		write "------END OF INIT ALG SP3";
		write "---END OF INIT PREDIOS ALG";
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//--------------------------- COMUNAS ------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		write "---START OF INIT COMUNAS ALG";
		ask comunas {
			let pxl_generated <- 0;
			let pxl_subcrops <- 0;
			let pxl_coffee <- 0;
			save ("type,months") to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: true;
			loop while: pxl_generated != length(cells_deforest) {
				if comuna_subcrops_needs > pxl_subcrops and com_available_workers >= laborcost_SC3_1 {
					save ("SC3.1" + "," + rnd(30)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
					pxl_generated <- pxl_generated + 1;
					pxl_subcrops <- pxl_subcrops + 1;
					com_available_workers <- com_available_workers - laborcost_SC3_1;
					com_occupied_workers <- com_occupied_workers + laborcost_SC3_1;
				} else {
					if com_available_workers > laborcost_SC2 {
						save ("SC2" + "," + 0) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_generated <- pxl_generated + 1;
						pxl_coffee <- pxl_coffee + 1;
						com_available_workers <- com_available_workers - laborcost_SC2;
						com_occupied_workers <- com_occupied_workers + laborcost_SC2;
					} else {
						save ("fallow" + "," + rnd(60)) to: ("/init/ALG/" + name + "_ldsp.csv") rewrite: false;
						pxl_generated <- pxl_generated + 1;
					}

				}

			}

		}

		write "---END OF INIT COMUNAS ALG";
	}

	action init_farm_jobs {
		write "---START OF INIT FARM JOBS";
		ask hogares where (each.type = "predio") {
			if available_workers < 0 { //manage the employed labor force
				if (livelihood_strategy = "SP2") or (livelihood_strategy = "SP3") {
					employees_workers <- round(((0 - available_workers) / 30) + 0.5); //rounded up to the nearest whole number because workers are indivisible
					labor_force <- labor_force + (employees_workers * 30);
					occupied_workers <- occupied_workers + (employees_workers * 30);
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
		ask hogares where (each.type = "predio") {
			let no_more_jobs <- false;
			loop while: (available_workers >= 14.0) and length(job_candidates) > 0 and (oil_workers < oil_workers_max) and (no_more_jobs = false) {
				ask first(job_candidates) {
					if one_matches(empresas at_distance (5 #km), each.free_jobs > 0) {
						empresa <- empresas at_distance (5 #km) where (each.free_jobs > 0) closest_to self;
						write "" + empresa.name + " found a worker";
						oil_worker <- true;
						work_pace <- 14;
						job_wages <- job_wages;
						contract_term <- rnd(4, 12); //biblio : Morin (2015) p.76 "4 mois à une année"
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

		write "---END OF INIT OIL JOBS";
	}

	action init_control {
		save ("nbLS1.1,nbLS1.2,nbLS1.3,nbLS2,nbLS3") to: ("../exports/init_report") rewrite: false;
		save [nb_LS1_1, nb_LS1_2, nb_LS1_3, nb_LS2, nb_LS3] to: ("../exports/init_report") rewrite: true header: true;
	}

}

