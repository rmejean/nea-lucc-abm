/**
* Name: Model_INIT_DAYUMA
* Author: Romain Mejean (UT2J/UMR GEODE)
* Description: Init modèle thèse Romain
* Tags: deforestation, lucc, ecuador
*/
model Dayuma_INIT_GENSTAR

global {

//Chargement des fichiers CSV
	file f_PERSONAS_predios <- file("../includes/censo/Personas_des_161_locsincom.csv");
	file f_HOGARES_predios <- file("../includes/censo/Hogares_des_161_locsincom.csv");
	//	file f_PERSONAS_comunas <- file("../includes/censo/com_personas.csv");
	//	file f_HOGARES_comunas <- file("../includes/censo/com_hogares.csv");

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
	list<string> echelle_pop <- (list<string>(range(95)));
	list<string> echelle_ages <- (list<string>(range(105)));
	list<string> echelle_GLOBALE <- (list<string>(range(150)));
	list<string> list_id <- ([]);

	//Variables globales pour monitors
	int nb_menages -> length(hogares);
	int nb_personas -> length(personas);
	float ratio_deforest_min -> predios min_of (each.ratio_deforest);
	float ratio_deforest_max -> predios max_of (each.ratio_deforest);
	float ratio_deforest_mean -> predios mean_of (each.ratio_deforest);
	int area_min -> predios min_of (each.area_total);
	int area_max -> predios max_of (each.area_total);
	float area_mean -> predios mean_of (each.area_total);
	int area_deforest_min -> predios min_of (each.area_deforest);
	int area_deforest_max -> predios max_of (each.area_deforest);
	float area_deforest_mean -> predios mean_of (each.area_deforest);

	//-----------------------------------------------------------------------------------------------
	init {
		do init_cells;
		do init_predios;
		//do init_comunas;
		do init_vias;
		do init_pop;
		do init_LS;
		//do init_cult;
		do init_revenu;
	}

	action init_cells {
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

	action init_predios {
		create predios from: predios_con_def_shp with: [clave_cata::string(read('clave_cata'))] {
			is_free <- true;
		}

		ask predios {
			do calcul_tx_deforest;
			do carto_tx_deforest;
		}

	}

	action init_vias {
		create vias from: vias_shp with: [orden::int(get("orden"))] {
		}

	}

	action init_pop {
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
			my_predio <- one_of(predios overlapping self);
			location <- one_of(my_predio.cells_deforest).location; //A VERIFIER
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
			do MOF_calc;
			ask my_predio.cells_inside {
				my_hogar <- myself;
			}

		}

		ask sectores {
			do carto_pop;
		}

	}

	//---------------------------------------------------------
	//Initialisation des LS (livelihood strategies) des ménages
	//---------------------------------------------------------
	action init_LS {
		ask hogares {
		//SP3 : basé sur la taille des parcelles (pâturages)
			if my_predio.area_deforest > 50 {
				float proba <- rnd(100.0);
				if proba < 66.666 {
					livelihood_strategy <- 'SP3';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP2';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP1.1';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.2';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
				}

			}
			//SP2 : basé sur la taille des parcelles (pâturages)
			if my_predio.area_deforest between (10, 50) {
				float proba <- rnd(100.0);
				if proba < 66.666 {
					livelihood_strategy <- 'SP2';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP3';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP1.1';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.2';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
				}

			}
			//SP1.1 : basé sur l'éloignement à la route principale (via Auca, indigènes et comunas)
			if distance_to(my_predio, vias where (each.orden = 1) closest_to self) > 4 #km {
				float proba <- rnd(100.0);
				if proba < 66.666 {
					livelihood_strategy <- 'SP1.1';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP3';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP2';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.2';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
				}

			}
			//SP1.2 : basé sur la proximité aux routes secondaires
			if distance_to(my_predio, vias where (each.orden = 2) closest_to self) < distance_to(my_predio, vias where (each.orden = 1) closest_to self) {
				float proba <- rnd(100.0);
				if proba < 66.666 {
					livelihood_strategy <- 'SP1.2';
				}

				if proba between (66.666, 74.916) {
					livelihood_strategy <- 'SP3';
				}

				if proba between (74.916, 83.166) {
					livelihood_strategy <- 'SP2';
				}

				if proba between (83.166, 91.416) {
					livelihood_strategy <- 'SP1.1';
				}

				if proba between (91.416, 100.00) {
					livelihood_strategy <- 'SP1.3';
				}

			}

		}

		ask predios where (each.is_free = false) {
			do carto_LS;
		}

	}
	//---------------------------------------------------------
	//Initialisation des cultures selon la LS des ménages
	//---------------------------------------------------------
	action init_cult {
		ask hogares {
			ask first(cell overlapping self) {
				cult <- 'house';
			}

			if livelihood_strategy = 'SP3' {
				ask my_predio.cells_deforest {
					
				}

			}

			if livelihood_strategy = 'SP2' {
			}

			if livelihood_strategy = 'SP1.1' {
			}

			if livelihood_strategy = 'SP1.2' {
			}

			if livelihood_strategy = 'SP1.3' {
			}

			//		if flip(0.6666) = true {
			//			cult <- 'v_maniocmais';
			//			do cult_parameters;
			//		} else {
			//			if flip(0.6666) = true {
			//				cult <- 'v_maraichage';
			//				do cult_parameters;
			//			} else {
			//				if flip(0.3333) = true {
			//					cult <- 'v_petit-elevage';
			//					do cult_parameters;
			//				} else {
			//					if flip(0.15) = true {
			//						cult <- 'v_plantain';
			//						do cult_parameters;
			//					}
			//
			//				}
			//
			//			}
			//
			//		}

		}

	}

	action init_revenu {
		ask hogares {
			common_pot_inc <- sum(my_predio.cells_inside collect each.rev);
		}

	}

}

