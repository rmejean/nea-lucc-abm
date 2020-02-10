/**
* Name: Model_INIT_DAYUMA
* Author: Romain Mejean (UT2J/UMR GEODE)
* Description: Init modèle thèse Romain
* Tags: deforestation, lucc, ecuador
*/
model Dayuma_INIT_GENSTAR

global {

//Chargement des fichiers CSV pop.
	file f_PERSONAS_predios <- file("../includes/censo/Personas_des_161_locsincom.csv");
	file f_HOGARES_predios <- file("../includes/censo/Hogares_des_161_locsincom.csv");
	//	file f_PERSONAS_comunas <- file("../includes/censo/com_personas.csv");
	//	file f_HOGARES_comunas <- file("../includes/censo/com_hogares.csv");

	//Chargement des fichiers CSV landscape
	file f_FREQ_SP1_1 <- file("../includes/LS_patchwork_frequencies/SP1_1.csv");
	file f_FREQ_SP1_2 <- file("../includes/LS_patchwork_frequencies/SP1_2.csv");
	file f_FREQ_SP1_3 <- file("../includes/LS_patchwork_frequencies/SP1_3.csv");
	file f_FREQ_SP2 <- file("../includes/LS_patchwork_frequencies/SP2.csv");
	file f_FREQ_SP3 <- file("../includes/LS_patchwork_frequencies/SP3.csv");

	//Chargement des fichiers SHP
	file buildings_shp <- file("../includes/constructions_dayuma_SIGTIERRAS.shp");
	file sectores_shp <- file("../includes/sectores_entiers.shp");
	file predios_con_def_shp <- file("../includes/predios_con_def.shp");
	//file predios_sin_def_shp <- file("../includes/predios_sin_def.shp");
	file vias_shp <- shape_file("../includes/routes_SIGTIERRAS_cut.shp");
	file comunas_shp <- file("../includes/comunas.shp");

	//Chargement du Land Cover
	file MAE_2008 <- file("../includes/MAE2008_90m.asc");

	//name of the property that contains the id of the census spatial areas in the shapefile
	string stringOfCensusIdInShapefile <- "DPA_SECDIS";
	//name of the property that contains the id of the census spatial areas in the csv file (and population)
	string stringOfCensusIdInCSVfile <- "sec_id";
	geometry shape <- envelope(MAE_2008);

	//Lists
	list<string> echelle_pop <- (list<string>(range(95)));
	list<string> echelle_ages <- (list<string>(range(105)));
	list<string> echelle_GLOBALE <- (list<string>(range(150)));
	list<string> list_id <- ([]);
	list<string> criterias <- ["def_rate", "dist_via_auca", "indigena"];
	list
	criteria_WM_SP1_1 <- [["name"::"def_rate", "weight"::SP1_1_weight_def_rate], ["name"::"dist_via_auca", "weight"::SP1_1_weight_dist_via_auca], ["name"::"indigena", "weight"::SP1_1_weight_indigena]];
	list
	criteria_WM_SP1_2 <- [["name"::"def_rate", "weight"::SP1_2_weight_def_rate], ["name"::"dist_via_auca", "weight"::SP1_2_weight_dist_via_auca], ["name"::"indigena", "weight"::SP1_2_weight_indigena]];
	list
	criteria_WM_SP1_3 <- [["name"::"def_rate", "weight"::SP1_3_weight_def_rate], ["name"::"dist_via_auca", "weight"::SP1_3_weight_dist_via_auca], ["name"::"indigena", "weight"::SP1_3_weight_indigena]];
	list
	criteria_WM_SP2 <- [["name"::"def_rate", "weight"::SP2_weight_def_rate], ["name"::"dist_via_auca", "weight"::SP2_weight_dist_via_auca], ["name"::"indigena", "weight"::SP2_weight_indigena]];
	list
	criteria_WM_SP3 <- [["name"::"def_rate", "weight"::SP3_weight_def_rate], ["name"::"dist_via_auca", "weight"::SP3_weight_dist_via_auca], ["name"::"indigena", "weight"::SP3_weight_indigena]];

	//Variables globales pour monitors
	int nb_menages -> length(hogares);
	int nb_personas -> length(personas);
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

	//----------------------------
	//Init des critères pour l'EMC
	//----------------------------
	//SP1.1
	float SP1_1_weight_def_rate <- 1.0;
	float SP1_1_weight_dist_via_auca <- 1.0;
	float SP1_1_weight_indigena <- 1.0;
	//SP1.2
	float SP1_2_weight_def_rate <- 1.0;
	float SP1_2_weight_dist_via_auca <- 1.0;
	float SP1_2_weight_indigena <- 1.0;
	//SP1.3
	float SP1_3_weight_def_rate <- 1.0;
	float SP1_3_weight_dist_via_auca <- 1.0;
	float SP1_3_weight_indigena <- 1.0;
	//SP2
	float SP2_weight_def_rate <- 1.0;
	float SP2_weight_dist_via_auca <- 1.0;
	float SP2_weight_indigena <- 1.0;
	//SP3
	float SP3_weight_def_rate <- 1.0;
	float SP3_weight_dist_via_auca <- 1.0;
	float SP3_weight_indigena <- 1.0;

	//-----------------------------------------------------------------------------------------------
	//--------------------------------------INITIALIZATION-------------------------------------------
	//-----------------------------------------------------------------------------------------------
	init {
		do init_cells;
		do init_vias;
		do init_predios;
		//do init_comunas;
		do init_pop;
		//do init_LS;
		do init_LS_EMC;
		do init_AGL;
		//do init_revenu;
	}

	action init_cells { //Init des cellules
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

	}

	action init_predios { //Init des parcelles
		create predios from: predios_con_def_shp with: [clave_cata::string(read('clave_cata'))];
		ask predios {
			if length(cells_deforest) = 0 { //supprimer les éventuelles parcelles sans déforestation... Peut-être pas à conserver !
				do die;
			}

			do calcul_tx_deforest;
			do carto_tx_deforest;
		}

	}

	action init_vias { //Init des routes
		create vias from: vias_shp with: [orden::int(get("orden"))] {
		}

	}

	action init_pop { //Init de la population
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
				my_hogar <- myself;
			}

		}

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
		// --------------------------
		// Instructions post-génération
		// --------------------------
		ask hogares {
			membres_hogar <- personas where (each.hog_id = self.hog_id);
			chef_hogar <- one_of(membres_hogar where (each.chef = true));
			chef_auto_id <- chef_hogar.auto_id;
			if chef_hogar.auto_id = "indigena" {
				ask my_predio {
					indigena <- 1;
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

	}

	action init_LS { //ESSAI (PROVISOIRE)
	//---------------------------------------------------------
	//Initialisation des LS (livelihood strategies) des ménages
	//---------------------------------------------------------
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

		}

		ask predios where (each.is_free = false) {
			do carto_LS;
		}

	}

	action init_LS_EMC { //Création des 5 agents-LS
		create LS number: 1 {
			SP <- '1.1';
			do EMC;
		}

		create LS number: 1 {
			SP <- '1.2';
			do EMC;
		}

		create LS number: 1 {
			SP <- '1.3';
			do EMC;
		}

		create LS number: 1 {
			SP <- '2';
			do EMC;
		}

		create LS number: 1 {
			SP <- '3';
			do EMC;
		}
		
//		ask predios where (each.is_free = false) {
//			do carto_LS;
//		}

	}

	action init_AGL {
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

		}

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
}

