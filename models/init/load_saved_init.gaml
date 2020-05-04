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

import "../species_def.gaml"
import "init_data_import.gaml"

global {

	action init_saved_files {
		saved_predios <- file("../../includes/initGENfiles/predios.shp");
		saved_hogares <- file("../../includes/initGENfiles/hogares.shp");
		saved_personas <- file("../../includes/initGENfiles/personas.shp");
	}

	action load_saved_predios {
		write "---START OF INIT PLOTS";
		create predios from: saved_predios with:
		[name:: string(get("NAME")), clave_cata::string(get("CLAVE")), is_free::bool(get('free')), area_total::int(get("AREA_TOTAL")), area_deforest::int(get("AREA_DEF")), area_forest::int(get("AREA_F")), def_rate::float(get("DEF_RATE")), forest_rate::float(get("FOREST_R")), dist_via_auca::float(get("D_VIAAUCA")), prox_via_auca::float(get("PROX_VIAA")), indigena::int(get("INDIGENA")), LS::string(get("LS")), my_hogar::hogares(get("HOUSEHOLD")), cells_inside::list<cell>(get("CELLS_IN")), cells_deforest::list<cell>(get("CELLS_DEF")), cells_forest::list<cell>(get("CELLS_F")), cells_urban::list<cell>(get("CELLS_U")), cashcrops_amount::int(get("CASH_C")), subcrops_amount::int(get("SUB_C")), neighbors::list<predios>(get("NEIGH"))];
		ask predios {
			do map_deforestation_rate;
		}

		write "---END OF INIT PLOTS";
	}

	action load_saved_hogares {
		write "---START OF INIT HOUSEHOLDS";
		create hogares from: saved_hogares with:
		[name:: string(get("NAME")), sec_id::string(get("SEC_ID")), hog_id::string(get("HOG_ID")), Total_Personas::int(get("TOTAL_P")), Total_Hombres::int(get("TOTAL_M")), Total_Mujeres::int(get("TOTAL_F")), my_predio::predios(get("PLOT")), my_house::cell(get("HOUSE")), membres_hogar::list<personas>(get("HOG_MEMBER")), chef_hogar::personas(get("HEAD")), chef_auto_id::string(get("HEAD_AUTOI")), labor_force::float(get("LABOR_F")), gross_monthly_inc::float(get("BRUT_INC")), income::float(get("INC")), livelihood_strategy::string(get("LS")), available_workers::float(get("MOF_A")), occupied_workers::float(get("MOF_O")), employees_workers::float(get("MOF_E")), labor_alert::bool(get("MOF_W")), needs_alert::bool(get("NEEDS_W")), subcrops_needs::(float(get("SUB_NEED")))];
		write "---END OF INIT HOUSEHOLDS";
	}

	action load_saved_personas {
		write "---START OF INIT PEOPLE";
		create personas from: saved_personas with:
		[name:: string(get("NAME")), sec_id::string(get("SEC_ID")), hog_id::string(get("HOG_ID")), Total_Personas::int(get("TOTAL_P")), Total_Hombres::int(get("TOTAL_M")), Total_Mujeres::int(get("TOTAL_F")), my_predio::predios(get("PLOT")), my_house::cell(get("HOUSE")), membres_hogar::list<personas>(get("HOG_MEMBER")), chef_hogar::personas(get("HEAD")), chef_auto_id::string(get("HEAD_AUTOI")), labor_force::float(get("LABOR_F")), gross_monthly_inc::float(get("BRUT_INC")), income::float(get("INC")), livelihood_strategy::string(get("LS")), my_hogar::hogares(get("HOUSEHOLD")), Age::int(get("AGE")), mes_nac::string(get("MES_NAC")), Sexo::string(get("SEXO")), orden_en_hogar::int(get("ORDEN")), labor_value::float(get("labor_value")), inc::float(get("INC")), auto_id::string(get("AUTO_ID")), chef::bool(get("HEAD"))];
		write "---END OF INIT PEOPLE";
	}

	action load_saved_landscape {
		write "---START OF INIT ALG";
		list<string> list_farming_activities <- (["SC1.1", "SC1.2", "SC2", "SC3.1", "SC4.1", "SC4.2", "SE1.1", "SE1.2", "SE2.1", "SE2.2", "SE2.3", "SE3", "fallow"]);
		//------------------------------------------------------------------
		write "------START OF INIT ALG SP1.1";
		ask predios where (each.LS = 'SP1.1') {
			gen_population_generator AL_genSP1_1;
			AL_genSP1_1 <- AL_genSP1_1 with_generation_algo "US";
			AL_genSP1_1 <- add_census_file(AL_genSP1_1, ("../../includes/ALGv2/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_1 <- AL_genSP1_1 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_1 <- AL_genSP1_1 add_attribute ("months", int, []);
			create patches from: AL_genSP1_1 {
				if length(myself.cells_deforest where (each.is_free = true)) != 0 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						landuse <- myself.type;
						nb_months <- myself.months;
						add landuse to: land_use_hist;
						do param_activities;
						do update_yields;
					}

				}

				do die;
			}

		}

		write "------END OF INIT ALG SP1.1";
		write "------START OF INIT ALG SP1.2";
		ask predios where (each.LS = 'SP1.2') {
			gen_population_generator AL_genSP1_2;
			AL_genSP1_2 <- AL_genSP1_2 with_generation_algo "US";
			AL_genSP1_2 <- add_census_file(AL_genSP1_2, ("../../includes/ALGv2/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_2 <- AL_genSP1_2 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_2 <- AL_genSP1_2 add_attribute ("months", int, []);
			create patches from: AL_genSP1_2 {
				if type != "SE3" and type != "SE2.1" {
					if length(myself.cells_deforest where (each.is_free = true)) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
						ask pxl_cible {
							is_free <- false;
						}

						location <- pxl_cible.location;
						ask pxl_cible {
							landuse <- myself.type;
							nb_months <- myself.months;
							add landuse to: land_use_hist;
							do param_activities;
							do update_yields;
						}

					}

					do die;
				} else {
					if type = "SE3" { //chicken farming on the house pixel
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse2 <- myself.type;
								add landuse2 to: land_use_hist;
								do param_activities;
								do update_yields;
							}

						}

						do die;
					}

					if type = "SE2.1" { //chicken farming on the house pixel
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse3 <- myself.type;
								add landuse3 to: land_use_hist;
								do param_activities;
								do update_yields;
							}

						}

						do die;
					}

				}

			}

		}

		write "------END OF INIT ALG SP1.2";
		write "------START OF INIT ALG SP1.3";
		ask predios where (each.LS = 'SP1.3') {
			gen_population_generator AL_genSP1_3;
			AL_genSP1_3 <- AL_genSP1_3 with_generation_algo "US";
			AL_genSP1_3 <- add_census_file(AL_genSP1_3, ("../../includes/ALGv2/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP1_3 <- AL_genSP1_3 add_attribute ("type", string, list_farming_activities);
			AL_genSP1_3 <- AL_genSP1_3 add_attribute ("months", int, []);
			create patches from: AL_genSP1_3 {
				if type != "SE3" and type != "SE2.3" {
					if length(myself.cells_deforest where (each.is_free = true)) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
						ask pxl_cible {
							is_free <- false;
						}

						location <- pxl_cible.location;
						ask pxl_cible {
							landuse <- myself.type;
							nb_months <- myself.months;
							add landuse to: land_use_hist;
							do param_activities;
							do update_yields;
						}

					}

					do die;
				} else {
					if type = "SE3" {
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse2 <- myself.type;
								add landuse2 to: land_use_hist;
								do param_activities;
								do update_yields;
							}

						}

						do die;
					}

					if type = "SE2.3" {
						if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
							cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
							location <- pxl_cible.location;
							ask pxl_cible {
								landuse3 <- myself.type;
								add landuse3 to: land_use_hist;
								do param_activities;
								do update_yields;
							}

						}

						do die;
					}

				}

			}

		}

		write "------END OF INIT ALG SP1.2";
		write "------START OF INIT ALG SP2";
		ask predios where (each.LS = 'SP2') {
			gen_population_generator AL_genSP2;
			AL_genSP2 <- AL_genSP2 with_generation_algo "US";
			AL_genSP2 <- add_census_file(AL_genSP2, ("../../includes/ALGv2/" + name + "_ldsp.csv"), "Sample", ",", 1, 0);
			// --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP2 <- AL_genSP2 add_attribute ("type", string, list_farming_activities);
			AL_genSP2 <- AL_genSP2 add_attribute ("months", int, []);
			create patches from: AL_genSP2 {
				if type != "SE3" {
					if length(myself.cells_deforest where (each.is_free = true)) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
						ask pxl_cible {
							is_free <- false;
						}

						location <- pxl_cible.location;
						ask pxl_cible {
							landuse <- myself.type;
							nb_months <- myself.months;
							add landuse to: land_use_hist;
							do param_activities;
							do update_yields;
						}

					}

					do die;
				} else { //chicken farming on the house pixel
					if length(myself.cells_deforest where (each.landuse = "house")) != 0 {
						cell pxl_cible <- one_of(myself.cells_deforest where (each.landuse = "house"));
						location <- pxl_cible.location;
						ask pxl_cible {
							landuse2 <- myself.type;
							add landuse2 to: land_use_hist;
							do param_activities;
							do update_yields;
						}

					}

					do die;
				}

			}

		}

		write "------END OF INIT ALG SP2";
		write "------START OF INIT ALG SP3";
		ask predios where (each.LS = 'SP3') {
			gen_population_generator AL_genSP3;
			AL_genSP3 <- AL_genSP3 with_generation_algo "US";
			AL_genSP3 <- add_census_file(AL_genSP3, ("../../includes/ALGv2/" + name + "_ldsp.csv"), "Sample", ",", 1, 0); // --------------------------
			// Setup Attributs
			// --------------------------	
			AL_genSP3 <- AL_genSP3 add_attribute ("type", string, list_farming_activities);
			AL_genSP3 <- AL_genSP3 add_attribute ("months", int, []);
			create patches from: AL_genSP3 {
				if length(myself.cells_deforest where (each.is_free = true)) != 0 {
					cell pxl_cible <- one_of(myself.cells_deforest where (each.is_free = true));
					ask pxl_cible {
						is_free <- false;
					}

					location <- pxl_cible.location;
					ask pxl_cible {
						landuse <- myself.type;
						nb_months <- myself.months;
						add landuse to: land_use_hist;
						do param_activities;
						do update_yields;
					}

				}

				do die;
			}

		}

		write "------END OF INIT ALG SP3";
		write "---END OF INIT ALG";
	}

}
		