grid cell file: MAE_2008 use_regular_agents: false use_individual_shapes: false use_neighbors_cache: false {
	bool is_deforest;
	string cult;
	float rev;
	float MOF_cost;
	hogares my_hogar;
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? #darkgreen : (grid_value = 3 ? #burlywood : #red));
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

	action color_cult {
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
	bool is_free;
	int area_total <- length(cells_inside);
	int area_deforest <- cells_inside count each.is_deforest;
	float ratio_deforest;
	rgb color;
	rgb color_tx_def;
	rgb LS_color;
	hogares my_hogar;
	list<cell> cells_inside -> {cell overlapping self}; //trouver mieux que overlapping ? il faut vérifier si pas de doubles comptes!
	list<cell> cells_deforest -> cells_inside where (each.grid_value = 3);

	action calcul_tx_deforest {
		if area_total > 0 {
			ratio_deforest <- (area_deforest / area_total);
		} else {
			ratio_deforest <- 0.0;
		}

	}

	action carto_tx_deforest {
		color_tx_def <- ratio_deforest = 0 ? #white : (between(ratio_deforest, 0.1, 0.25) ? rgb(253, 204, 138) : (between(ratio_deforest, 0.25, 0.50) ?
		rgb(253, 204, 138) : (between(ratio_deforest, 0.50, 0.75) ? rgb(252, 141, 89) : rgb(215, 48, 31))));
	}

	action carto_LS {
		LS_color <- my_hogar.livelihood_strategy = 'SP3' ? #lightseagreen : (my_hogar.livelihood_strategy = 'SP2' ? #paleturquoise : (my_hogar.livelihood_strategy = 'SP1.1' ?
		#greenyellow : (my_hogar.livelihood_strategy = 'SP1.2' ? #tan : #rosybrown)));
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
			species predios aspect: carto_LS;
			//species sectores;
			species hogares;
			species personas;
		}

		monitor "Total ménages" value: nb_menages;
		monitor "Total personas" value: nb_personas;
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