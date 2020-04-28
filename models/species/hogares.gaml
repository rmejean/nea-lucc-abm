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
	float gross_monthly_inc;
	float income;
	string livelihood_strategy <- 'none';
	bool needs_alert;
	bool labor_alert;

	action values_calc {
		labor_force <- (sum(membres_hogar collect each.labor_value) * 30);
		available_workers <- labor_force;
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

	action init_employees {
//		occupied_workers <- (length(my_predio.cells_deforest where (each.landuse = "SC1.1")) * laborcost_SC1_1) + (length(my_predio.cells_deforest where
//		(each.landuse = "SC1.2")) * laborcost_SC1_2) + (length(my_predio.cells_deforest where (each.landuse = "SC2")) * laborcost_SC2) + (length(my_predio.cells_deforest where
//		(each.landuse = "SC3.1")) * laborcost_SC3_1) + (length(my_predio.cells_deforest where (each.landuse = "SC4.1")) * laborcost_SC4_1) + (length(my_predio.cells_deforest where
//		(each.landuse = "SC4.2")) * laborcost_SC4_2) + (length(my_predio.cells_deforest where (each.landuse = "SE1.1")) * laborcost_SE1_1) + (length(my_predio.cells_deforest where
//		(each.landuse = "SE1.2")) * laborcost_SE1_2) + (length(my_predio.cells_deforest where (each.landuse = "SE2.1")) * laborcost_SE2_1) + (length(my_predio.cells_deforest where
//		(each.landuse = "SE2.2")) * laborcost_SE2_2) + (length(my_predio.cells_deforest where (each.landuse = "SE2.3")) * laborcost_SE2_3) + (length(my_predio.cells_deforest where
//		(each.landuse = "SE3")) * laborcost_SE3);
//		available_workers <- labor_force - occupied_workers;

		if available_workers < 0 { //manage the employed labor force
			if (livelihood_strategy = "SP2") or (livelihood_strategy = "SP3") {
				employees_workers <- round(((0 - available_workers) / 30) + 0.5); //rounded up to the nearest whole number because workers are indivisible
				labor_force <- labor_force + (employees_workers * 30);
				available_workers <- labor_force - occupied_workers;
				
			}
			if (livelihood_strategy = "SP1.1") or (livelihood_strategy = "SP1.2") or (livelihood_strategy = "SP1.3"){
				labor_alert <- true;
			}

		}

	}

	action init_needs { //calculation of cash income (does not include food crops)
		if livelihood_strategy = "SP1.1" {
			gross_monthly_inc <- sum(my_predio.cells_inside where (each.landuse = "SC2") collect each.rev);
			income <- gross_monthly_inc - (employees_workers * cost_employees);
		}

		if livelihood_strategy = "SP1.2" {
			gross_monthly_inc <- sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.1" or each.landuse = "SC1.2") collect each.rev);
			income <- gross_monthly_inc - (employees_workers * cost_employees);
		}

		if livelihood_strategy = "SP1.3" {
			gross_monthly_inc <- sum(my_predio.cells_inside where (each.landuse = "SC2" or each.landuse = "SC1.2" or each.landuse = "SE1.2" or each.landuse = "SE2.3") collect each.rev);
			income <- gross_monthly_inc - (employees_workers * cost_employees);
		}

		if livelihood_strategy = "SP2" {
			gross_monthly_inc <- sum(my_predio.cells_inside collect each.rev);
			income <- gross_monthly_inc - (employees_workers * cost_employees);
		}

		if livelihood_strategy = "SP3" {
			gross_monthly_inc <- sum(my_predio.cells_inside collect each.rev);
			income <- gross_monthly_inc - (employees_workers * cost_employees);
		}

		//		if livelihood_strategy = "SP1.1" {
		//			income <- income + 50;//50-dollar voucher from the authorities
		//		}
		ask my_predio {
			do crops_calc;
		}

		if (subcrops_needs > my_predio.subcrops_amount) and ($_ANFP > income * 12) { //TODO: la multiplication par 12 sous-entend que le ménage est capable d'anticiper à l'année... à voir si je le laisse ou non
			needs_alert <- true;
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
