/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model init_core

import "init_data_import.gaml"
import "species_def.gaml"
import "init_MCA_criteria.gaml"

global {
//Lists
	list<string> echelle_pop <- (list<string>(range(95)));
	list<string> echelle_ages <- (list<string>(range(105)));
	list<string> echelle_GLOBALE <- (list<string>(range(150)));
	list<string> list_id <- ([]);

	//-----------------------------
	//Farming activities parameters
	//-----------------------------

	//MOF -------------------------
	float MOFcost_maniocmais <- 9.0;
	float MOFcost_fruits <- 12.6;
	float MOFcost_s_livestock <- 6.4;
	float MOFcost_plantain <- 3.6;
	float MOFcost_coffee <- 3.1;
	float MOFcost_cacao <- 3.0;
	float MOFcost_livestock <- 20.5;
	float MOFcost_no_farming <- 0.0;

	//-----------------------------
	//Saving init------------------
	//-----------------------------
	bool init_end <- false;
	string save_landscape <- ("../initGENfiles/agricultural_landscape.shp");
	string save_predios <- ("../initGENfiles/predios.shp");
	string save_hogares <- ("../initGENfiles/hogares.shp");
	string save_personas <- ("../initGENfiles/personas.shp");

	//-----------------------------------------------------------------------------------------------
	//--------------------------------------INITIALIZATION-------------------------------------------
	//-----------------------------------------------------------------------------------------------
	action init_cells { //Cells init
		write "---START OF INIT CELLS";
		ask cell {
			if grid_value = 0.0 {
				do die;
			}

			if grid_value >= 3 {
				is_deforest <- true;
			} else {
				is_deforest <- false;
			}

		}

		write "---END OF INIT CELLS";
	}

	action init_predios { //Plots init
		write "---START OF INIT PLOTS";
		create predios from: predios_con_def_shp with: [clave_cata::string(read('clave_cata'))];
		ask predios {
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
		create vias from: vias_shp with: [orden::int(get("orden"))] {
		}

		write "---END OF INIT ROADS";
	}

	action init_pop { //Population init with GENSTAR
		write "---START OF INIT POPULATION";
		write "------START OF SETUP HOUSEHOLDS"; //
		// --------------------------
		// Setup HOGARES
		// --------------------------
		//
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
			location <- one_of(my_predio.cells_deforest).location; //A AMELIORER : first est trop régulier, one_of trop hasardeux
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
		//
		gen_population_generator pop_gen;
		pop_gen <- pop_gen with_generation_algo "US";
		pop_gen <- add_census_file(pop_gen, f_PERSONAS_predios.path, "Sample", ",", 1, 1);
		// --------------------------
		// Setup Attributs
		// --------------------------	
		pop_gen <- pop_gen add_attribute ("sec_id", string, list_id);
		pop_gen <- pop_gen add_attribute ("hog_id", string, list_id);
		pop_gen <- pop_gen add_attribute ("viv_id", string, list_id);
		pop_gen <- pop_gen add_attribute ("Sexo", string, ["Hombre", "Mujer"]);
		pop_gen <- pop_gen add_attribute ("Age", int, echelle_ages);
		pop_gen <- pop_gen add_attribute ("mes_nac", string, []);
		pop_gen <- pop_gen add_attribute ("orden_en_hogar", int, echelle_GLOBALE);
		pop_gen <- pop_gen add_attribute ("auto_id", string, []);
		// --------------------------
		create personas from: pop_gen {
			my_hogar <- first(hogares where (each.hog_id = self.hog_id));
			if my_hogar != nil {
				location <- my_hogar.location;
				my_predio <- my_hogar.my_predio;
				do values_calc;
			} else {
				do die;
			}

		}

		write "------END OF SETUP PEOPLE";
		// --------------------------
		// Instructions post-génération
		// --------------------------
		ask hogares {
			membres_hogar <- personas where (each.hog_id = self.hog_id);
			do setup_hogar;
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
		write "------START OF INIT ALG SP3";
		list<string> list_farming_activities <- (["maniocmais", "fruits", "s_livestock", "plantain", "coffee", "cacao", "livestock", "friche"]);
		ask predios where (each.LS = 'SP3') {
			gen_population_generator AL_genSP3;
			AL_genSP3 <- AL_genSP3 with_generation_algo "IS";
			AL_genSP3 <- add_census_file(AL_genSP3, f_FREQ_SP3.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP3 <- AL_genSP3 add_attribute ("type", string, list_farming_activities);
			AL_genSP3 <- AL_genSP3 add_attribute ("id", string, ["test"]);
			create patches from: AL_genSP3 number: length(self.cells_deforest where (each.is_free = true)) {
				if length(myself.cells_deforest where (each.is_free = true)) >= 1 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						cult <- myself.type;
						do param_activities;
					}

				}

				do die;
			}

		} //
		write "------END OF INIT ALG SP3";
		write "------START OF INIT ALG SP2"; //
		ask predios where (each.LS = 'SP2') {
			gen_population_generator AL_genSP2;
			AL_genSP2 <- AL_genSP2 with_generation_algo "IS";
			AL_genSP2 <- add_census_file(AL_genSP2, f_FREQ_SP2.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP2 <- AL_genSP2 add_attribute ("type", string, list_farming_activities);
			AL_genSP2 <- AL_genSP2 add_attribute ("id", string, ["test"]);
			create patches from: AL_genSP2 number: length(self.cells_deforest where (each.is_free = true)) {
				if length(myself.cells_deforest where (each.is_free = true)) >= 1 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						cult <- myself.type;
						do param_activities;
					}

				}

				do die;
			}

		} //
		write "------END OF INIT ALG SP2";
		write "------START OF INIT ALG SP1.1"; //
		ask predios where (each.LS = 'SP1.1') {
			gen_population_generator AL_genSP1_1;
			AL_genSP1_1 <- AL_genSP1_1 with_generation_algo "IS";
			AL_genSP1_1 <- add_census_file(AL_genSP1_1, f_FREQ_SP1_1.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_1 <- AL_genSP1_1 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_1 <- AL_genSP1_1 add_attribute ("id", string, ["test"]);
			create patches from: AL_genSP1_1 number: length(self.cells_deforest where (each.is_free = true)) {
				if length(myself.cells_deforest where (each.is_free = true)) >= 1 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						cult <- myself.type;
						do param_activities;
					}

				}

				do die;
			}

		} //
		write "------END OF INIT ALG SP1.1";
		write "------START OF INIT ALG SP1.2"; //
		ask predios where (each.LS = 'SP1.2') {
			gen_population_generator AL_genSP1_2;
			AL_genSP1_2 <- AL_genSP1_2 with_generation_algo "IS";
			AL_genSP1_2 <- add_census_file(AL_genSP1_2, f_FREQ_SP1_2.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_2 <- AL_genSP1_2 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_2 <- AL_genSP1_2 add_attribute ("id", string, ["test"]);
			create patches from: AL_genSP1_2 number: length(self.cells_deforest where (each.is_free = true)) {
				if length(myself.cells_deforest where (each.is_free = true)) >= 1 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						cult <- myself.type;
						do param_activities;
					}

				}

				do die;
			}

		} //
		write "------END OF INIT ALG SP1.2";
		write "------START OF INIT ALG SP1.3"; //
		ask predios where (each.LS = 'SP1.3') {
			gen_population_generator AL_genSP1_3;
			AL_genSP1_3 <- AL_genSP1_3 with_generation_algo "IS";
			AL_genSP1_3 <- add_census_file(AL_genSP1_3, f_FREQ_SP1_3.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_3 <- AL_genSP1_3 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_3 <- AL_genSP1_3 add_attribute ("id", string, ["test"]);
			create patches from: AL_genSP1_3 number: length(self.cells_deforest where (each.is_free = true)) {
				if length(myself.cells_deforest where (each.is_free = true)) >= 1 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						cult <- myself.type;
						do param_activities;
					}

				}

				do die;
			}

		} //
		write "------END OF INIT ALG 1.3";
		write "---END OF INIT ALG";
	}

	action init_needs {
		ask hogares {
			common_pot_inc <- sum(my_predio.cells_inside collect each.rev);
		}

		write "Calculation of the quantity of food crops & cash crops per plot...";
		ask predios where (each.is_free = false) {
			do update_needs;
			do map_eminent_LUC;
		}

		write "... calculation complete.";
	}

}