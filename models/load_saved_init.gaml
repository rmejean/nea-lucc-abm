/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model init_saved

import "species_def.gaml"
import "init_data_import.gaml"

global {

	action init_saved_files {
		saved_cells <- file("../initGENfiles/agricultural_landscape.shp");
		saved_vias <- file("../initGENfiles/vias.shp");
		saved_predios <- file("../initGENfiles/predios.shp");
		saved_hogares <- file("../initGENfiles/hogares.shp");
		saved_personas <- file("../initGENfiles/personas.shp");
	}

	action load_saved_cells {
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

		create patches from: saved_cells with:
		[name:: string(get("NAME")), is_deforest::bool(get("DEF")), cult::string(get("CULT")), predio::predios(get("PREDIO")), my_hogar::hogares(get("HOUSEHOLD"))];
		ask patches {
			ask first(cell inside (self)) {
				is_deforest <- myself.is_deforest;
				cult <- myself.cult;
				predio <- myself.predio;
				my_hogar <- myself.my_hogar;
			}

			do die;
		}

		ask cell {
			do param_activities;
		}

		write "---END OF INIT CELLS";
	}

	action load_saved_vias {
		write "---START OF INIT ROADS";
		create vias from: saved_vias with: [name:: string(get("NAME")), orden::int(get("ORDEN"))];
		write "---END OF INIT ROADS";
	}

	action load_saved_predios {
		write "---START OF INIT PLOTS";
		create predios from: saved_predios with:
		[name:: string(get("NAME")), clave_cata::string(get("CLAVE")), is_free::bool(get('free')), area_total::int(get("AREA_TOTAL")), area_deforest::int(get("AREA_DEF")), area_forest::int(get("AREA_F")), def_rate::float(get("DEF_RATE")), forest_rate::float(get("FOREST_R")), dist_via_auca::float(get("D_VIAAUCA")), prox_via_auca::float(get("PROX_VIAA")), indigena::int(get("INDIGENA")), LS::string(get("LS")), my_hogar::hogares(get("HOUSEHOLD")), cells_inside::list<cell>(get("CELLS_IN")), cells_deforest::list<cell>(get("CELLS_DEF")), cells_forest::list<cell>(get("CELLS_F")), cells_urban::list<cell>(get("CELLS_U")), cashcrops_amount::int(get("CASH_C")), subcrops_amount::int(get("SUB_C")), needs_alert::bool(get("NEEDS_W")), MOF_total::float(get("MOF_total")), MOF_available::float(get("MOF_A")), MOF_occupied::float(get("MOF_O")), MOF_alert::bool(get("MOF_W"))];
		ask predios {
			do map_deforestation_rate;
		}

		write "---END OF INIT PLOTS";
	}

	action load_saved_hogares {
		write "---START OF INIT HOUSEHOLDS";
		create hogares from: saved_hogares with:
		[name:: string(get("NAME")), sec_id::string(get("SEC_ID")), hog_id::string(get("HOG_ID")), viv_id::string(get("NAME")), Total_Personas::int(get("TOTAL_P")), Total_Hombres::int(get("TOTAL_M")), Total_Mujeres::int(get("TOTAL_F")), my_predio::predios(get("PLOT")), my_house::cell(get("HOUSE")), membres_hogar::list<personas>(get("HOG_MEMBER")), chef_hogar::personas(get("HEAD")), chef_auto_id::string(get("HEAD_AUTOI")), labor_force::float(get("labor_force")), common_pot_inc::float(get("COMMON_POT")), livelihood_strategy::string(get("LS"))];
		write "---END OF INIT HOUSEHOLDS";
	}

	action load_saved_personas {
		write "---START OF INIT PEOPLE";
		create personas from: saved_personas with:
		[name:: string(get("NAME")), sec_id::string(get("SEC_ID")), hog_id::string(get("HOG_ID")), viv_id::string(get("NAME")), Total_Personas::int(get("TOTAL_P")), Total_Hombres::int(get("TOTAL_M")), Total_Mujeres::int(get("TOTAL_F")), my_predio::predios(get("PLOT")), my_house::cell(get("HOUSE")), membres_hogar::list<personas>(get("HOG_MEMBER")), chef_hogar::personas(get("HEAD")), chef_auto_id::string(get("HEAD_AUTOI")), labor_force::float(get("labor_force")), common_pot_inc::float(get("COMMON_POT")), livelihood_strategy::string(get("LS")), my_hogar::hogares(get("HOUSEHOLD")), Age::int(get("AGE")), mes_nac::string(get("MES_NAC")), Sexo::string(get("SEXO")), orden_en_hogar::int(get("ORDEN")), labor_value::float(get("labor_value")), inc::float(get("INC")), auto_id::string(get("AUTO_ID")), chef::bool(get("HEAD"))];
		write "---END OF INIT PEOPLE";
	}

}
		