grid cell file: MAE_2008 use_regular_agents: true use_individual_shapes: false use_neighbors_cache: false {
	bool is_deforest <- true; //POURQUOI TRUE ?!
	bool is_free <- true;
	string cult;
	float rev;
	float MOF_cost;
	hogares my_hogar;
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? #darkgreen : (grid_value = 3 ? #burlywood : #red));

	action param_activities {
		if cult = 'maniocmais' {
			rev <- rnd((450 / 12), (900 / 12));
			color <- #yellow;
		}

		if cult = 'fruits' {
			rev <- rnd((1500 / 12), (2500 / 12));
			color <- #orange;
		}

		if cult = 's_livestock' {
			rev <- rnd((450 / 12), (1800 / 12));
			color <- #palevioletred;
		}

		if cult = 'plantain' {
			rev <- rnd((250 / 12), (2210 / 12));
			color <- #springgreen;
		}

		if cult = 'coffee' {
			rev <- rnd((5100 / 12), (3000 / 12));
			color <- #brown;
		}

		if cult = 'cacao' {
			rev <- rnd((1100 / 12), (900 / 12));
			color <- #red;
		}

		if cult = 'livestock' {
			rev <- rnd((1240 / 12), (1010 / 12));
			color <- #purple;
		}

		if cult = 'friche' {
			rev <- 0.0;
			color <- #white;
		}

		if cult = 'house' {
			rev <- 0.0;
			color <- #red;
		}

	}

}

