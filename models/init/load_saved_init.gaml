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
		saved_empresas <- file("../../includes/initGENfiles/empresas.shp");
	}

	action load_saved_cells {
		write "---START OF INIT CELLS";
		ask cell {
			switch grid_value {
				match 0.0 {
				//do die; //TODO: peut-être pas utile, ça a l'air de perturber les charts
				}

				match 1.0 {
					is_deforest <- nil;
					landuse <- 'water';
					add 'water' to: land_use_hist;
				}

				match 2.0 {
					is_deforest <- false;
					landuse <- 'forest';
					add 'forest' to: land_use_hist;
				}

				match 3.0 {
					is_deforest <- true;
				}

				match 4.0 {
					is_deforest <- nil;
					landuse <- 'urban';
					add 'urban' to: land_use_hist;
				}

			}

		}

		write "---END OF INIT CELLS";
	}

	action load_saved_empresas {
		write "---START OF INIT OIL COMPANIES";
		create empresas from: saved_empresas with: [name:: string(get("NAME")), nb_jobs::int(get("NB_JOBS")), free_jobs::int(get("FR_JOBS"))];
		write "---END OF INIT OIL COMPANIES";
	}

	action load_saved_predios {
		write "---START OF INIT PLOTS";
		create predios from: saved_predios with:
		[name:: string(get("NAME")), clave_cata::string(get("CLAVE")), is_free::bool(get('free')), area_total::int(get("AREA_TOTAL")), area_deforest::int(get("AREA_DEF")), area_forest::int(get("AREA_F")), def_rate::float(get("DEF_RATE")), forest_rate::float(get("FOREST_R")), dist_via_auca::float(get("D_VIAAUCA")), prox_via_auca::float(get("PROX_VIAA")), indigena::int(get("INDIGENA")), LS::string(get("LS"))]
		{
			ask cells_inside {
				predio <- myself;
			}

		}

		write "---END OF INIT PLOTS";
	}

	action load_saved_hogares {
		write "---START OF INIT HOUSEHOLDS";
		create hogares from: saved_hogares with:
		[name:: string(get("NAME")), sec_id::string(get("SEC_ID")), hog_id::string(get("HOG_ID")), Total_Personas::int(get("TOTAL_P")), Total_Hombres::int(get("TOTAL_M")), Total_Mujeres::int(get("TOTAL_F")), my_predio::(first(predios
		where
		(each.name = get("PLOT")))), chef_auto_id::string(get("HEAD_AUTOI")), labor_force::float(get("LABOR_F")), livelihood_strategy::string(get("LS")), available_workers::float(get("MOF_A")), occupied_workers::float(get("MOF_O")), employees_workers::float(get("MOF_E")), labor_alert::bool(get("MOF_W")), subcrops_needs::(float(get("SUB_NEED"))), oil_workers::(int(get("NB_OIL_W")))];
		ask hogares {
			my_house <- first(cell overlapping self);
			ask my_house {
				landuse <- "house";
				is_free <- false;
				is_deforest <- nil;
			}

			ask my_predio {
				my_hogar <- myself;
			}

			ask my_predio.cells_inside {
				my_hogar <- myself;
			}

		}

		write "---END OF INIT HOUSEHOLDS";
	}

	action load_saved_personas {
		write "---START OF INIT PEOPLE";
		create personas from: saved_personas with: [name:: string(get("NAME")), sec_id::string(get("SEC_ID")), hog_id::string(get("HOG_ID")), my_predio::(first(predios where
		(each.name = get("PLOT")))), my_hogar::(first(hogares where
		(each.name = get("HOUSEHOLD")))), income::float(get("INC")), Age::int(get("AGE")), mes_nac::string(get("MES_NAC")), Sexo::string(get("SEXO")), orden_en_hogar::int(get("ORDEN")), labor_value::float(get("labor_value")), inc::float(get("INC")), auto_id::string(get("AUTO_ID")), chef::bool(get("HEAD")), oil_worker::bool(get("WORK")), empresa::(first(empresas
		where
		(each.name = get("EMPRESA")))), contract_term::int(get("CONTRACT")), working_months::int(get("WORK_M")), work_pace::int(get("WORKPACE")), annual_inc::int(get("ANNUAL_INC"))] {
			my_house <- my_hogar.my_house;
			ask my_predio {
				my_hogar <- myself.my_hogar;
			}

			ask my_predio.cells_inside {
				predio <- myself.my_predio;
				my_hogar <- myself.my_hogar;
			}

			ask my_hogar {
				add myself to: membres_hogar;
				chef_hogar <- membres_hogar with_min_of each.orden_en_hogar;
				neighbors <- hogares closest_to (self, 5);
				add all: neighbors to: social_network;
			}

			if oil_worker = true {
				ask empresa {
					add myself to: workers;
				}

				co_workers_hog <- empresa.workers collect each.my_hogar;
				co_workers_hog <- remove_duplicates(co_workers_hog);
				remove all: my_hogar from: co_workers_hog;
			}

			add all: co_workers_hog to: my_hogar.social_network;
		}

		write "---END OF INIT PEOPLE";
	}

	action load_saved_landscape {
		write "---START OF INIT ALG";
		list<string> list_farming_activities <- (["SC1.1", "SC1.2", "SC2", "SC3.1", "SC4.1", "SC4.2", "SE1.1", "SE1.2", "SE2.1", "SE2.2", "SE2.3", "SE3", "fallow"]);
		//------------------------------------------------------------------
		write "------START OF INIT ALG SP1.1";
		ask predios where (each.LS = 'SP1.1') {
			create patches from: csv_file("/init/ALG/" + name + "_ldsp.csv", true) with: [type:: string(get("type")), months::int(get("months"))] {
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
					}

				}

				do die;
			}

		}

		write "------END OF INIT ALG SP1.1";
		write "------START OF INIT ALG SP1.2";
		ask predios where (each.LS = 'SP1.2') {
			create patches from: csv_file("/init/ALG/" + name + "_ldsp.csv", true) with: [type:: string(get("type")), months::int(get("months"))] {
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
			create patches from: csv_file("/init/ALG/" + name + "_ldsp.csv", true) with: [type:: string(get("type")), months::int(get("months"))] {
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
			create patches from: csv_file("/init/ALG/" + name + "_ldsp.csv", true) with: [type:: string(get("type")), months::int(get("months"))] {
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
						}

					}

					do die;
				}

			}

		}

		write "------END OF INIT ALG SP2";
		write "------START OF INIT ALG SP3";
		ask predios where (each.LS = 'SP3') {
			create patches from: csv_file("/init/ALG/" + name + "_ldsp.csv", true) with: [type:: string(get("type")), months::int(get("months"))] {
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
					}

				}

				do die;
			}

		}

		write "------END OF INIT ALG SP3";
		ask predios {
			ask cells_inside {
				do color_activities;
				do update_yields;
			}

		}

		write "---END OF INIT ALG";
	}

}