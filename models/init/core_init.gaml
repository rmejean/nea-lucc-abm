/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model core_init

import "data_import.gaml"
import "species_def.gaml"
import "MCA_criteria.gaml"

global {

//Lists
	list<string> echelle_pop <- (list<string>(range(95)));
	list<string> echelle_ages <- (list<string>(range(105)));
	list<string> echelle_GLOBALE <- (list<string>(range(150)));
	list<string> list_id <- ([]);

	//Global variables for monitors
	int nb_menages -> length(hogares);
	int nb_personas -> length(personas);
	int nb_predios -> length(predios);
	int nb_patches -> length(patches);
	float ratio_deforest_min -> predios min_of (each.def_rate);
	float ratio_deforest_max -> predios max_of (each.def_rate);
	float ratio_deforest_mean -> predios mean_of (each.def_rate);
	int area_min -> predios min_of (each.area_total);
	int area_max -> predios max_of (each.area_total);
	float area_mean -> predios mean_of (each.area_total);
	int area_deforest_min -> predios min_of (each.area_deforest);
	int area_deforest_max -> predios max_of (each.area_deforest);
	float area_deforest_mean -> predios mean_of (each.area_deforest);

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
	//Life cost --------------------
	float $_ANFP <- 250.0; //AMOUNT NEEDED TO FEED A PERSON - à établir
	//Saving init
	bool init_end <- false;
	string save_landscape <- ("../results/agricultural_landscape.shp");
	string save_predios <- ("../results/predios.shp");
	string save_hogares <- ("../results/hogares.shp");
	string save_personas <- ("../results/personas.shp");

	//-----------------------------------------------------------------------------------------------
	//--------------------------------------INITIALIZATION-------------------------------------------
	//-----------------------------------------------------------------------------------------------
	init {
		write "START OF INITIALIZATION";
		do init_cells;
		do init_vias;
		do init_predios;
		//do init_comunas;
		do init_pop;
		//do init_LS;
		do init_LS_EMC;
		do init_ALG;
		do init_revenu;
		write "END OF INITIALIZATION";
		init_end <- true;
	}

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

			do calcul_tx_deforest;
			do carto_tx_deforest;
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
		write "------START OF SETUP HOUSEHOLDS";
		//
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
		hog_gen <- hog_gen add_spatial_match (stringOfCensusIdInCSVfile, stringOfCensusIdInShapefile, 5 #km, 1 #km, 1); //à préciser
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
		write "------START OF SETUP PEOPLE";
		//
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
		pop_gen <- pop_gen add_attribute ("orden_en_hogar", int, echelle_GLOBALE);
		pop_gen <- pop_gen add_attribute ("auto_id", string, []);
		// --------------------------
		create personas from: pop_gen {
			my_hogar <- first(hogares where (each.hog_id = self.hog_id));
			if my_hogar != nil {
				location <- my_hogar.location;
				my_predio <- my_hogar.my_predio;
				if orden_en_hogar = 1 {
					chef <- true;
				} else {
					chef <- false;
				}

				do vMOF_calc;
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
			chef_hogar <- one_of(membres_hogar where (each.chef = true));
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

			do MOF_calc;
			ask my_predio.cells_inside {
				my_hogar <- myself;
			}

		}

		ask sectores {
			do carto_pop;
		}

		write "---END OF INIT POPULATION";
	}

	action init_LS { //ESSAI (provisoire ou forçage si besoin)
	//---------------------------------------------------------
	//Initialisation des LS (livelihood strategies) des ménages
	//---------------------------------------------------------
		write "---START OF INIT LS";
		ask hogares {
		//SP3 : basé sur la taille des parcelles (pâturages)
			if my_predio.area_deforest > 50 {
				float proba <- rnd(100.00);
				if proba < 66.666 {
					livelihood_strategy <- 'SP3';
					my_predio.LS <- 'SP3';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP2';
					my_predio.LS <- 'SP2';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP1.1';
					my_predio.LS <- 'SP1.1';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.2';
					my_predio.LS <- 'SP1.2';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
					my_predio.LS <- 'SP1.3';
				}

			}
			//SP2 : basé sur la taille des parcelles (pâturages)
			if my_predio.area_deforest between (10, 50) {
				float proba <- rnd(100.0);
				if proba < 66.666 {
					livelihood_strategy <- 'SP2';
					my_predio.LS <- 'SP2';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP3';
					my_predio.LS <- 'SP3';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP1.1';
					my_predio.LS <- 'SP1.1';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.2';
					my_predio.LS <- 'SP1.2';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
					my_predio.LS <- 'SP1.3';
				}

			}
			//SP1.1 : basé sur l'éloignement à la route principale (via Auca, indigènes et comunas)
			if distance_to(my_predio, vias where (each.orden = 1) closest_to self) > 4 #km {
				float proba <- rnd(100.0);
				if proba < 66.666 {
					livelihood_strategy <- 'SP1.1';
					my_predio.LS <- 'SP1.1';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP3';
					my_predio.LS <- 'SP3';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP2';
					my_predio.LS <- 'SP2';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.2';
					my_predio.LS <- 'SP1.2';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
					my_predio.LS <- 'SP1.3';
				}

			}
			//SP1.2 : basé sur la proximité aux routes secondaires
			if distance_to(my_predio, vias where (each.orden = 2) closest_to self) < distance_to(my_predio, vias where (each.orden = 1) closest_to self) {
				float proba <- rnd(100.0);
				if proba < 66.666 {
					livelihood_strategy <- 'SP1.2';
					my_predio.LS <- 'SP1.2';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP3';
					my_predio.LS <- 'SP3';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP2';
					my_predio.LS <- 'SP2';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.1';
					my_predio.LS <- 'SP1.1';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
					my_predio.LS <- 'SP1.3';
				}

			}

			write "Livelihood strategies affected (temporary procedure)";
		}

		ask predios where (each.is_free = false) {
			do carto_LS;
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
		ask predios where (each.is_free = false) {
			do carto_LS;
		}

	}

	action init_ALG {
		write "---START OF INIT ALG";
		write "------START OF INIT ALG SP3";
		ask predios where (each.LS = 'SP3') {
			gen_population_generator AL_genSP3;
			AL_genSP3 <- AL_genSP3 with_generation_algo "IS";
			AL_genSP3 <- add_census_file(AL_genSP3, f_FREQ_SP3.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			list<string> list_farming_activities <- (["maniocmais", "fruits", "s_livestock", "plantain", "coffee", "cacao", "livestock", "friche"]);
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

		}
		//
		write "------END OF INIT ALG SP3";
		write "------START OF INIT ALG SP2";
		//
		ask predios where (each.LS = 'SP2') {
			gen_population_generator AL_genSP2;
			AL_genSP2 <- AL_genSP2 with_generation_algo "IS";
			AL_genSP2 <- add_census_file(AL_genSP2, f_FREQ_SP2.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			list<string> list_farming_activities <- (["maniocmais", "fruits", "s_livestock", "plantain", "coffee", "cacao", "livestock", "friche"]);
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

		}
		//
		write "------END OF INIT ALG SP2";
		write "------START OF INIT ALG SP1.1";
		//
		ask predios where (each.LS = 'SP1.1') {
			gen_population_generator AL_genSP1_1;
			AL_genSP1_1 <- AL_genSP1_1 with_generation_algo "IS";
			AL_genSP1_1 <- add_census_file(AL_genSP1_1, f_FREQ_SP1_1.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			list<string> list_farming_activities <- (["maniocmais", "fruits", "s_livestock", "plantain", "coffee", "cacao", "livestock", "friche"]);
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

		}
		//
		write "------END OF INIT ALG SP1.1";
		write "------START OF INIT ALG SP1.2";
		//
		ask predios where (each.LS = 'SP1.2') {
			gen_population_generator AL_genSP1_2;
			AL_genSP1_2 <- AL_genSP1_2 with_generation_algo "IS";
			AL_genSP1_2 <- add_census_file(AL_genSP1_2, f_FREQ_SP1_2.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			list<string> list_farming_activities <- (["maniocmais", "fruits", "s_livestock", "plantain", "coffee", "cacao", "livestock", "friche"]);
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

		}
		//
		write "------END OF INIT ALG SP1.2";
		write "------START OF INIT ALG SP1.3";
		//
		ask predios where (each.LS = 'SP1.3') {
			gen_population_generator AL_genSP1_3;
			AL_genSP1_3 <- AL_genSP1_3 with_generation_algo "IS";
			AL_genSP1_3 <- add_census_file(AL_genSP1_3, f_FREQ_SP1_3.path, "GlobalFrequencyTable", ",", 1, 1);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			list<string> list_farming_activities <- (["maniocmais", "fruits", "s_livestock", "plantain", "coffee", "cacao", "livestock", "friche"]);
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

		}
		//
		write "------END OF INIT ALG 1.3";
		write "---END OF INIT ALG";
	}

	action init_revenu {
		ask hogares {
			common_pot_inc <- sum(my_predio.cells_inside collect each.rev);
		}

	}

}

species patches {
	string type;
	predios my_predio;
	string id;
}

species sectores {
	string dpa_secdis;
	list<hogares> hogares_inside;
	list<personas> personas_inside;
	int nb_hogares;
	int nb_personas;
	rgb color <- rnd_color(255);

	action carto_pop { //A TRANSFORMER EN REFLEX POUR LES SECTORES ?
		hogares_inside <- hogares inside self;
		personas_inside <- personas inside self;
		nb_hogares <- length(hogares_inside);
		nb_personas <- length(personas_inside);
	}

	aspect default {
		draw shape color: #transparent border: #black;
	}

}

experiment Simulation type: gui {
	user_command "Save Agricultural Landscape" category: "Saving init" when: init_end = true color: #darkblue {
		save cell to: save_landscape type: "shp" attributes: ["NAME"::name,"DEF"::is_deforest, "CULT"::cult, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
	}

	user_command "Save Plots" category: "Saving init" when: init_end = true color: #darkblue {
		save predios to: save_predios type: "shp" attributes:
		["NAME"::name,"CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_RATE"::forest_rate, "DIST_VIAAUCA"::dist_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest];
	}

	user_command "Save Households" category: "Saving init" when: init_end = true color: #darkblue {
		save hogares to: save_hogares type: "shp" attributes:
		["NAME"::name,"SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOG_MEMBERS"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOID"::chef_auto_id, "MOF"::MOF, "COMMON_POT"::common_pot_inc, "LS"::livelihood_strategy];
	}

	user_command "Save People" category: "Saving init" when: init_end = true color: #darkblue {
		save personas to: save_personas type: "shp" attributes:
		["NAME"::name,"SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "HOUSEHOLD"::my_hogar, "AGE"::Age, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "vMOF"::vMOF, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef];
	}

	user_command "Save all init files" category: "Saving init" when: init_end = true color: #darkred {
		save cell to: save_landscape type: "shp" attributes: ["NAME"::name,"DEF"::is_deforest, "CULT"::cult, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
		save predios to: save_predios type: "shp" attributes:
		["NAME"::name,"CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_RATE"::forest_rate, "DIST_VIAAUCA"::dist_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest];
		save hogares to: save_hogares type: "shp" attributes:
		["NAME"::name,"SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOG_MEMBERS"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOID"::chef_auto_id, "MOF"::MOF, "COMMON_POT"::common_pot_inc, "LS"::livelihood_strategy];
		save personas to: save_personas type: "shp" attributes:
		["NAME"::name,"SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "HOUSEHOLD"::my_hogar, "AGE"::Age, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "vMOF"::vMOF, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef];
	}

	parameter "File chooser landscape" category: "Saving init" var: save_landscape;
	parameter "File chooser plots" category: "Saving init" var: save_predios;
	parameter "File chooser households" category: "Saving init" var: save_hogares;
	parameter "File chooser people" category: "Saving init" var: save_personas;
	output {
		display map_ALG type: opengl {
			grid cell;
			species predios aspect: default;
			//species sectores;
			species hogares;
			//species personas;
		}

		display map_LS type: opengl {
			grid cell;
			species predios aspect: carto_LS;
			//species sectores;
			species hogares;
			//species personas;
		}

		display map_tx_def type: opengl {
			grid cell;
			species predios aspect: carto_tx_def;
			//species sectores;
			species hogares;
			//species personas;
		}

		monitor "Total ménages" value: nb_menages;
		monitor "Total personas" value: nb_personas;
		monitor "Total parcelles" value: nb_predios;
		monitor "Total patches" value: nb_patches;
		monitor "Ratio deforest min" value: ratio_deforest_min;
		monitor "Ratio deforest max" value: ratio_deforest_max;
		monitor "Moy. ratio deforest" value: ratio_deforest_mean;
		monitor "Sup. min" value: area_min;
		monitor "Sup. max" value: area_max;
		monitor "Moy. sup." value: area_mean;
		monitor "Sup. déforest. min" value: area_deforest_min;
		monitor "Sup. déforest. max" value: area_deforest_max;
		monitor "Moy. déforest." value: area_deforest_mean;
		//-------------------------------------
		browse "suivi hogares" value: hogares attributes: ["sec_id", "hog_id", "viv_id", "Total_Personas", "Total_Hombres", "Total_Mujeres", "MOF", "my_predio", "common_pot_inc"];
		browse "suivi personas" value: personas attributes: ["sec_id", "hog_id", "viv_id", "Age", "Sexo", "vMOF", "my_hogar", "orden_en_hogar", "my_predio"];
		browse "suivi predios" value: predios attributes: ["clave_cata", "is_free", "area_total", "area_deforest", "ratio_deforest", "cells_inside"];
		//-------------------------------------
		display Ages {
			chart "Ages" type: histogram {
				loop i from: 0 to: 110 {
					data "" + i value: personas count (each.Age = i);
				}

			}

		}

		display area_def {
			chart "Ages" type: histogram {
				loop i from: 0 to: 170 {
					data "" + i value: predios count (each.area_deforest = i);
				}

			}

		}

	}

}