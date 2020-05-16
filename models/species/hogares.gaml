/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/ model hogares_def //
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
	float gross_monthly_inc;
	float income;
	float estimated_annual_inc;
	string livelihood_strategy <- 'none';
	bool needs_alert;
	bool labor_alert;
	int oil_workers <- 0;

	action init_values {
		labor_force <- (sum(membres_hogar collect each.labor_value) * 30);
		available_workers <- labor_force;
		subcrops_needs <- (sum(membres_hogar collect each.food_needs));
	}

	//action update_values {
	//labor_force <- (sum(membres_hogar collect each.labor_value) * 30) + (employees_workers * 30) - (oil_workers * 14.0);
	//}

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

	action LUC {
		switch livelihood_strategy {
			match "SP1.1" {
			}

			match "SP1.2" {
			}

			match "SP1.3" {
			}

			match "SP2" {
			}

			match "SP3" {
			}

		}

	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}
