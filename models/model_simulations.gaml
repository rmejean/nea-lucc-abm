/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/ model simulations

import "model_core.gaml"
import "species_def.gaml" //Global variables for monitors
global {
//-----------------------------
//Monitors & charts------------
//-----------------------------
	int nb_menages -> length(hogares);
	int nb_personas -> length(personas);
	int nb_predios -> length(predios);
	int nb_LS1_1 -> length (hogares where (each.livelihood_strategy="SP1.1"));
	int nb_LS1_2 -> length (hogares where (each.livelihood_strategy="SP1.2"));
	int nb_LS1_3 -> length (hogares where (each.livelihood_strategy="SP1.3"));
	int nb_LS2 -> length (hogares where (each.livelihood_strategy="SP2"));
	int nb_LS3 -> length (hogares where (each.livelihood_strategy="SP3"));
	int total_jobs -> sum(empresas collect (each.nb_jobs));
	int total_free_jobs -> sum(empresas collect (each.free_jobs));
	int deforestation -> sum(predios collect (each.area_deforest));
	float ratio_deforest_min -> predios min_of (each.def_rate);
	float ratio_deforest_max -> predios max_of (each.def_rate);
	float ratio_deforest_mean -> predios mean_of (each.def_rate);
	int area_deforest_min -> predios min_of (each.area_deforest);
	int area_deforest_max -> predios max_of (each.area_deforest);
	float area_deforest_mean <- predios mean_of (each.area_deforest) update: predios mean_of (each.area_deforest);
	float labor_mean <- hogares mean_of (each.labor_force) update: hogares mean_of (each.labor_force);
	//-----------------------------
	//Parameters-------------------
	//-----------------------------
	int nb_new_jobs;
	float wages_min;
	float wages_max;
	float job_wages <- rnd(wages_min, wages_max);
	bool social_network_inf <- false; //Enables the imitation of LUCC choices from the household's social network
	bool scenarios <- false; //launch scenarios
	bool save_years <- true; //save a classif export every 12 cycles
	//-----------------------------
	//Saving init------------------
	//-----------------------------
	bool init_end <- false;
	string save_landscape <- ("../includes/initGENfiles/agricultural_landscape.shp");
	string save_simplified_classif <- ("../includes/initGENfiles/simplified_classif.tif");
	string save_vias <- ("../includes/initGENfiles/vias.shp");
	string save_empresas <- ("../includes/initGENfiles/empresas.shp");
	string save_predios <- ("../includes/initGENfiles/predios.shp");
	string save_hogares <- ("../includes/initGENfiles/hogares.shp");
	string save_personas <- ("../includes/initGENfiles/personas.shp");
	//
	bool step_end <- false;
	string export_landscape <- ("../exports/agricultural_landscape.shp");
	string export_simplified_classif <- ("../exports/simplified_classif.tif");
	string export_vias <- ("../exports/vias.shp");
	string export_empresas <- ("../exports/empresas.shp");
	string export_predios <- ("../exports/predios.shp");
	string export_hogares <- ("../exports/hogares.shp");
	string export_personas <- ("../exports/personas.shp");
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// SAVE AN INIT /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
experiment save_init type: gui until: stop_simulation = true {
//
//DATA EXPORT
//
//Saving pixels
//TODO : il faut ajouter des messages avant et après enregistrement en utilisant file_exists
	user_command "Save all files" category: "Saving init" when: init_end = true color: #darkred {
	//save cell to: save_landscape type: "shp" attributes:
	//["NAME"::name, "DEF"::is_deforest, "landuse"::landuse, "landuse2"::landuse2, "landuse3"::landuse3, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
		save cell to: save_simplified_classif type: "geotiff"; //Export a simplified classification
		save vias to: save_vias type: "shp" attributes: ["NAME"::name, "ORDEN"::orden];
		save predios to: save_predios type: "shp" attributes:
		["NAME"::name, "CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_R"::forest_rate, "D_VIAAUCA"::dist_via_auca, "PROX_VIAA"::prox_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest, "SUB_C"::subcrops_amount, "idLS1_1"::id_EMC_LS1_1, "idLS1_2"::id_EMC_LS1_2, "idLS1_3"::id_EMC_LS1_3, "idLS2"::id_EMC_LS2, "idLS3"::id_EMC_LS3];
		save hogares to: save_hogares type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOI"::chef_auto_id, "LABOR_F"::labor_force, "BRUT_INC"::gross_monthly_inc, "INC"::income, "LS"::livelihood_strategy, "SUB_NEED"::subcrops_needs, "NEEDS_W"::needs_alert, "HUNGER_W"::hunger_alert, "MONEY_W"::money_alert, "MOF_O"::occupied_workers, "MOF_A"::available_workers, "MOF_E"::employees_workers, "MOF_W"::labor_alert, "NB_OIL_W"::oil_workers, "ESTIM_ANINC"::estimated_annual_inc];
		save personas to: save_personas type: "shp" attributes:
		["NAME"::name, "HOG_ID"::hog_id, "COWORKHOG"::co_workers_hog, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "SUB_NEED"::subcrops_needs, "HOUSEHOLD"::my_hogar, "AGE"::Age, "MES_NAC"::mes_nac, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "labor_value"::labor_value, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef, "WORK"::oil_worker, "EMPRESA"::empresa, "CONTRACT"::contract_term, "WORK_M"::working_months, "WORKPACE"::work_pace, "ANNUAL_INC"::annual_inc];
		save empresas to: save_empresas type: "shp" attributes: ["NAME"::name, "NB_JOBS"::nb_jobs, "FR_JOBS"::free_jobs, "WORKERS"::workers];
	}

	parameter "Generate a new init?" category: "Parameters" var: new_init init: true;
	//Model Parameters
	parameter "LUCC influenced by social network choices?" category: "Global Parameters" var: social_network_inf init: false;
	parameter "Number of new jobs per months" category: "Global Parameters" var: nb_new_jobs init: 3 min: 1 max: 30;
	parameter "Amount needed to feed a person per year" category: "Global Parameters" var: $_ANFP init: 3900.0;
	//Manpower
	parameter "Employees cost" category: "Manpower" var: cost_employees init: 250;
	parameter "Job wages min" category: "Manpower" var: wages_min init: 300.0;//biblio : Morin (2015) p. 79
	parameter "Job wages max" category: "Manpower" var: wages_max init: 400.0;//biblio : Morin (2015) p. 79
	//Agronomy
	parameter "Soil depletion probability" category: "Agronomy" var: soil_depletion_proba init: 0.2;
	parameter "Price cacao" category: "Agronomy" var: price_cacao init: 100;
	parameter "Price Coffee" category: "Agronomy" var: price_coffee init: 14;
	parameter "Price_manioc" category: "Agronomy" var: price_manioc init: 15;
	parameter "Price plantain" category: "Agronomy" var: price_plantain init: 3;
	parameter "Price tubercules" category: "Agronomy" var: price_tubercules init: 10;
	parameter "Price papayes" category: "Agronomy" var: price_papayes init: 1;
	parameter "Price ananas" category: "Agronomy" var: price_ananas init: 1;
	parameter "Price maïs" category: "Agronomy" var: price_mais init: 18;
	parameter "Price veaux" category: "Agronomy" var: price_veaux init: 150;
	parameter "Price vache réformée" category: "Agronomy" var: price_vachereforme init: 130;
	parameter "Price cheese" category: "Agronomy" var: price_cheese init: 2.5;
	parameter "Price pig" category: "Agronomy" var: price_pig init: 250;
	parameter "Price porcelet" category: "Agronomy" var: price_porcelet init: 80;
	parameter "Price truie" category: "Agronomy" var: price_truie init: 2;
	parameter "Price oldchicken" category: "Agronomy" var: price_oldchicken init: 17;
	parameter "Price chicken" category: "Agronomy" var: price_chicken init: 15;
	parameter "Maintenance cost of cacao inputs" category: "Agronomy" var: costmaint_cacaoinputs init: 13.375;
	parameter "Maintenance cost of cattle 1" category: "Agronomy" var: costmaint_cattle_1 init: 11.48; //TODO: à revoir : plus il y a d'hectares en pâture, plus c'est cher
	parameter "Maintenance cost of cattle 2" category: "Agronomy" var: costmaint_cattle_2 init: 1.61635;
	parameter "Buy a pig" category: "Agronomy" var: buy_pig init: 12.27;
	parameter "Maintenance cost of pig breeding 1" category: "Agronomy" var: costmaint_pigbreeding init: 5.375;
	parameter "Maintenance cost of pig breeding 2" category: "Agronomy" var: costmaint_pigbreeding2 init: 21.1;
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// RUN MODEL //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
experiment run_model type: gui until: stop_simulation = true {
//
//DATA EXPORT
//
	init {
		new_init <- false;
	}

	//Saving all
	user_command "Save all files" category: "Export data" when: step_end = true color: #darkred {
	//save cell to: export_landscape type: "shp" attributes:
	//["NAME"::name, "DEF"::is_deforest, "landuse"::landuse, "landuse2"::landuse2, "landuse3"::landuse3, "PREDIO"::predio, "HOUSEHOLD"::my_hogar];
		save cell to: export_simplified_classif type: "geotiff"; //Export a simplified classification
		save vias to: export_vias type: "shp" attributes: ["NAME"::name, "ORDEN"::orden];
		save predios to: export_predios type: "shp" attributes:
		["NAME"::name, "CLAVE"::clave_cata, "free"::is_free, "AREA_TOTAL"::area_total, "AREA_DEF"::area_deforest, "AREA_F"::area_forest, "DEF_RATE"::def_rate, "FOREST_R"::forest_rate, "D_VIAAUCA"::dist_via_auca, "PROX_VIAA"::prox_via_auca, "INDIGENA"::indigena, "LS"::LS, "HOUSEHOLD"::my_hogar, "CELLS_IN"::cells_inside, "CELLS_DEF"::cells_deforest, "CELLS_F"::cells_forest, "SUB_C"::subcrops_amount, "idLS1_1"::id_EMC_LS1_1, "idLS1_2"::id_EMC_LS1_2, "idLS1_3"::id_EMC_LS1_3, "idLS2"::id_EMC_LS2, "idLS3"::id_EMC_LS3];
		save hogares to: export_hogares type: "shp" attributes:
		["NAME"::name, "SEC_ID"::sec_id, "HOG_ID"::hog_id, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "HEAD_AUTOI"::chef_auto_id, "LABOR_F"::labor_force, "BRUT_INC"::gross_monthly_inc, "INC"::income, "LS"::livelihood_strategy, "SUB_NEED"::subcrops_needs, "NEEDS_W"::needs_alert, "HUNGER_W"::hunger_alert, "MONEY_W"::money_alert, "MOF_O"::occupied_workers, "MOF_A"::available_workers, "MOF_E"::employees_workers, "MOF_W"::labor_alert, "NB_OIL_W"::oil_workers, "ESTIM_ANINC"::estimated_annual_inc];
		save personas to: export_personas type: "shp" attributes:
		["NAME"::name, "HOG_ID"::hog_id, "COWORKHOG"::co_workers_hog, "TOTAL_P"::Total_Personas, "TOTAL_M"::Total_Hombres, "TOTAL_F"::Total_Mujeres, "PLOT"::my_predio, "HOUSE"::my_house, "HOG_MEMBER"::membres_hogar, "HEAD"::chef_hogar, "SUB_NEED"::subcrops_needs, "HOUSEHOLD"::my_hogar, "AGE"::Age, "MES_NAC"::mes_nac, "SEXO"::Sexo, "ORDEN"::orden_en_hogar, "labor_value"::labor_value, "INC"::inc, "AUTO_ID"::auto_id, "HEAD"::chef, "WORK"::oil_worker, "EMPRESA"::empresa, "CONTRACT"::contract_term, "WORK_M"::working_months, "WORKPACE"::work_pace, "ANNUAL_INC"::annual_inc];
		save empresas to: export_empresas type: "shp" attributes: ["NAME"::name, "NB_JOBS"::nb_jobs, "FR_JOBS"::free_jobs, "WORKERS"::workers];
	}

	reflex when: every(12 #cycles) and save_years {
		save cell to: ("../exports/simu_month" + cycle + ".asc") type: "asc";
		write "EXPORT CLASSIF";
	}
	//Model Parameters
	parameter "LUCC influenced by social network choices?" category: "Global Parameters" var: social_network_inf init: false;
	parameter "Scenarios?" category: "Global Parameters" var: scenarios init: false;
	parameter "Number of new jobs per months" category: "Global Parameters" var: nb_new_jobs init: 3 min: 1 max: 30;
	parameter "Amount needed to feed a person per year" category: "Global Parameters" var: $_ANFP init: 3900.0;
	//Manpower
	parameter "Employees cost" category: "Manpower" var: cost_employees init: 250;
	parameter "Job wages min" category: "Manpower" var: wages_min init: 250.0;
	parameter "Job wages max" category: "Manpower" var: wages_max init: 350.0;
	//Agronomy
	parameter "Soil depletion probability" category: "Agronomy" var: soil_depletion_proba init: 0.2;
	parameter "Price cacao" category: "Agronomy" var: price_cacao init: 100;
	parameter "Price Coffee" category: "Agronomy" var: price_coffee init: 14;
	parameter "Price_manioc" category: "Agronomy" var: price_manioc init: 15;
	parameter "Price plantain" category: "Agronomy" var: price_plantain init: 3;
	parameter "Price tubercules" category: "Agronomy" var: price_tubercules init: 10;
	parameter "Price papayes" category: "Agronomy" var: price_papayes init: 1;
	parameter "Price ananas" category: "Agronomy" var: price_ananas init: 1;
	parameter "Price maïs" category: "Agronomy" var: price_mais init: 18;
	parameter "Price veaux" category: "Agronomy" var: price_veaux init: 150;
	parameter "Price vache réformée" category: "Agronomy" var: price_vachereforme init: 130;
	parameter "Price cheese" category: "Agronomy" var: price_cheese init: 2.5;
	parameter "Price pig" category: "Agronomy" var: price_pig init: 250;
	parameter "Price porcelet" category: "Agronomy" var: price_porcelet init: 80;
	parameter "Price truie" category: "Agronomy" var: price_truie init: 2;
	parameter "Price oldchicken" category: "Agronomy" var: price_oldchicken init: 17;
	parameter "Price chicken" category: "Agronomy" var: price_chicken init: 15;
	parameter "Maintenance cost of cacao inputs" category: "Agronomy" var: costmaint_cacaoinputs init: 13.375;
	parameter "Maintenance cost of cattle 1" category: "Agronomy" var: costmaint_cattle_1 init: 11.48; //TODO: à revoir : plus il y a d'hectares en pâture, plus c'est cher
	parameter "Maintenance cost of cattle 2" category: "Agronomy" var: costmaint_cattle_2 init: 1.61635;
	parameter "Buy a pig" category: "Agronomy" var: buy_pig init: 12.27;
	parameter "Maintenance cost of pig breeding 1" category: "Agronomy" var: costmaint_pigbreeding init: 5.375;
	parameter "Maintenance cost of pig breeding 2" category: "Agronomy" var: costmaint_pigbreeding2 init: 21.1;
	output {
		display map_ALG type: opengl {
			grid cell;
			species predios aspect: default;
			species hogares;
		}
		//
		monitor "Total ménages" value: nb_menages;
		monitor "Total personas" value: nb_personas;
		monitor "Total parcelles" value: nb_predios;
		monitor "Total oil_jobs" value: total_jobs;
		monitor "Total free_oil_jobs" value: total_free_jobs;
		monitor "Total LS1.1" value: nb_LS1_1;
		monitor "Total LS1.2" value: nb_LS1_2;
		monitor "Total LS1.3" value: nb_LS1_3;
		monitor "Total LS2" value: nb_LS2;
		monitor "Total LS3" value: nb_LS3;
		monitor "Ratio deforest min" value: ratio_deforest_min;
		monitor "Ratio deforest max" value: ratio_deforest_max;
		monitor "Moy. ratio deforest" value: ratio_deforest_mean;
		monitor "Sup. déforest. min" value: area_deforest_min;
		monitor "Sup. déforest. max" value: area_deforest_max;
		monitor "Moy. déforest." value: area_deforest_mean refresh: true;
		monitor "Moy. labor_force" value: labor_mean refresh: true;
		//
		display Ages synchronized: true {
			chart "Ages" type: histogram {
				loop i from: 0 to: 110 {
					data "" + i value: personas count (each.Age = i);
				}

			}

		}

		display "Deforestation" type: java2D synchronized: true {
			chart "Proportion: serie" type: series series_label_position: legend style: line {
				data "deforested pixels in fincas" accumulate_values: true value: deforestation color: #black;
			}

		}

		display "Needs" type: java2D synchronized: true {
			chart "Households don't have their needs met" type: series series_label_position: legend style: line {
				data "Households don't have their needs met" accumulate_values: true value: [length(hogares where (each.needs_alert = true))] color: #red marker: false style: line;
			}

		}

	}

}
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// BATCH EXP //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
experiment 'Run x simulations' type: batch repeat: 1 keep_seed: true until: stop_simulation = true {

	init {
		new_init <- false;
		save_years <- true;
	}

}