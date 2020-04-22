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
	float costmaint_cattle <- 11.9; //TODO: à revoir : plus il y a d'hectares en pâture, plus c'est cher
	float buy_pig <- 13.33;
	float costmaint_pigbreeding <- 5.375;
	float costmaint_pigbreeding2 <- 21.1;

	//	float yld_cacaoA;
	//	float yld_cacaoB;
	//	float yld_coffee;
	//	float yld_manioc1;
	//  float yld_manioc2;
	//  float yld_manioc3;
	//  float yld_manioc4;
	//	float yld_plantain1;
	//	float yld_plantain2;
	//	float yld_tubercules;
	//	float yld_papayes;
	//	float yld_ananas;
	//	float yld_mais;

}

grid cell file: MAE_2008 use_regular_agents: false use_individual_shapes: false use_neighbors_cache: false {
	bool is_deforest <- true;
	bool is_free <- true;
	string landuse;
	list<string> land_use_hist; //history: pasts land uses
	int nb_months;
	float rev;
	float yld; //yield
	predios predio;
	hogares my_hogar;
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? rgb(35, 75, 0) : (grid_value = 3 ? #burlywood : #red));

	action param_activities {
		if landuse = 'SC1.1' {
			nb_months <- rnd(0, 24);
			color <- #brown;
		}

		if landuse = 'SC1.2' {
			color <- #brown;
		}

		if landuse = 'SC2' {
			color <- rgb(149, 110, 110);
		}

		if landuse = 'SC3.1' {
			nb_months <- rnd(0, 17);
			color <- #springgreen;
		}

		if landuse = 'SC4.1' {
			color <- rgb(149, 110, 110);
		}

		if landuse = 'SC4.2' {
			color <- #yellow;
		}

		if landuse = 'SE1.1' {
			color <- rgb(112, 141, 61);
		}

		if landuse = 'SE1.2' {
			color <- rgb(81, 75, 0);
		}

		if landuse = 'SE2.1' {
			color <- rgb(81, 75, 0);
		}

		if landuse = 'SE2.2' {
			color <- rgb(81, 75, 0);
		}

		if landuse = 'SE2.3' {
			color <- rgb(81, 75, 0);
		}

		if landuse = 'SE3' {
			rev <- 0.0;
			color <- #red;
		}

		if landuse = 'fallow' {
			nb_months <- rnd(1, 360); //fallow: maximum 30 years?
			color <- rgb(81, 75, 0);
		}

	}

	action update_yields {
		if landuse = 'SC1.1' { //cocoa in production with inputs
			let yld_cacao <- 0.66;
			rev <- (yld_cacao * price_cacao) - costmaint_cacaoinputs;
		}

		if landuse = 'SC1.2' { //cocoa in production without inputs
			let yld_cacao <- 0.16;
			rev <- (yld_cacao * price_cacao);
		}

		if landuse = 'SC2' { //coffee plants in production
			let yld_coffee <- 2.08;
			rev <- (yld_coffee * price_coffee);
		}

		if landuse = 'SC3.1' { //food crops for self-consumption in complex combination with long fallow land
			if nb_months <= 12 {
				let yld_manioc <- 10.0;
				let yld_plantain <- 33.33;
				let yld_tubercules <- 7.25;
				let yld_papayes <- 25.0;
				let yld_ananas <- 5.0;
				rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain) + (yld_tubercules * price_tubercules) + (yld_papayes * price_papayes) + (yld_ananas * price_ananas);
			}

			if nb_months > 12 {
				let yld_manioc <- 7.5;
				let yld_plantain <- 29.16;
				let yld_tubercules <- 7.25;
				let yld_papayes <- 25.0;
				let yld_ananas <- 5.0;
				rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain) + (yld_tubercules * price_tubercules) + (yld_papayes * price_papayes) + (yld_ananas * price_ananas);
			}

		}

		if landuse = 'SC4.1' { //food crops for self-consumption in simple association and short-term fallow land
			if nb_months <= 12 {
				let yld_manioc <- 3.33;
				let yld_plantain <- 29.16;
				rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain);
			}

			if nb_months > 12 {
				let yld_manioc <- 1.66;
				let yld_plantain <- 29.16;
				rev <- (yld_manioc * price_manioc) + (yld_plantain * price_plantain);
			}

		}

		if landuse = 'SC4.2' { //food crops for self-consumption in simple plantain/corn and short-term fallow land combinations
			let yld_mais <- 0.33;
			let yld_plantain <- 33.33;
			rev <- (yld_mais * price_mais) + (yld_plantain * price_plantain);
		}

		if landuse = 'SE1.1' { // cattle breeding with cheese marketing (30 mothers and 70ha of pastures)
			let yld_veaux <- 0.079875;
			let yld_vachereforme <- 0.027;
			let yld_cheese <- 11.43;
			rev <- (yld_veaux * price_veaux) + (yld_vachereforme * price_vachereforme) + (yld_cheese * price_cheese) - costmaint_cattle;
		}

		if landuse = 'SE1.2' { // cattle breeding with cheese marketing (30 mothers and 70ha of pastures)
			let yld_veaux <- 0.040;
			let yld_vachereforme <- 0.022;
			let yld_cheese <- 1.2;
			rev <- (yld_veaux * price_veaux) + (yld_vachereforme * price_vachereforme) + (yld_cheese * price_cheese) - costmaint_cattle;
		}

		if landuse = 'SE2.1' {
			let yld_pig <- 0.16;
			rev <- (yld_pig * price_pig) - buy_pig;
		}

		if landuse = 'SE2.2' {
			let yld_porcelets <- 1.11;
			let yld_truie <- 0.041;
			rev <- (yld_porcelets * price_porcelet) + (yld_truie * price_truie) - costmaint_pigbreeding;
		}

		if landuse = 'SE2.3' {
			let yld_porcelets <- 0.8;
			let yld_pig <- 0.316;
			let yld_truie <- 0.041;
			rev <- (yld_porcelets * price_porcelet) + (yld_truie * price_truie) + (yld_pig * price_pig) - costmaint_pigbreeding2;
		}

		if landuse = 'SE3' {
			let yld_oldchicken <- 0.41;
			let yld_chicken <- 5.83;
			let yld_eggs <- 93.33;
			rev <- (yld_oldchicken * price_oldchicken) + (yld_chicken * price_chicken) + (yld_eggs * price_eggs);
		}

	}

	action crop_cycle {
		nb_months <- nb_months + 1;
		
		if landuse = 'maniocmais' and nb_months = 24 {
			landuse <- 'fallow';
			add landuse to: land_use_hist;
			rev <- 0.0;
			color <- rgb(81, 75, 0);
			//TODO: sow_maniocmais;
		}

		if landuse = 'plantain' and nb_months = 17 {
			landuse <- 'fallow';
			add landuse to: land_use_hist;
			rev <- 0.0;
			color <- rgb(81, 75, 0);
		}

	}

	aspect land_use {
		draw square(1) color: color;
	}

}