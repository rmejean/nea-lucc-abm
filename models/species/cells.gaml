/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model cells_def
//
//
// DEFINITION OF CELLS
//
//
import "../species_def.gaml"

global {
	int timeprod_maniocmais <- 6;
	int timeprod_fruits <- 3;
	int timeprod_s_livetock <- 3;
	int timeprod_plantain <- 9;
	int timeprod_coffee <- 24;
	int timeprod_cacao <- 24;
	int timeprod_livestock <- 24;
	int price_cacao <- 100;
	int price_coffee <- 14;
	int price_manioc <- 15;
	int price_plantain <- 3;
	int price_tubercules <- 10;
	int price_papayes <- 1;
	int price_ananas <- 1;
	int price_mais <- 18;
	int price_veaux <- 150;
	int price_vachereforme <- 130;
	float price_cheese <- 2.5;
	int price_pig <- 250;
	int price_porcelet <- 80;
	int price_truie <- 2;
	int price_oldchicken <- 17;
	int price_chicken <- 15;
	float price_eggs <- 0.25;
	float costmaint_cacaoinputs <- 13.375;
	float costmaint_cattle_1 <- 11.48; //TODO: à revoir : plus il y a d'hectares en pâture, plus c'est cher
	float costmaint_cattle_2 <- 1.61635;
	float buy_pig <- 12.27;
	float costmaint_pigbreeding <- 5.375;
	float costmaint_pigbreeding2 <- 21.1;
	float yld_cacao;
	float yld_coffee;
	float yld_manioc;
	float yld_plantain;
	float yld_tubercules;
	float yld_papayes;
	float yld_ananas;
	float yld_mais;
	float yld_veaux;
	float yld_vachereforme;
	float yld_cheese;
	float yld_pig;
	float yld_porcelets;
	float yld_truie;
	float yld_oldchicken;
	float yld_chicken;
	float yld_eggs;
}

