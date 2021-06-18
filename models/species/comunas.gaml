/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model comunas_def
//
// DEFINITION OF COMUNAS (community plots)
//
import "../species_def.gaml"
//
species comunas {
	string clave_cata;
	int area_total -> length(cells_inside);
	int area_deforest -> length(cells_deforest);
	int area_forest -> length(cells_forest);
	list<cell> cells_inside <- cell overlapping self; //trouver mieux que overlapping ?
	list<cell> cells_deforest -> cells_inside where (each.is_deforest = true);
	list<cell> cells_forest -> cells_inside where (each.is_deforest = false);
	int nb_hogares;
	int nb_personas;
	float def_rate;
	float income_crops_annual;
	float comuna_subcrops_needs;
	int comuna_subcrops_amount;
	float forest_rate;
	bool hunger_alert;
	bool needs_alert;
	list<personas> membres_comuna;
	//
	action deforestation_rate_calc {
		if area_total > 0 {
			def_rate <- (area_deforest / area_total) * 100;
			forest_rate <- (area_forest / area_total) * 100;
		} else {
			def_rate <- 0.0;
		}

	}

	action assess_income_needs {
		income_crops_annual <- (sum(cells_inside where (each.landuse = "SC2") collect each.rev) * 12);
	}

	action crops_calc {
		comuna_subcrops_amount <- (length(cells_deforest where (each.landuse = "SC3.1" or each.landuse = "SC4.1" or each.landuse = "SC4.2" or each.landuse = "SE3")));
	}

	action setting_alerts {
		if (unforest_based * comuna_subcrops_needs / 100 > comuna_subcrops_amount) { //dépend de la part de subsistance due à la forêt
			hunger_alert <- true;
		}

		if hunger_alert {
			needs_alert <- true;
		}

	}

	aspect default {
		draw shape color: #black border: #black;
	}

}