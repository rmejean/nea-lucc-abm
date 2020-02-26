/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model simulations

import "model_core.gaml"

global { //Global variables for monitors
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
}

experiment Simulation type: gui {
	user_command "Save Agricultural Landscape" category: "Saving init" when: init_end = true color: #darkblue {
		save cell to: save_landscape type: "shp" attributes: ["NAME"::name, "DEF"::is_deforest, "CULT"::cult, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
	}

	user_command "Save Plots" category: "Saving init" when: init_end = true color: #darkblue {
		save predios to: save_predios type: "shp" attributes:
		["NAME"::name, "CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_RATE"::forest_rate, "DIST_VIAAUCA"::dist_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest];
	}

	user_command "Save Households" category: "Saving init" when: init_end = true color: #darkblue {
		save hogares to: save_hogares type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOG_MEMBERS"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOID"::chef_auto_id, "MOF"::MOF, "COMMON_POT"::common_pot_inc, "LS"::livelihood_strategy];
	}

	user_command "Save People" category: "Saving init" when: init_end = true color: #darkblue {
		save personas to: save_personas type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "HOUSEHOLD"::my_hogar, "AGE"::Age, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "vMOF"::vMOF, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef];
	}

	user_command "Save all init files" category: "Saving init" when: init_end = true color: #darkred {
		save cell to: save_landscape type: "shp" attributes: ["NAME"::name, "DEF"::is_deforest, "CULT"::cult, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
		save predios to: save_predios type: "shp" attributes:
		["NAME"::name, "CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_RATE"::forest_rate, "DIST_VIAAUCA"::dist_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest];
		save hogares to: save_hogares type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOG_MEMBERS"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOID"::chef_auto_id, "MOF"::MOF, "COMMON_POT"::common_pot_inc, "LS"::livelihood_strategy];
		save personas to: save_personas type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "VIV_ID"::viv_id, "HOUSEHOLD"::my_hogar, "AGE"::Age, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "vMOF"::vMOF, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef];
	}

	parameter "File chooser landscape" category: "Saving init" var: save_landscape;
	parameter "File chooser plots" category: "Saving init" var: save_predios;
	parameter "File chooser households" category: "Saving init" var: save_hogares;
	parameter "File chooser people" category: "Saving init" var: save_personas;
	output {
		display map_ALG type: opengl {
			grid cell;
			species predios aspect: default;
			species hogares;
		}

		display map_LS type: opengl {
			grid cell;
			species predios aspect: carto_LS;
			species hogares;
		}

		display map_tx_def type: opengl {
			grid cell;
			species predios aspect: carto_tx_def;
			species hogares;
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
		monitor "Moy. déforest." value: area_deforest_mean; //-------------------------------------
 browse "suivi hogares" value: hogares attributes:
		["sec_id", "hog_id", "viv_id", "Total_Personas", "Total_Hombres", "Total_Mujeres", "MOF", "my_predio", "common_pot_inc"];
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