species predios {
	string clave_cata;
	bool is_free <- true;
	bool is_free_EMC <- true;
	int area_total <- length(cells_inside);
	int area_deforest <- cells_inside count each.is_deforest;
	float def_rate; //Taux de déforestation
	float dist_via_auca <- distance_to(self, vias where (each.orden = 1) closest_to self); //Distance à la Via Auca
	int indigena;//Indice ethnie
	string LS;//Livelihood strategy
	rgb color;
	rgb color_tx_def;
	rgb LS_color;
	hogares my_hogar;
	list<cell> cells_inside -> {cell overlapping self}; //ancienne version : il y avait overlapping
	list<cell> cells_deforest -> cells_inside where (each.grid_value = 3);

	action calcul_tx_deforest {
		if area_total > 0 {
			def_rate <- (area_deforest / area_total);
		} else {
			def_rate <- 0.0;
		}

	}

	action carto_tx_deforest {
		color_tx_def <- def_rate = 0 ? #white : (between(def_rate, 0.1, 0.25) ? rgb(253, 204, 138) : (between(def_rate, 0.25, 0.50) ?
		rgb(253, 204, 138) : (between(def_rate, 0.50, 0.75) ? rgb(252, 141, 89) : rgb(215, 48, 31))));
	}

	action carto_LS {
		LS_color <- my_hogar.livelihood_strategy = 'SP3' ? #lightseagreen : (my_hogar.livelihood_strategy = 'SP2' ? #paleturquoise : (my_hogar.livelihood_strategy = 'SP1.1' ?
		#greenyellow : (my_hogar.livelihood_strategy = 'SP1.2' ? #tan : #rosybrown)));
	}

	aspect default {
		draw shape border: #black;
	}

	aspect carto_tx_def {
		draw shape color: color_tx_def border: #black;
	}

	aspect carto_LS {
		draw shape color: LS_color border: #black;
	}

}

species vias {
	int orden;

	aspect default {
		draw shape color: #black border: #black;
	}

}

species comunas {
	int area_total;
	int area_deforest;
	float ratio_deforest;

	aspect default {
		draw shape color: #black border: #black;
	}

}

species LS {
	string SP;

	action EMC { //EVALUATION MULTI CRITERES
		if SP = '1.1' {
			int choice <- weighted_means_DM(predios where (each.is_free_EMC = true), criteria_WM_SP1_1);
			if choice >= 0 {
				ask predios at choice {
					is_free_EMC <- false;
					self.LS <- 'SP1.1';
				}

			}

		}

		if SP = '1.2' {
			int choice <- weighted_means_DM(predios where (each.is_free_EMC = true), criteria_WM_SP1_2);
			if choice >= 0 {
				ask predios at choice {
					is_free_EMC <- false;
					self.LS <- 'SP1.2';
				}

			}

		}

		if SP = '1.3' {
			int choice <- weighted_means_DM(predios where (each.is_free_EMC = true), criteria_WM_SP1_3);
			if choice >= 0 {
				ask predios at choice {
					is_free_EMC <- false;
					self.LS <- 'SP1.3';
				}

			}

		}

		if SP = '2' {
			int choice <- weighted_means_DM(predios where (each.is_free_EMC = true), criteria_WM_SP2);
			if choice >= 0 {
				ask predios at choice {
					is_free_EMC <- false;
					self.LS <- 'SP2';
				}

			}

		}

		if SP = '3' {
			int choice <- weighted_means_DM(predios where (each.is_free_EMC = true), criteria_WM_SP3);
			if choice >= 0 {
				ask predios at choice {
					is_free_EMC <- false;
					self.LS <- 'SP3';
				}

			}

		}

	}

}

species hogares {
	string sec_id;
	string hog_id;
	string viv_id;
	int Total_Personas;
	int Total_Hombres;
	int Total_Mujeres;
	predios my_predio;
	list<personas> membres_hogar;
	personas chef_hogar;
	string chef_auto_id;
	float MOF;
	float common_pot_inc;
	string livelihood_strategy;

	action MOF_calc {
		MOF <- (sum(membres_hogar collect each.vMOF) * 30);
	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}

species personas parent: hogares {
	hogares my_hogar;
	int Age;
	string Sexo;
	int orden_en_hogar;
	float vMOF;
	float inc;
	string auto_id;
	bool chef;

	action vMOF_calc {
		if Age < 11 {
			vMOF <- 0.0;
		}

		if Age = 11 {
			vMOF <- 0.16;
		}

		if Age = 12 {
			vMOF <- 0.33;
		}

		if Age = 13 {
			vMOF <- 0.5;
		}

		if Age = 14 {
			vMOF <- 0.66;
		}

		if Age = 15 {
			vMOF <- 0.83;
		}

		if Age >= 16 {
			vMOF <- 1.0;
		}

	}

	aspect default {
		draw circle(6) color: #blue border: #black;
	}

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
	output {
		display map type: opengl {
			grid cell;
			//species predios aspect: default;
			//species sectores;
			species hogares;
			//species personas;
		}

		monitor "Total ménages" value: nb_menages;
		monitor "Total personas" value: nb_personas;
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
		browse "suivi hogares" value: hogares attributes:
		["sec_id", "hog_id", "viv_id", "Total_Personas", "Total_Hombres", "Total_Mujeres", "MOF", "my_predio", "common_pot_inc", "chef_auto_id"];
		browse "suivi personas" value: personas attributes: ["sec_id", "hog_id", "viv_id", "Age", "Sexo", "vMOF", "my_hogar", "orden_en_hogar", "my_predio"];
		browse "pop par secteur" value: sectores attributes: ["DPA_SECDIS", "nb_hogares", "nb_personas"];
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