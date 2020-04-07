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
	
}

grid cell file: MAE_2008 use_regular_agents: false use_individual_shapes: false use_neighbors_cache: false {
	bool is_deforest <- true;
	bool is_free <- true;
	string cult;
	list<string> land_use_hist;//history: pasts land uses
	int nb_months;
	float rev;
	predios predio;
	hogares my_hogar;
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? rgb(35, 75, 0) : (grid_value = 3 ? #burlywood : #red));

	action param_activities {
		if cult = 'SC1.1' {
			nb_months <- rnd (0,24);
			color <- #yellow;
		}

		if cult = 'SC1.2' {
			color <- #orange;
		}

		if cult = 'SC2' {
			color <- #palevioletred;
		}

		if cult = 'SC3' {
			nb_months <- rnd (0,17);
			color <- #springgreen;
		}

		if cult = 'SC4.1' {
			color <- #brown;
		}

		if cult = 'SC4.2' {
			color <- rgb(177, 107, 94);
		}

		if cult = 'SE1.1' {
			color <- rgb(112, 141, 61);
		}

		if cult = 'SE1.2' {
			nb_months <- rnd(1,360);//fallow: maximum 30 years?
			color <- rgb(81, 75, 0);
		}
		
		if cult = 'SE2.1' {
			nb_months <- rnd(1,360);//fallow: maximum 30 years?
			color <- rgb(81, 75, 0);
		}
		
		if cult = 'SE2.2' {
			nb_months <- rnd(1,360);//fallow: maximum 30 years?
			color <- rgb(81, 75, 0);
		}
		
		if cult = 'SE2.3' {
			nb_months <- rnd(1,360);//fallow: maximum 30 years?
			color <- rgb(81, 75, 0);
		}

		if cult = 'SE3' {
			rev <- 0.0;
			color <- #red;
		}

	}
	
	action update_yields {
		if cult = 'maniocmais' and nb_months > timeprod_maniocmais {
			rev <- rnd((405 / 12), (810 / 12));
		}

		if cult = 'fruits' {
			rev <- rnd((1350 / 12), (2250 / 12));
		}

		if cult = 's_livestock' {
			rev <- rnd((405 / 12), (1620 / 12));
		}

		if cult = 'plantain' and nb_months > timeprod_plantain {
			rev <- rnd((225 / 12), (1989 / 12));
		}

		if cult = 'coffee' {
			rev <- rnd((4590 / 12), (2700 / 12));
		}

		if cult = 'cacao' {
			rev <- rnd((990 / 12), (810 / 12));
		}

		if cult = 'livestock' {
			rev <- rnd((1116 / 12), (909 / 12));
		}

	}
	
	action crop_cycle {
		if (cult = 'maniocmais') or (cult = 'plantain') or (cult ='friche') {
			nb_months <- nb_months + 1;
		}
		if cult = 'maniocmais' and nb_months = 24 {
			cult <- 'friche';
			add cult to: land_use_hist;
			rev <- 0.0;
			color <- rgb(81, 75, 0);
			//TODO: sow_maniocmais;
		}
		if cult = 'plantain' and nb_months = 17 {
			cult  <- 'friche';
			add cult to: land_use_hist;
			rev <- 0.0;
			color <- rgb(81, 75, 0);
		}
	}
	

	aspect land_use {
		draw square(1) color: color;
	}

}