/**
* Name: Model_INIT_DAYUMA
* Author: Romain Mejean (UT2J/UMR GEODE)
* Description: Init modèle thèse Romain
* Tags: deforestation, lucc, ecuador
*/
model Dayuma_INIT_GENSTAR

global {

//Chargement des fichiers CSV
	file f_PERSONAS_predios <- file("../includes/censo/personas_sin_com-urb.csv");
	file f_HOGARES_predios <- file("../includes/censo/hogares_sin_com-urb.csv");
	file f_VIVIENDAS_predios <- file("../includes/censo/viviendas_sin_com-urb_oc.csv");
	file f_PERSONAS_comunas <- file("../includes/censo/com_personas.csv");
	file f_HOGARES_comunas <- file("../includes/censo/com_hogares.csv");
	file f_VIVIENDAS_comunas <- file("../includes/censo/com_viviendas.csv");

	//Chargement des fichiers SHP
	file buildings_shp <- file("../includes/constructions_dayuma_SIGTIERRAS.shp");
	file sectores_shp <- file("../includes/sectores_entiers.shp");
	file predios_con_def_shp <- file("../includes/predios_con_def.shp");
	//file predios_sin_def_shp <- file("../includes/predios_sin_def.shp");
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
	int nb_viviendas -> length(viviendas);
	//int nb_viviendas_free -> length(viviendas where each.is_free);
	float ratio_deforest_min -> predios min_of (each.ratio_deforest);
	float ratio_deforest_max -> predios max_of (each.ratio_deforest);
	float ratio_deforest_mean -> predios mean_of (each.ratio_deforest);
	int area_min -> predios min_of (each.area_total);
	int area_max -> predios max_of (each.area_total);
	float area_mean -> predios mean_of (each.area_total);
	int area_deforest_min -> predios min_of (each.area_deforest);
	int area_deforest_max -> predios max_of (each.area_deforest);
	float area_deforest_mean -> predios mean_of (each.area_deforest);
	//int nb_personnes150153999016 -> length(hogares where (each.sec_id = "150153999016"));

	//	//Palettes
	//	list<string> palette <- brewer_palettes(5);
	//	string sequentialPalette <- "YlOrRd";
	//	list<rgb> SequentialColors <- brewer_colors(sequentialPalette);

	//-----------------------------------------------------------------------------------------------
	init {
		do init_cells;	
		do init_predios;
		do init_viviendas;
		do init_predios;
		do init_viviendas;
		//do init_comunas;
		do init_pop;
		do init_cult;
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
		create predios from: predios_con_def_shp {
			is_free <- true;
		}

		ask predios {
			do calcul_tx_deforest;
			do carto_tx_deforest;
		}

	}

	action init_viviendas {
		create sectores from: sectores_shp with: [dpa_secdis::string(read('DPA_SECDIS'))];
		gen_population_generator viv_gen;
		viv_gen <- viv_gen with_generation_algo "US";
		viv_gen <- add_census_file(viv_gen, f_VIVIENDAS_predios.path, "Sample", ",", 1, 1);
		// --------------------------
		// Setup Attributs
		// --------------------------	
		viv_gen <- viv_gen add_attribute ("sec_id", string, list_id);
		viv_gen <- viv_gen add_attribute ("hog_id", string, list_id);
		viv_gen <- viv_gen add_attribute ("viv_id", string, list_id);
		viv_gen <- viv_gen add_attribute ("Total_Personas", int, echelle_GLOBALE);
		viv_gen <- viv_gen add_attribute ("nro_hogares", int, ["0", "1", "2"]);
		// -------------------------
		// Spatialization 
		// -------------------------
		//		viv_gen <- viv_gen localize_on_geometries (predios_con_def_shp.path);
		//		viv_gen <- viv_gen add_capacity_distribution (1,1);
		//		viv_gen <- viv_gen localize_on_census (sectores_shp.path);
		//		viv_gen <- viv_gen add_spatial_mapper (stringOfCensusIdInCSVfile, stringOfCensusIdInShapefile);
		//
		create viviendas from: viv_gen {
			if one_matches(predios, each.is_free = true) {
				my_predio <- (shuffle(predios) first_with (each.is_free = true));
				location <- my_predio.location;
				ask my_predio {
					is_free <- false;
				}

			}

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
		create hogares from: hog_gen {
			my_vivienda <- first(viviendas where (each.viv_id = self.viv_id));
			if my_vivienda != nil {
				location <- my_vivienda.location;
				my_predio <- my_vivienda.my_predio;
			} else {
				do die;
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
		// --------------------------
		create personas from: pop_gen {
			my_hogar <- first(hogares where (each.hog_id = self.hog_id));
			if my_hogar != nil {
				location <- my_hogar.location;
				my_predio <- my_hogar.my_predio;
				do vMOF_calc;
			} else {
				do die;
			}

		}
		// --------------------------
		ask hogares {
			membres_hogar <- personas where (each.hog_id = self.hog_id);
			MOF <- sum(membres_hogar collect each.vMOF);
		}

		ask sectores {
			do carto_pop;
		}

	}

	action init_cult {
		ask predios where (each.is_free = false) {
			ask cells_inside where (each.grid_value = 3) {
				do cult_attribution;
			}

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
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? #darkgreen : (grid_value = 3 ? #burlywood : #red));

	action cult_attribution {
		if flip(0.6666) = true {
			cult <- 'v_maniocmais';
			rev <- rnd ((450/12),(900/12));
			color <- #yellow;
		}
		else {
			if flip(0.6666) = true {
				cult <- 'v_maraichage';
				rev <- rnd ((1500/12),(2500/12));
				color <- #purple;
			}
			else {
				if flip (0.3333) = true {
					cult <- 'v_petit-elevage';
					rev <- rnd ((450/12),(1800/12));
					color <- #palevioletred;
				}
				else {
					if flip (0.15) = true {
						cult <- 'v_plantain';
						rev <- rnd ((250/12),(2210/12));
						color <- #springgreen;
					}
				}
			}
		}

	}

}

species predios {
	bool is_free;
	int area_total <- length(cells_inside);
	int area_deforest <- cells_inside count each.is_deforest;
	float ratio_deforest;
	rgb color;
	list<cell> cells_inside -> {cell overlapping self}; //trouver mieux que overlapping ? il faut vérifier si pas de doubles comptes!
	action calcul_tx_deforest {
		if area_total > 0 {
			ratio_deforest <- (area_deforest / area_total);
		} else {
			ratio_deforest <- 0.0;
		}

	}

	action carto_tx_deforest {
		color <- ratio_deforest = 0 ? #white : (between(ratio_deforest, 0.1, 0.25) ? rgb(253, 204, 138) : (between(ratio_deforest, 0.25, 0.50) ?
		rgb(253, 204, 138) : (between(ratio_deforest, 0.50, 0.75) ? rgb(252, 141, 89) : rgb(215, 48, 31))));
	}

	aspect default {
		draw shape color: #transparent border: #black;
	}
	
	aspect carto {
		draw shape color: color border: #black;
	}

}

species viviendas {
	string sec_id;
	string hog_id;
	string viv_id;
	sectores my_sector;
	hogares my_hogar;
	predios my_predio;
	int Total_Personas;
	int nro_hogares;

	aspect default {
		draw circle(20) color: #black border: #black;
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
	viviendas my_vivienda;
	predios my_predio;
	list<personas> membres_hogar;
	float MOF;
	float common_pot_inc;

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
			species predios aspect: default;
			species viviendas;
			//species sectores;
			species hogares;
			species personas;
		}

		monitor "Total ménages" value: nb_menages;
		monitor "Total personas" value: nb_personas;
		monitor "Total viviendas" value: nb_viviendas;
		//monitor "Total viviendas libres" value: nb_viviendas_free;
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
		browse "suivi viviendas" value: viviendas attributes: ["sec_id", "hog_id", "viv_id", "Total_Personas", "nro_hogares", "my_predio"];
		browse "suivi hogares" value: hogares attributes: ["sec_id", "hog_id", "viv_id", "Total_Personas", "Total_Hombres", "Total_Mujeres", "MOF", "my_predio", "common_pot_inc"];
		browse "suivi personas" value: personas attributes: ["sec_id", "hog_id", "viv_id", "Age", "Sexo", "vMOF", "my_hogar", "orden_en_hogar", "my_predio"];
		browse "pop par secteur" value: sectores attributes: ["DPA_SECDIS", "nb_hogares", "nb_personas"];
		//-------------------------------------
		display Ages {
			chart "Ages" type: histogram {
				loop i from: 0 to: 110 {
					data "" + i value: personas count (each.Age = i);
				}

			}

		}
		//		
		//		display Sex {
		//			chart "sex" type: pie {
		//				loop se over: ["Hombre", "Mujer"] {
		//					data se value: people count(each.Sexe = se);
		//				}
		//			}
		//		}
		//		
		//			display Ages2 {
		//			chart "Ages2" type: histogram {
		//				loop i from: 0 to: 110 {
		//					data ""+i value: people where (each.sec_id = "220158999006") count(each.Age = i);
		//				}
		//			}
		//		}

		//				display Sex2 {
		//			chart "sexe par secteur" type: pie {
		//				loop se2 over: ["Hombre", "Mujer"] {
		//					data se2 value: people with:[sec_id = "220153999001"] count(each.Sexe = se2);
		//				}
		//			}
		//		}
	}

}