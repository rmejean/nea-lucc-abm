/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model predios_def
//
//
// DEFINITION OF PREDIOS (plots)
//
//
import "../species_def.gaml"
species predios {
	string clave_cata;
	bool is_empty;
	bool is_free_MCA;
	int id_EMC_LS1_1 <- 0;
	int id_EMC_LS1_2 <- 0;
	int id_EMC_LS1_3 <- 0;
	int id_EMC_LS2 <- 0;
	int id_EMC_LS3 <- 0;
	int id_EMC <- 0;
	int area_total -> length(cells_inside);
	int area_deforest -> length(cells_deforest);
	int area_forest -> length(cells_forest);
	float def_rate;
	float forest_rate;
	float dist_via_auca <- distance_to(self, vias where (each.orden = 1) closest_to self); //distance to via Auca (main road on the study area, original settlement and and location of oil companies)
	float prox_via_auca <- 20000 - (self.dist_via_auca);
	int indigena; //indigenous index
	string LS <- 'none'; //livelihood strategy
	rgb color;
	rgb color_tx_def;
	rgb LS_color;
	rgb bool_color;
	hogares my_hogar;
	int subcrops_amount;
	//Cell lists
	list<cell> cells_inside <- cell overlapping self; //trouver mieux que overlapping ?
	list<cell> cells_deforest -> cells_inside where (each.is_deforest = true);
	list<cell> cells_forest -> cells_inside where (each.is_deforest = false);
	list<cell> reforest_candidates -> cells_inside where (each.landuse = 'fallow' and each.nb_months >= 60);
	list<cell> cells_SE1_1 -> cells_inside where (each.landuse = 'SE1.1');
	list<cell> cells_SE1_2 -> cells_inside where (each.landuse = 'SE1.2');
	int nb_cells_SE1_1 -> length(cells_SE1_1);
	int nb_cells_SE1_2 -> length(cells_SE1_2);
	//list<cell> cells_urban -> cells_inside where (each.grid_value = 4);
	list<int> rankings_LS_EMC <- ([]);

	action deforestation_rate_calc {
		if area_total > 0 {
			def_rate <- (area_deforest / area_total) * 100;
			forest_rate <- (area_forest / area_total) * 100;
		} else {
			def_rate <- nil;
		}

	}

	action identify_house {
		ask (cells_deforest closest_to (vias closest_to self)) {
			landuse <- 'house';
			is_free <- false;
			is_deforest <- nil;
		}

	}

	action crops_calc {
		subcrops_amount <- (length(cells_deforest where (each.landuse = "SC3.1" or each.landuse = "SC4.1" or each.landuse = "SC4.2" or each.landuse = "SE3")));
	}

	action map_deforestation_rate {
		color_tx_def <- def_rate = 0 ? #white : (between(def_rate, 10, 25) ? rgb(253, 204, 138) : (between(def_rate, 25, 50) ? rgb(253, 204, 138) : (between(def_rate, 50, 75) ?
		rgb(252, 141, 89) : rgb(215, 48, 31))));
	}

	action map_livelihood_strategies {
		LS_color <- my_hogar.livelihood_strategy = 'SP3' ? #pink : (my_hogar.livelihood_strategy = 'SP2' ? #green : (my_hogar.livelihood_strategy = 'SP1.1' ?
		#red : (my_hogar.livelihood_strategy = 'SP1.2' ? #blue : #yellow)));
	}

	action map_needs_alert {
		bool_color <- my_hogar.needs_alert = true ? #red : #green;
	}

	action map_assets_alert {
		bool_color <- my_hogar.labor_alert = true ? #red : #green;
	}

	aspect default {
		draw shape color: #transparent border: #black;
	}

	aspect map_def_rate {
		draw shape color: color_tx_def border: #black;
	}

	aspect map_LS {
		draw shape color: LS_color border: #black;
	}

	aspect map_LUC_decisions {
		draw shape color: bool_color border: #black;
	}

}