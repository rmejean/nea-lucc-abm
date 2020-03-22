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

	action load_saved_cells {
	}

	action load_saved_vias {
		write "---START OF INIT ROADS";
		create vias from: saved_vias with: [name::string(get("NAME")),orden::int(get("ORDEN"))];
		write "---END OF INIT ROADS";
	}

	action load_saved_predios {
		write "---START OF INIT PLOTS";
		create predios from: saved_predios with: [clave_cata::string(read('clave_cata'))];
	}

	action load_saved_hogares {
	}

	action load_saved_personas {
	}

} /* Insert your model definition here */

