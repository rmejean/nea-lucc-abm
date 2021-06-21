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
	float com_available_workers;
	float com_occupied_workers;
	float com_labor_force;
	float def_rate ;
	float income_crops_annual;
	float comuna_subcrops_needs;
	int comuna_subcrops_amount;
	float forest_rate ;
	bool hunger_alert;
	bool money_alert;
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
		do crops_calc;
	}

	action crops_calc {
		comuna_subcrops_amount <- (length(cells_deforest where (each.landuse = "SC3.1")));
	}

	action setting_alerts {
		if (unforest_based * comuna_subcrops_needs / 100 > comuna_subcrops_amount) { //dépend de la part de subsistance due à la forêt
			hunger_alert <- true;
		}

		if ((unforest_based * ($_ANFP * length(membres_comuna) / 100)) > income_crops_annual) {
			money_alert <- true;
		}

		if hunger_alert {
			needs_alert <- true;
		}

	}

	action subsistence_LUC {
		let needs <- (unforest_based * comuna_subcrops_needs / 100) - comuna_subcrops_amount;
		let stop <- false;
		loop while: length(cells_forest) > 0 and (needs > 0) and (stop = false) { //TODO: s'il y a au moins un pixel à déforester mais rajouter aussi les friches longues!
			if com_available_workers > (laborcost_SC3_1 + laborcost_install_SC3) {
				ask closest_to(cells_forest, one_of(cells_deforest), 1) {
					is_deforest <- true;
					landuse <- 'SC3.1';
					grid_value <- 3.0;
					new_SC3 <- new_SC3 + 1;
					predio.subcrops_amount <- predio.subcrops_amount + 1;
					write "new SC3.1 for SUBSISTENCE at " + location;
					my_comuna.com_available_workers <- (my_comuna.com_available_workers - (laborcost_SC3_1 + laborcost_install_SC3));
					nb_months <- 0;
				}

				needs <- comuna_subcrops_needs - comuna_subcrops_amount;
			} else {
				write "pas assez de main d'oeuvre pour faire du SUBSISTENCE LUC en comuna";
				stop <- true;
			}

		}

	}

	aspect default {
		draw shape color: #black border: #black;
	}

}