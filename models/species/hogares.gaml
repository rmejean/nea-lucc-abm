/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model hogares_def
//
//
// DEFINITION OF HOGARES (households)
//
//
import "../species_def.gaml"
species hogares {
	string sec_id;
	string hog_id;
	string viv_id;
	int Total_Personas;
	int Total_Hombres;
	int Total_Mujeres;
	predios my_predio;
	cell my_house;
	list<personas> membres_hogar;
	personas chef_hogar;
	string chef_auto_id;
	float labor_force;
	float subcrops_needs;
	float common_pot_inc;
	string livelihood_strategy <- 'none';
	bool needs_alert;
	bool MOF_alert;
	float MOF_total;
	float MOF_occupied;
	float MOF_available;

	action values_calc {
		labor_force <- (sum(membres_hogar collect each.labor_value) * 30);
		subcrops_needs <- (sum(membres_hogar collect each.food_needs));
	}

	action head_and_ethnicity {
		chef_hogar <- membres_hogar with_min_of each.orden_en_hogar;
		chef_auto_id <- chef_hogar.auto_id;
		if chef_auto_id = "indigena" {
			ask my_predio {
				indigena <- 100;
			}

		} else {
			ask my_predio {
				indigena <- 0;
			}

		}

	}

	action update_needs {
		common_pot_inc <- sum(my_predio.cells_inside collect each.rev);
		ask my_predio {
			do crops_calc;
		}

		if (subcrops_needs > my_predio.subcrops_amount) or ($_ANFP > common_pot_inc * 12) {
			needs_alert <- true;
		}

	}

	action update_assets {
		MOF_total <- labor_force;
		MOF_occupied <- (length(my_predio.cells_deforest where (each.cult = "maniocmais")) * MOFcost_maniocmais) + (length(my_predio.cells_deforest where
		(each.cult = "fruits")) * MOFcost_fruits) + (length(my_predio.cells_deforest where (each.cult = "s_livestock")) * MOFcost_s_livestock) + (length(my_predio.cells_deforest where
		(each.cult = "plantain")) * MOFcost_plantain) + (length(my_predio.cells_deforest where (each.cult = "coffee")) * MOFcost_coffee) + (length(my_predio.cells_deforest where
		(each.cult = "cacao")) * MOFcost_cacao) + (length(my_predio.cells_deforest where (each.cult = "livestock")) * MOFcost_livestock);
		MOF_available <- MOF_total - MOF_occupied;
		if MOF_available < 0 {
			MOF_alert <- true;
		}

	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}