grid cell file: MAE_2008 use_regular_agents: false use_individual_shapes: false use_neighbors_cache: false {
	bool is_deforest <- true;
	bool is_free <- true;
	string landuse;
	string landuse2;
	string landuse3;
	list<string> land_use_hist; //history: pasts land uses
	int nb_months;
	float rev;
	float yld; //yield
	predios predio;
	hogares my_hogar;
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? rgb(35, 75, 0) : (grid_value = 3 ? #burlywood : #red));

	action param_activities {
		switch landuse {
			match 'SC1.1' {
				color <- rgb(96, 30, 29);
			}

			match 'SC1.2' {
				color <- rgb(103, 7, 4);
			}

			match 'SC2' {
				color <- rgb(164, 113, 88);
			}

			match 'SC3.1' {
				color <- rgb(206, 211, 62);
			}

			match 'SC4.1' {
				color <- rgb(49, 219, 103);
			}

			match 'SC4.2' {
				color <- rgb(255, 252, 23);
			}

			match 'SE1.1' {
				color <- rgb(113, 173, 44);
			}

			match 'SE1.2' {
				color <- rgb(140, 181, 82);
			}

			match 'SE2.1' {
				color <- rgb(96, 30, 29);
			}

			match 'SE2.2' {
				color <- rgb(96, 30, 29);
			}

			match 'SE2.3' {
				color <- rgb(96, 30, 29);
			}

			match 'SE3' {
				color <- rgb(96, 30, 29);
			}

			match 'fallow' {
				color <- rgb(206, 161, 93);
			}

			match 'house' {
				color <- #red;
			}

		}

		if is_deforest = false {
			color <- rgb(35, 75, 0);
		}

	}

	action update_yields {
		if landuse = 'SC1.1' {
			do yld_SC1_1;
		}

		if landuse = 'SC1.2' {
			do yld_SC1_2;
		}

		if landuse = 'SC2' {
			do yld_SC2;
		}

		if landuse = 'SC3.1' {
			do yld_SC3_1;
		}

		if landuse = 'SC4.1' {
			do yld_SC4_1;
		}

		if landuse = 'SC4.2' {
			do yld_SC4_2;
		}

		if landuse = 'SE1.1' or landuse2 = 'SE1.1' or landuse3 = 'SE1.1' {
			do yld_SE1_1;
		}

		if landuse = 'SE1.2' or landuse2 = 'SE1.2' or landuse3 = 'SE1.2' {
			do yld_SE1_2;
		}

		if landuse = 'SE2.1' or landuse2 = 'SE2.1' or landuse3 = 'SE2.1'  {
			do yld_SE2_1;
		}

		if landuse = 'SE2.2' or landuse2 = 'SE2.2' or landuse3 = 'SE2.2' {
			do yld_SE2_2;
		}

		if landuse = 'SE2.3' or landuse2 = 'SE2.3' or landuse3 = 'SE2.3' {
			do yld_SE2_3;
		}

		if landuse = 'SE3' or landuse2 = 'SE3' or landuse3 = 'SE3' {
			do yld_SE3;
		}

	}

	action yld_SC1_1 { //cocoa in production with inputs
		yld_cacao <- 0.66;
		rev <- (yld_cacao * price_cacao) - costmaint_cacaoinputs;
	}

	action yld_SC1_2 { //cocoa in production without inputs
		yld_cacao <- 0.16;
		rev <- (yld_cacao * price_cacao);
	}

	action yld_SC2 { //coffee plants in production
		yld_coffee <- 2.08;
		rev <- (yld_coffee * price_coffee);
	}

	action yld_SC3_1 { //food crops for self-consumption in complex combination with long fallow land
		if nb_months < 6 {
			yld_manioc <- 0.0;
			yld_plantain <- 0.0;
			yld_tubercules <- 0.0;
			yld_papayes <- 0.0;
			yld_ananas <- 0.0;
			rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain) + (yld_tubercules * price_tubercules) + (yld_papayes * price_papayes) + (yld_ananas * price_ananas);
		}

		if nb_months <= 18 {
			yld_manioc <- 10.0;
			yld_plantain <- 33.33;
			yld_tubercules <- 7.25;
			yld_papayes <- 25.0;
			yld_ananas <- 5.0;
			rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain) + (yld_tubercules * price_tubercules) + (yld_papayes * price_papayes) + (yld_ananas * price_ananas);
		}

		if nb_months > 18 {
			yld_manioc <- 7.5;
			yld_plantain <- 29.16;
			yld_tubercules <- 7.25;
			yld_papayes <- 25.0;
			yld_ananas <- 5.0;
			rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain) + (yld_tubercules * price_tubercules) + (yld_papayes * price_papayes) + (yld_ananas * price_ananas);
		}

	}

	action yld_SC4_1 { //food crops for self-consumption in simple association and short-term fallow land
		if nb_months < 6 {
			yld_manioc <- 0.0;
			yld_plantain <- 0.0;
			rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain);
		}

		if nb_months <= 18 {
			yld_manioc <- 3.0;
			yld_plantain <- 26.25;
			rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain);
		}

		if nb_months > 18 {
			yld_manioc <- 1.5;
			yld_plantain <- 26.25;
			rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain);
		}

	}

	action yld_SC4_2 { //food crops for self-consumption in simple plantain/corn and short-term fallow land combinations
		if nb_months < 6 {
			yld_mais <- 0.0;
			yld_plantain <- 0.0;
			rev <- (yld_mais * price_mais) + (yld_plantain * price_plantain);
		} else {
			yld_mais <- 0.3;
			yld_plantain <- 30.0;
			rev <- (yld_mais * price_mais) + (yld_plantain * price_plantain);
		}

	}

	action yld_SE1_1 { // cattle breeding with cheese marketing (30 mothers and 70ha of pastures)
		yld_veaux <- 0.079875;
		yld_vachereforme <- 0.027;
		yld_cheese <- 11.43;
		rev <- (yld_veaux * price_veaux) + (yld_vachereforme * price_vachereforme) + (yld_cheese * price_cheese) - costmaint_cattle_1;
	}

	action yld_SE1_2 { // cattle breeding with cheese marketing (30 mothers and 70ha of pastures)
		yld_veaux <- 0.040;
		yld_vachereforme <- 0.022;
		yld_cheese <- 1.2;
		rev <- (yld_veaux * price_veaux) + (yld_vachereforme * price_vachereforme) + (yld_cheese * price_cheese) - costmaint_cattle_2;
	}

	action yld_SE2_1 {
		yld_pig <- 0.375;
		rev <- (yld_pig * price_pig) - buy_pig;
	}

	action yld_SE2_2 {
		yld_porcelets <- 1.116;
		yld_truie <- 0.041;
		rev <- (yld_porcelets * price_porcelet) + (yld_truie * price_truie) - costmaint_pigbreeding;
	}

	action yld_SE2_3 {
		yld_porcelets <- 0.8;
		yld_pig <- 0.316;
		yld_truie <- 0.041;
		rev <- (yld_porcelets * price_porcelet) + (yld_truie * price_truie) + (yld_pig * price_pig) - costmaint_pigbreeding2;
	}

	action yld_SE3 {
		yld_oldchicken <- 0.41;
		yld_chicken <- 5.83;
		yld_eggs <- 93.33;
		rev <- (yld_oldchicken * price_oldchicken) + (yld_chicken * price_chicken) + (yld_eggs * price_eggs);
	}

	action crop_cycle {
		nb_months <- nb_months + 1;
		do reforestation;
		do fallow_and_resow;
		do param_activities;
	}

	action fallow_and_resow {
		if (landuse = 'SC3.1' or 'SC4.1' or 'SC4.2') and (nb_months >= 24) {
			write "fallow & resow!";
			let previous_landuse <- landuse;
			landuse <- 'fallow';
			nb_months <- 0;
			add landuse to: land_use_hist;
			rev <- 0.0;
			switch previous_landuse {
				match 'SC3.1' {
					if one_matches(predio.cells_inside, each.is_deforest = false) {
						ask one_of(predio.cells_inside where (each.is_deforest = false)) {
							is_deforest <- true;
							landuse <- previous_landuse;
							write "deforest to resow at " + location;
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						write "" + my_hogar.name + " cannot re-sow SC3.1";
					}

				}

				match 'SC4.1' {
					if one_matches(predio.cells_inside, each.landuse = 'fallow' and each.nb_months >= 60) {
						ask one_of(predio.cells_inside where (each.landuse = 'fallow' and each.nb_months >= 60)) {
							landuse <- previous_landuse;
							write "resow at " + location;
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if one_matches(predio.cells_inside, each.is_deforest = false) {
							ask one_of(predio.cells_inside where (each.is_deforest = false)) {
								is_deforest <- true;
								landuse <- previous_landuse;
								write "deforest to resow at " + location;
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						} else {
							write "" + my_hogar.name + " cannot re-sow SC4.1";
						}

					}

				}

				match 'SC4.2' {
					if one_matches(predio.cells_inside, each.landuse = 'fallow' and each.nb_months >= 60) {
						ask one_of(predio.cells_inside where (each.landuse = 'fallow' and each.nb_months >= 60)) {
							landuse <- previous_landuse;
							write "resow at " + location;
							nb_months <- 0;
							add landuse to: land_use_hist;
						}

					} else {
						if one_matches(predio.cells_inside, each.is_deforest = false) {
							ask one_of(predio.cells_inside where (each.is_deforest = false)) {
								is_deforest <- true;
								landuse <- previous_landuse;
								write "deforest to resow at " + location;
								nb_months <- 0;
								add landuse to: land_use_hist;
							}

						} else {
							write "" + my_hogar.name + " cannot re-sow SC4.2";
						}

					}

				}

			}

		}

	}

	action reforestation {
		if (landuse = 'fallow') and (nb_months >= 120) {
			write "reforestation at " + location;
			is_deforest <- false;
			landuse <- nil;
			nb_months <- nil;
		}

	}

	aspect land_use {
		draw square(1) color: color;
	}

}