/**
* Name: Model_INIT_DAYUMA
* Author: Romain Mejean (UT2J/UMR GEODE)
* Description: Init modèle thèse Romain
* Tags: deforestation, lucc, ecuador
*/
model Dayuma_INIT_GENSTAR

global {

    //Chargement des fichiers CSV
	file f_detail_HOGARES <- file("../includes/censo/fichier_detail_hogares_dayuma_ELAG.csv");
	file f_detail_PERSONAS <- file("../includes/censo/fichier_detail_dayuma_ELAG.csv");
	//file f_detail_PERSONAS_m <- file("../includes/censo/fichier_detail_personasM_dayuma_ELAG.csv");

	//Chargement des fichiers SHP
	file buildings_shp <- file("../includes/constructions_dayuma_SIGTIERRAS.shp");
	file sectores_shp <- file("../includes/sectores_dayuma_INEC.shp");
	file predios_shp <- file("../includes/predios_dayuma_SIGTIERRAS.shp");

	//Chargement du Land Cover
	file MAE_2008 <- file("../includes/MAE2008_90m.tif");

	//name of the property that contains the id of the census spatial areas in the shapefile
	string stringOfCensusIdInShapefile <- "DPA_SECDIS";

	//name of the property that contains the id of the census spatial areas in the csv file (and population)
	string stringOfCensusIdInCSVfile <- "sec_id";
	
	geometry shape <- envelope(MAE_2008);
	list<string> echelle_pop <- (list<string>(range (95)));
	list<string> echelle_ages <- (list<string>(range (105)));
	list<string> list_sectores <- (["220151999001", "220151999004", "220151999002", "220151999005", "220151999014", "220151999015", "220151999013", "220151999016", "220151999012", "220151999011", "220151999009", "220151999018", "220151999006", "220151999007", "220151999008", "220151999017", "220151999010", "220151999003", "220153999002", "220153999003", "220153999001", "220156999002", "220152999001", "220152999004", "220152999005", "220152999003", "220154999004", "220154999005", "220157999001", "220157999004", "220157999007", "220157999005", "220157999003", "220157999002", "220158999004", "220158999002", "220158999003", "220158999006", "220158999007", "220158999008", "220158999009", "220158999010", "220158999011", "220158999013", "220158999014", "220158999015", "220158999005", "220158999012", "220252999001", "150153999017", "150153999016", "220152999002"]);
    list<string> list_hogares <- ([]);

	//Variables globales pour monitors
	int nb_menages -> length(hogares);
	int nb_personas -> length(people);
	//int nb_hommes -> people count (each.Sexo = "Hombre");
	//int nb_femmes -> people count (each.Sexo = "Mujer");
	float ratio_deforest_min -> fincas min_of (each.ratio_deforest);
	float ratio_deforest_max -> fincas max_of (each.ratio_deforest);
	float ratio_deforest_mean -> fincas mean_of (each.ratio_deforest);
	int area_min -> fincas min_of (each.area_total);
	int area_max -> fincas max_of (each.area_total);
	float area_mean -> fincas mean_of (each.area_total);
	int area_deforest_min -> fincas min_of (each.area_deforest);
	int area_deforest_max -> fincas max_of (each.area_deforest);
	float area_deforest_mean -> fincas mean_of (each.area_deforest);
	//int nb_personnes150153999016 -> length(hogares where (each.sec_id = "150153999016"));

	//	//Palettes
	//	list<string> palette <- brewer_palettes(5);
	//	string sequentialPalette <- "YlOrRd";
	//	list<rgb> SequentialColors <- brewer_colors(sequentialPalette);

	//-----------------------------------------------------------------------------------------------
	init {
		do init_cells;
		do init_pop;
		do init_fincas;
	}

	action init_cells {
		ask cell {
			if grid_value = 0.0 {
				do die;
			}

			color <- grid_value = 1 ? #blue : (grid_value = 2 ? #darkgreen : (grid_value = 3 ? #yellow : #red));
			if grid_value >= 3 {
				is_deforest <- true;
			} else {
				is_deforest <- false;
			}

		}

	}

	action init_pop {
		create sectores from: sectores_shp with: [dpa_secdis::string(read('DPA_SECDIS'))];
		
		gen_population_generator hog_gen;
		hog_gen <- hog_gen with_generation_algo "simple_draw";
		hog_gen <- add_census_file(hog_gen, f_detail_HOGARES.path, "Sample", ",", 1, 1);

		// --------------------------
		// Setup Attributs
		// --------------------------	
		hog_gen <- hog_gen add_attribute ("Total_Personas", int, echelle_pop);
		hog_gen <- hog_gen add_attribute ("Total_Hombres", int, echelle_pop);
		hog_gen <- hog_gen add_attribute ("Total_Mujeres", int, echelle_pop);
		hog_gen <- hog_gen add_attribute ("sec_id", string, list_sectores);
		hog_gen <- hog_gen add_attribute ("hog_id", string, list_hogares);

		// -------------------------
		// Spatialization 
		// -------------------------
		hog_gen <- hog_gen localize_on_census (sectores_shp.path);
		hog_gen <- hog_gen add_spatial_mapper (stringOfCensusIdInCSVfile, stringOfCensusIdInShapefile);

		//Spatialisation sur les fincas
		hog_gen <- hog_gen localize_on_geometries (buildings_shp.path); //à désactiver pour avoir un nombre plus proche de la réalité : parfois, il n'y a pas de constructions dans un secteur "peuplé", donc pas d'agents dedans...


		// -------------------------			
		create hogares from: hog_gen;
			
		gen_population_generator pop_gen;
		pop_gen <- pop_gen with_generation_algo "simple_draw";
		pop_gen <- add_census_file(pop_gen, f_detail_PERSONAS.path, "Sample", ",", 1, 1);

		// --------------------------
		// Setup Attributs
		// --------------------------	
		pop_gen <- pop_gen add_attribute ("Sexo", string, ["Hombre", "Mujer"]);
		pop_gen <- pop_gen add_attribute ("Age", int, echelle_ages);
		pop_gen <- pop_gen add_attribute ("hog_id", string, list_hogares);
			
		create people from: pop_gen number: 10173;
		
		ask people {
			my_hogar <- one_of (hogares where (each.hog_id = self.hog_id));
			location <- my_hogar.location ;
		}
			
		
		

	}

	action init_fincas {
		create fincas from: predios_shp with: [tipo::string(read('tipo')), finca_id::string(read('finca_id'))];
		ask fincas {
			do calcul_deforest;
			do carto_tx_deforest;
		}

	}

}

