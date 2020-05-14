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
import "species_def.gaml"

//Global variables for monitors
global {
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
	float labor_mean <- hogares mean_of (each.labor_force) update: hogares mean_of (each.labor_force);

	//-----------------------------
	//Saving init------------------
	//-----------------------------
	bool init_end <- false;
	string save_landscape <- ("../../includes/initGENfiles/agricultural_landscape.shp");
	string save_vias <- ("../../includes/initGENfiles/vias.shp");
	string save_empresas <- ("../../includes/initGENfiles/empresas.shp");
	string save_predios <- ("../../includes/initGENfiles/predios.shp");
	string save_hogares <- ("../../includes/initGENfiles/hogares.shp");
	string save_personas <- ("../../includes/initGENfiles/personas.shp");
}

experiment save_init type: gui until: stop_simulation = true {
//
//DATA EXPORT
//
//Saving pixels

//TODO : il faut ajouter des messages avant et après enregistrement en utilisant file_exists
	user_command "Save Agricultural Landscape" category: "Saving init" when: init_end = true color: #darkblue {
	//save cell to: ("../../includes/initGENfiles/cells.csv") type:"csv" rewrite: true;
		save cell to: save_landscape type: "shp" attributes:
		["NAME"::name, "DEF"::is_deforest, "landuse"::landuse, "landuse2"::landuse2, "landuse3"::landuse3, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
	}
	//Saving roads
	user_command "Save Roads" category: "Save files" when: init_end = true color: #darkblue {
		save vias to: save_vias type: "shp" attributes: ["NAME"::name, "ORDEN"::orden];
	}
	//Saving oil ompagnies
	user_command "Save oil compagnies" category: "Save files" when: init_end = true color: #darkblue {
		save empresas to: save_empresas type: "shp" attributes: ["NAME"::name, "NB_JOBS"::nb_jobs, "FR_JOBS"::free_jobs, "WORKERS"::workers];
	}
	//Saving plots
	user_command "Save Plots" category: "Save files" when: init_end = true color: #darkblue {
		save predios to: save_predios type: "shp" attributes:
		["NAME"::name, "CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_R"::forest_rate, "D_VIAAUCA"::dist_via_auca, "PROX_VIAA"::prox_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest, "CELLS_U"::cells_urban, "CASH_C"::cashcrops_amount, "SUB_C"::subcrops_amount, "NEIGH"::neighbors];
	}
	//Saving households
	user_command "Save Households" category: "Save files" when: init_end = true color: #darkblue {
		save hogares to: save_hogares type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOI"::chef_auto_id, "LABOR_F"::labor_force, "BRUT_INC"::gross_monthly_inc, "INC"::income, "LS"::livelihood_strategy, "SUB_NEED"::subcrops_needs, "NEEDS_W"::needs_alert, "MOF_O"::occupied_workers, "MOF_A"::available_workers, "MOF_E"::employees_workers, "MOF_W"::labor_alert, "NB_OIL_W"::oil_workers, "ESTIM_ANINC"::estimated_annual_inc];
	}
	//Saving people
	user_command "Save People" category: "Save files" when: init_end = true color: #darkblue {
		save personas to: save_personas type: "shp" attributes:
		["NAME"::name, "HOG_ID"::hog_id, "HOGAR"::my_hogar, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "SUB_NEED"::subcrops_needs, "HOUSEHOLD"::my_hogar, "AGE"::Age, "MES_NAC"::mes_nac, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "labor_value"::labor_value, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef, "WORK"::oil_worker, "EMPRESA"::empresa, "CONTRACT"::contract_term, "WORK_M"::working_months, "WORKPACE"::work_pace, "ANNUAL_INC"::annual_inc];
	}
	//Saving cells
	user_command "Save cells" category: "Save files" when: init_end = true color: #darkblue {
		ask cell {save (cell where (grid_value != 0.0)) to: ("../../includes/initGENfiles/cells.csv") type: "csv" rewrite: true;}	
	}

	//Saving all
	user_command "Save all files" category: "Save files" when: init_end = true color: #darkred {
		save cell to: save_landscape type: "shp" attributes:
		["NAME"::name, "DEF"::is_deforest, "landuse"::landuse, "landuse2"::landuse2, "landuse3"::landuse3, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
		save vias to: save_vias type: "shp" attributes: ["NAME"::name, "ORDEN"::orden];
		save predios to: save_predios type: "shp" attributes:
		["NAME"::name, "CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_R"::forest_rate, "D_VIAAUCA"::dist_via_auca, "PROX_VIAA"::prox_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest, "CELLS_U"::cells_urban, "CASH_C"::cashcrops_amount, "SUB_C"::subcrops_amount, "NEIGH"::neighbors, "idLS1_1"::id_EMC_LS1_1, "idLS1_2"::id_EMC_LS1_2, "idLS1_3"::id_EMC_LS1_3, "idLS2"::id_EMC_LS2, "idLS3"::id_EMC_LS3];
		save hogares to: save_hogares type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOI"::chef_auto_id, "LABOR_F"::labor_force, "BRUT_INC"::gross_monthly_inc, "INC"::income, "LS"::livelihood_strategy, "SUB_NEED"::subcrops_needs, "NEEDS_W"::needs_alert, "MOF_O"::occupied_workers, "MOF_A"::available_workers, "MOF_E"::employees_workers, "MOF_W"::labor_alert, "NB_OIL_W"::oil_workers, "ESTIM_ANINC"::estimated_annual_inc];
		save personas to: save_personas type: "shp" attributes:
		["NAME"::name, "HOG_ID"::hog_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "HOGAR"::my_hogar, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "SUB_NEED"::subcrops_needs, "HOUSEHOLD"::my_hogar, "AGE"::Age, "MES_NAC"::mes_nac, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "labor_value"::labor_value, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef, "WORK"::oil_worker, "EMPRESA"::empresa, "CONTRACT"::contract_term, "WORK_M"::working_months, "WORKPACE"::work_pace, "ANNUAL_INC"::annual_inc];
		save empresas to: save_empresas type: "shp" attributes: ["NAME"::name, "NB_JOBS"::nb_jobs, "WORKERS"::workers];
	}

	user_command "Save init (serialization)" category: "Init Generator"  color: #darkgreen {
		save saved_simulation_file('init.gsim', [simulation]);
	}

	user_command "Save init - 2 (serialization)" category: "Init Generator" color: #darkgreen {
		write "Save of simulation : " + save_simulation('simpleSimuList.gsim');
	}

	parameter "Generate a new init?" category: "Parameters" var: new_init;
	
	output {
		display map_ALG type: opengl {
			grid cell;
			species predios aspect: default;
			species hogares;
		}

		//		display map_LS type: opengl {
		//			grid cell;
		//			species predios aspect: map_LS;
		//			species hogares;
		//		}
		//
		//		display map_tx_def type: opengl {
		//			grid cell;
		//			species predios aspect: map_def_rate;
		//			species hogares;
		//		}
		//		display map_LUC_decisions type: opengl {
		//			species cell aspect: land_use;
		//			species predios aspect: map_LUC_decisions;
		//			//species hogares;
		//		}
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
		monitor "Moy. labor_force" value: labor_mean;
		//-------------------------------------
		browse "suivi hogares" value: hogares refresh: true attributes:
		["sec_id", "hog_id", "viv_id", "Total_Personas", "Total_Hombres", "Total_Mujeres", "labor_force", "my_predio", "my_house", "common_pot_inc", "subcrops_needs", "needs_alert"];
		browse "suivi personas" value: personas refresh: true attributes: ["sec_id", "hog_id", "viv_id", "Age", "Sexo", "labor_value", "my_hogar", "orden_en_hogar", "my_predio"];
		browse "suivi predios" value: predios refresh: true attributes:
		["clave_cata", "is_free", "dist_via_auca", "prox_via_auca", "area_total", "area_deforest", "def_rate", "cells_inside", "subcrops_amount", "cashcrops_amount"];
		//-------------------------------------
		display Ages synchronized: true {
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