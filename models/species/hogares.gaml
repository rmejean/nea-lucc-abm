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
	float occupied_workers;
	float available_workers;
	int employees_workers <- 0;
	float subcrops_needs;
	float common_pot_inc;
	float income;
	string livelihood_strategy <- 'none';
	bool needs_alert;
	bool labor_alert;

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

	action update_assets {
		occupied_workers <- (length(my_predio.cells_deforest where (each.cult = "maniocmais")) * MOFcost_maniocmais) + (length(my_predio.cells_deforest where
		(each.cult = "fruits")) * MOFcost_fruits) + (length(my_predio.cells_deforest where (each.cult = "s_livestock")) * MOFcost_s_livestock) + (length(my_predio.cells_deforest where
		(each.cult = "plantain")) * MOFcost_plantain) + (length(my_predio.cells_deforest where (each.cult = "coffee")) * MOFcost_coffee) + (length(my_predio.cells_deforest where
		(each.cult = "cacao")) * MOFcost_cacao) + (length(my_predio.cells_deforest where (each.cult = "livestock")) * MOFcost_livestock);
		available_workers <- labor_force - occupied_workers;
		if available_workers < 0 {
			do init_employed_labour;
		}

	}

	action update_needs {
		common_pot_inc <- sum(my_predio.cells_inside collect each.rev);
		income <- common_pot_inc - (employees_workers * cost_employees);
		ask my_predio {
			do crops_calc;
		}

		if (subcrops_needs > my_predio.subcrops_amount) and ($_ANFP > income * 12) { //TODO: à voir si on laisse la multiplication par 12... on pourrait faire au mois!
			needs_alert <- true;
		}

	}

	action init_employed_labour {
		if (livelihood_strategy = "SP2") or (livelihood_strategy = "SP3") {
			employees_workers <- round(((0 - available_workers) / 30) + 0.5); //rounded up to the nearest whole number because workers are indivisible
		}

		if (livelihood_strategy = "SP1.1") or (livelihood_strategy = "SP1.2") or (livelihood_strategy = "SP1.3") {
			labor_alert <- true; //TODO: mais à résoudre par la génération de csv pour l'ALG (les SP1 généreront leur landscape selon leur MOF)
		}

	}

	action LUC {
		if livelihood_strategy = "SP1.1" {
		}

		if livelihood_strategy = "SP1.2" {
		}

		if livelihood_strategy = "SP1.3" {
		}

		if livelihood_strategy = "SP2" {
		}

		if livelihood_strategy = "SP3" {
		}

	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}
