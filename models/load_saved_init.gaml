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
	}

	action load_saved_vias {
		write "---START OF INIT ROADS";
		create vias from: saved_vias with: [name:: string(get("NAME")), orden::int(get("ORDEN"))];
		write "---END OF INIT ROADS";
	}

	action load_saved_predios {
		write "---START OF INIT PLOTS";
		create predios from: saved_predios with:
		[name:: string(get("NAME")), clave_cata::string(get("clave_cata")), is_free::bool(get('free')), area_total::int(get("AREA_TOTAL")), area_deforest::int(get("AREA_DEF")), area_forest::int(get("AREA_F")), def_rate::float(get("DEF_RATE")), forest_rate::float(get("FOREST_RATE")), dist_via_auca::float(get("DIST_VIAAUCA")), prox_via_auca::float(get("PROX_VIAAUCA")), indigena::int(get("INDIGENA")), LS::string(get("LS")), my_hogar::hogares(get("HOUSEHOLD")), cells_inside::list<cell>(get("CELLS_IN")), cells_deforest::list<cell>(get("CELLS_DEF")), cells_forest::list<cell>(get("CELLS_F")), cells_urban::list<cell>(get("CELLS_U")), cashcrops_amount::int(get("CASH_C")), subcrops_amount::int(get("SUB_C"))];
		write "---END OF INIT PLOTS";
	}

	action load_saved_hogares {
	}

	action load_saved_personas {
	}

} /* Insert your model definition here */

