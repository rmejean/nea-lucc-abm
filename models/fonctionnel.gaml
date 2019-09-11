/**
* Name: Model_INIT_DAYUMA
* Author: Romain Mejean
* Description: Modèle thèse Romain
* Tags: Tag1, Tag2, TagN
*/

model Dayuma_INIT_GENSTAR

global {
	
	//Chargement des fichiers CSV
	file f_AS <- file("../includes/age_et_sexe.csv");
	file f_SECTORES <- file("../includes/dayuma_sectores.csv");
	
	//Chargement des fichiers SHP
	file buildings_shp <- file("../includes/constructions_dayuma_SIGTIERRAS.shp");
	file sectores_shp <- file("../includes/sectores_dayuma_INEC.shp");
	
	//Chargement du Land Cover
	file MAE_2008 <- file ("../includes/MAE2008_90m.asc");
	
	//name of the property that contains the id of the census spatial areas in the shapefile
	string stringOfCensusIdInShapefile <- "DPA_SECDIS";

	//name of the property that contains the id of the census spatial areas in the csv file (and population)
	string stringOfCensusIdInCSVfile <- "sec_id";

	geometry shape <- envelope(buildings_shp);

	list<string> tranches_age <- ["Menor de 1 año", "De 1 a 4 años", "De 5 a 9 años", "De 10 a 14 años", "De 15 a 19 años", 
									"De 20 a 24 años", "De 25 a 29 años", "De 30 a 34 años", "De 35 a 39 años", "De 40 a 44 años",
									"De 45 a 49 años", "De 50 a 54 años", "De 55 a 59 años", "De 60 a 64 años", "De 65 a 69 años",
									"De 70 a 74 años", "De 75 a 79 años", "De 80 a 84 años", "De 85 a 89 años", "De 90 a 94 años",
									"De 95 a 99 años", "De 100 años y mas"];
	
	init {		
		create sectores from: sectores_shp with: [dpa_secdis::string(read('DPA_SECDIS'))];			
		
		gen_population_generator pop_gen;
		pop_gen <- pop_gen with_generation_algo "IS";

		pop_gen <- add_census_file(pop_gen, f_AS.path, "ContingencyTable", ";", 1, 1);
		pop_gen <- add_census_file(pop_gen, f_SECTORES.path, "ContingencyTable", ",", 1, 1);					

		// --------------------------
		// Setup "AGE" attribute: INDIVIDUAL
		// --------------------------	

		pop_gen <- pop_gen add_attribute("Age", gen_range, tranches_age);
				
		// -------------------------
		// Setup "SEXE" attribute: INDIVIDUAL
		// -------------------------
		
		pop_gen <- pop_gen add_attribute("Sexe", string, ["Hombre", "Mujer"]);


		// -------------------------
		// Setup "SECTORES" attribute: INDIVIDUAL
		// -------------------------

		list<string> liste_sec <- ["220151999001", "220151999004", "220151999002", "220151999005", "220151999014", "220151999015", "220151999013",
		"220151999016", "220151999012", "220151999011", "220151999009", "220151999018", "220151999006", "220151999007", "220151999008", "220151999017",
		"220151999010", "220151999003", "220153999002", "220153999003", "220153999001", "220156999002", "220152999001", "220152999004", "220152999005",
		"220152999003", "220154999004", "220154999005", "220157999001", "220157999004", "220157999007", "220157999005", "220157999003", "220157999002",
		"220158999004", "220158999002", "220158999003", "220158999006", "220158999007", "220158999008", "220158999009", "220158999010", "220158999011",
		"220158999013", "220158999014", "220158999015", "220158999005", "220158999012", "220252999001", "150153999017", "150153999016", "220152999002"];
		
		pop_gen <- pop_gen add_attribute("sec_id", string, liste_sec, "pop10", int);


		// -------------------------
		// Spatialization 
		// -------------------------
		
		pop_gen <- pop_gen localize_on_census(sectores_shp.path);
		pop_gen <- pop_gen add_spatial_mapper(stringOfCensusIdInCSVfile,stringOfCensusIdInShapefile);
		//Spatialisation sur les fincas
		pop_gen <- pop_gen localize_on_geometries(buildings_shp.path);
		

		// -------------------------			
		create people from: pop_gen number: 10263;
	}
}

species fincas {
	
	aspect default {
		draw shape color:#lightgrey  border: #black;
	}
}

species people {
	int Age;
	string Sexe;
	string sec_id;

	aspect default { 
		draw circle(4) color: #red border: #black;
	}
}

species sectores {
	string dpa_secdis;
	rgb color <- rnd_color(255);
	aspect default {
		draw shape color:color  border: #black;
	}
}

grid classif08 file: MAE_2008{
	init {
		color <- grid_value = 1.0 ? #blue  : (grid_value = 2.0  ? #darkgreen :   (grid_value = 3.0 ? #brown : #red ));
	}
}


experiment DayumaTemplate type: gui {
	output {
		display map  type: opengl {
			grid classif08;
			species fincas;
			//species sectores;
			species people;
		}
		
//		display Ages {
//			chart "Ages" type: histogram {
//				loop i from: 0 to: 110 {
//					data ""+i value: people count(each.Age = i);
//				}
//			}
//		}
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
	