grid cell file: MAE_2008 use_regular_agents: false use_individual_shapes: false use_neighbors_cache: false {
	bool is_deforest;
}

species fincas {
	string tipo;
	string finca_id;
	int area_total;
	int area_deforest;
	float ratio_deforest;
	rgb color;
	list<cell> cells_inside -> {cell overlapping self}; //mieux que inside ? il faut vérifier si pas de doubles comptes
	action calcul_deforest {
		area_total <- length(cells_inside);
		area_deforest <- cells_inside count each.is_deforest;
		if area_total > 0 {
			ratio_deforest <- (area_deforest / area_total);
		} else {
			ratio_deforest <- 0.0;
		}

	}

	action carto_tx_deforest {
		if tipo = "parcelle" { //exclure les comunas pour l'instant
			color <- ratio_deforest = 0 ? #white : (between(ratio_deforest, 0.1, 0.25) ? rgb(253, 204, 138) : (between(ratio_deforest, 0.25, 0.50) ?
			rgb(253, 204, 138) : (between(ratio_deforest, 0.50, 0.75) ? rgb(252, 141, 89) : rgb(215, 48, 31))));
		} else {
			color <- #black;
		}

	}

	aspect default {
		draw shape color: color border: #black;
	}

}

species hogares {
	int Total_Personas;
	int Total_Hombres;
	int Total_Mujeres;
	string sec_id;
	string hog_id;

	aspect default {
		draw circle(4) color: #red border: #black;
	}

}

species people parent: hogares {
	int Age;
	string Sexo;
	string hog_id;
	agent my_hogar;

	aspect default {
		draw circle(4) color: #red border: #black;
	}

}

species sectores {
	string dpa_secdis;
	rgb color <- rnd_color(255);

	aspect default {
		draw shape color: #transparent border: #black;
	}

}

experiment Simulation type: gui {
	output {
		display map type: opengl {
			grid cell;
			//species fincas;
			//species sectores;
			species hogares;
		}

		monitor "Total ménages" value: nb_menages;
		monitor "Total personas" value: nb_personas;
		//monitor "Total hommes" value: nb_hommes;
		//monitor "Total femmes" value: nb_femmes;
		//monitor "Pop secteur 150153999016" value: nb_personnes150153999016; //pour contrôle données
		monitor "Ratio deforest min" value: ratio_deforest_min;
		monitor "Ratio deforest max" value: ratio_deforest_max;
		monitor "Moy. ratio deforest" value: ratio_deforest_mean;
		monitor "Sup. min" value: area_min;
		monitor "Sup. max" value: area_max;
		monitor "Moy. sup." value: area_mean;
		monitor "Sup. déforest. min" value: area_deforest_min;
		monitor "Sup. déforest. max" value: area_deforest_max;
		monitor "Moy. déforest." value: area_deforest_mean;
		browse "suivi ménages" value: hogares attributes: ["Total_Personas", "Total_Hombres", "Total_Mujeres", "sec_id", "hog_id"];
		browse "suivi pop" value: people attributes: ["Age", "Sexo", "my_hogar", "hog_id"];

				display Ages {
					chart "Ages" type: histogram {
						loop i from: 0 to: 110 {
							data ""+i value: people count(each.Age = i);
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