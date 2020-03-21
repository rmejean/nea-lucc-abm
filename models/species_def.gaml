/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model init_species_def
//
//
// DEFINITION OF SPECIES ATTRIBUTES & ACTIONS
//
//
import "init_data_import.gaml"
import "init_MCA_criteria.gaml"
import "model_core.gaml"
//
// DEFINITION OF CELLS
//
grid cell file: MAE_2008 use_regular_agents: true use_individual_shapes: false use_neighbors_cache: false {
	bool is_deforest <- true;
	bool is_free <- true;
	string cult;
	float rev;
	predios predio;
	hogares my_hogar;
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? rgb(35, 75, 0) : (grid_value = 3 ? #burlywood : #red));

	action param_activities {
		if cult = 'maniocmais' {
			rev <- rnd((450 / 12), (900 / 12));
			color <- #yellow;
		}

		if cult = 'fruits' {
			rev <- rnd((1500 / 12), (2500 / 12));
			color <- #orange;
		}

		if cult = 's_livestock' {
			rev <- rnd((450 / 12), (1800 / 12));
			color <- #palevioletred;
		}

		if cult = 'plantain' {
			rev <- rnd((250 / 12), (2210 / 12));
			color <- #springgreen;
		}

		if cult = 'coffee' {
			rev <- rnd((5100 / 12), (3000 / 12));
			color <- #brown;
		}

		if cult = 'cacao' {
			rev <- rnd((1100 / 12), (900 / 12));
			color <- rgb(177, 107, 94);
		}

		if cult = 'livestock' {
			rev <- rnd((1240 / 12), (1010 / 12));
			color <- rgb(112, 141, 61);
		}

		if cult = 'friche' {
			rev <- 0.0;
			color <- rgb(81, 75, 0);
		}

		if cult = 'house' {
			rev <- 0.0;
			color <- #red;
		}

	}

}
//
// DEFINITION OF ROADS
//
species vias {
	int orden;
	//
	aspect default {
		draw shape color: #black border: #black;
	}

}
//
// DEFINITION OF PLOTS
//
species predios {
	string clave_cata;
	bool is_free <- true;
	bool is_free_MCA <- false;
	int id_EMC_LS1_1 <- 0;
	int id_EMC_LS1_2 <- 0;
	int id_EMC_LS1_3 <- 0;
	int id_EMC_LS2 <- 0;
	int id_EMC_LS3 <- 0;
	int area_total <- length(cells_inside);
	int area_deforest <- length(cells_deforest);
	int area_forest <- length(cells_forest);
	float def_rate;
	float forest_rate;
	float dist_via_auca <- distance_to(self, vias where (each.orden = 1) closest_to self); //distance to via Auca (main road on the study area, original settlement and and location of oil companies)
	float prox_via_auca <- 20000 - (self.dist_via_auca);
	int indigena; //indigenous index
	string LS; //livelihood strategy
	rgb color;
	rgb color_tx_def;
	rgb LS_color;
	rgb LUC_color;
	hogares my_hogar;
	int subcrops_amount;
	int cashcrops_amount;
	list<cell> cells_inside -> {cell overlapping self}; //trouver mieux que overlapping ?
	list<cell> cells_deforest -> cells_inside where (each.grid_value = 3);
	list<cell> cells_forest -> cells_inside where (each.grid_value = 2);
	list<int> rankings_LS_EMC <- ([]);

	action deforestation_rate_calc {
		if area_total > 0 {
			def_rate <- (area_deforest / area_total) * 100;
			forest_rate <- (area_forest / area_total) * 100;
		} else {
			def_rate <- 0.0;
		}

	}

	action crops_calc {
		subcrops_amount <- (length(cells_deforest where (each.cult = "maniocmais" or "fruits" or "s_livestock" or "plantain")));
		cashcrops_amount <- (length(cells_deforest where (each.cult = "cacao" or "coffee" or "livestock")));
	}

	action update_needs {
		do crops_calc;
		if my_hogar != nil {
			ask my_hogar {
				do assess_food_needs;
			}
		}

	}

	action map_deforestation_rate {
		color_tx_def <- def_rate = 0 ? #white : (between(def_rate, 10, 25) ? rgb(253, 204, 138) : (between(def_rate, 25, 50) ? rgb(253, 204, 138) : (between(def_rate, 50, 75) ?
		rgb(252, 141, 89) : rgb(215, 48, 31))));
	}

	action map_livelihood_strategies {
		LS_color <- my_hogar.livelihood_strategy = 'SP3' ? #pink : (my_hogar.livelihood_strategy = 'SP2' ? #green : (my_hogar.livelihood_strategy = 'SP1.1' ?
		#red : (my_hogar.livelihood_strategy = 'SP1.2' ? #blue : #yellow)));
	}

	action map_eminent_LUC {
		LUC_color <- my_hogar.LUC = true ? #green : #red;
	}

	aspect default {
		draw shape color: #transparent border: #black;
	}

	aspect map_def_rate {
		draw shape color: color_tx_def border: #black;
	}

	aspect map_LS {
		draw shape color: LS_color border: #black;
	}

	aspect map_LUC_decisions {
		draw shape color: LUC_color border: #black;
	}

}
//
// DEFINITION OF COMUNAS (community plots)
//
species comunas {
	int area_total;
	int area_deforest;
	float ratio_deforest;

	aspect default {
		draw shape color: #black border: #black;
	}

}
//
// DEFINITION OF HOUSEHOLDS
//
species hogares {
	string sec_id;
	string hog_id;
	string viv_id;
	int Total_Personas;
	int Total_Hombres;
	int Total_Mujeres;
	predios my_predio;
	list<personas> membres_hogar;
	personas chef_hogar;
	string chef_auto_id;
	float MOF;
	float subcrops_needs;
	float common_pot_inc;
	string livelihood_strategy;
	bool LUC <- false;

	action values_calc {
		MOF <- (sum(membres_hogar collect each.vMOF) * 30);
		subcrops_needs <- (sum(membres_hogar collect each.food_needs));
	}

	action setup_hogar {
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

		do values_calc;
	}

	action assess_food_needs {
		if (subcrops_needs > my_predio.subcrops_amount) or ($_ANFP > common_pot_inc * 12) {
			LUC <- true;
		}

	}

	aspect default {
		draw circle(15) color: #red border: #black;
	}

}
//
// DEFINITION OF PEOPLE
//
species personas parent: hogares {
	hogares my_hogar;
	int Age;
	string mes_nac;
	string Sexo;
	int orden_en_hogar;
	float vMOF;
	float food_needs;
	float inc;
	string auto_id;
	bool chef;

	action values_calc {
		if Age < 11 {
			vMOF <- 0.0;
		}

		if Age = 11 {
			vMOF <- 0.16;
		}

		if Age = 12 {
			vMOF <- 0.33;
		}

		if Age = 13 {
			vMOF <- 0.5;
		}

		if Age = 14 {
			vMOF <- 0.66;
		}

		if Age = 15 {
			vMOF <- 0.83;
		}

		if Age >= 16 {
			vMOF <- 1.0;
		}

		food_needs <- 0.5;
	}

	action aging {
		if current_month = self.mes_nac { //when it's my birthday!
			Age <- Age + 1;
			do values_calc;
			//MORT
			if between(Age, 70, 80) {
				if flip(0.1) {
					remove self from: my_hogar.membres_hogar;
					ask my_hogar {
						do values_calc;
					}

					do die;
				}

			}

			if Age > 80 {
				if flip(0.33) {
					remove self from: my_hogar.membres_hogar;
					ask my_hogar {
						do values_calc;
					}

					do die;
				}

			}

		}

	}

	aspect default {
		draw circle(6) color: #blue border: #black;
	}

}
//
// DEFINITION OF LS AGENTS
//
species LS_agents {
	string code_LS;
	list<list> predios_eval {
		list<list> candidates;
		loop parcel over: (predios where (each.is_free_MCA = true)) { // ne mettre que les predios où il y a des ménages
			list<float> cand;
			add parcel.def_rate to: cand;
			add parcel.forest_rate to: cand;
			add parcel.indigena to: cand;
			add parcel.dist_via_auca to: cand;
			add parcel.prox_via_auca to: cand;
			add cand to: candidates;
		}

		return candidates;
	}
	//MULTICRITERIA ANALYSIS TO RANK LS
	action ranking_MCA {
		if code_LS = '1.1' {
			write "------START OF RANKING FOR LS 1.1";
			loop while: (length(predios where (each.is_free_MCA = true)) > 0) {
				list<list> cands <- predios_eval();
				int choice <- weighted_means_DM(cands, criteria_WM_SP1_1);
				if choice >= 0 {
					ask predios where (each.is_free_MCA = true) at choice {
						self.id_EMC_LS1_1 <- predios max_of (each.id_EMC_LS1_1) + 1;
						add self.id_EMC_LS1_1 to: self.rankings_LS_EMC;
						is_free_MCA <- false;
						write "---------Ranking of a plot for the LS 1.1";
					}

				}

			}

			ask hogares {
				ask my_predio {
					is_free_MCA <- true;
				}

			}

		}

		if code_LS = '1.2' {
			write "------START OF RANKING FOR LS 1.2";
			loop while: (length(predios where (each.is_free_MCA = true)) > 0) {
				list<list> cands <- predios_eval();
				int choice <- weighted_means_DM(cands, criteria_WM_SP1_2);
				if choice >= 0 {
					ask predios where (each.is_free_MCA = true) at choice {
						self.id_EMC_LS1_2 <- predios max_of (each.id_EMC_LS1_2) + 1;
						add self.id_EMC_LS1_2 to: self.rankings_LS_EMC;
						is_free_MCA <- false;
						write "---------Ranking of a plot for the LS 1.2";
					}

				}

			}

			ask hogares {
				ask my_predio {
					is_free_MCA <- true;
				}

			}

		}

		if code_LS = '1.3' {
			write "------START OF RANKING FOR LS 1.3";
			loop while: (length(predios where (each.is_free_MCA = true)) > 0) {
				list<list> cands <- predios_eval();
				int choice <- weighted_means_DM(cands, criteria_WM_SP1_3);
				if choice >= 0 {
					ask predios where (each.is_free_MCA = true) at choice {
						self.id_EMC_LS1_3 <- predios max_of (each.id_EMC_LS1_3) + 1;
						add self.id_EMC_LS1_3 to: self.rankings_LS_EMC;
						is_free_MCA <- false;
						write "---------Ranking of a plot for the LS 1.3";
					}

				}

			}

			ask hogares {
				ask my_predio {
					is_free_MCA <- true;
				}

			}

		}

		if code_LS = '2' {
			write "------START OF RANKING FOR LS 2";
			loop while: (length(predios where (each.is_free_MCA = true)) > 0) {
				list<list> cands <- predios_eval();
				int choice <- weighted_means_DM(cands, criteria_WM_SP2);
				if choice >= 0 {
					ask predios where (each.is_free_MCA = true) at choice {
						self.id_EMC_LS2 <- predios max_of (each.id_EMC_LS2) + 1;
						add self.id_EMC_LS2 to: self.rankings_LS_EMC;
						is_free_MCA <- false;
						write "---------Ranking of a plot for the LS 2";
					}

				}

			}

			ask hogares {
				ask my_predio {
					is_free_MCA <- true;
				}

			}

		}

		if code_LS = '3' {
			write "------START OF RANKING FOR LS 3";
			loop while: (length(predios where (each.is_free_MCA = true)) > 0) {
				list<list> cands <- predios_eval();
				int choice <- weighted_means_DM(cands, criteria_WM_SP3);
				if choice >= 0 {
					ask predios where (each.is_free_MCA = true) at choice {
						self.id_EMC_LS3 <- predios max_of (each.id_EMC_LS3) + 1;
						add self.id_EMC_LS3 to: self.rankings_LS_EMC;
						is_free_MCA <- false;
						write "---------Ranking of a plot for the LS 3";
					}

				}

			}

		}

		ask hogares {
			ask my_predio {
				is_free_MCA <- true;
			}

		}

	}

	action apply_MCA {
		ask predios {
			if index_of((self.rankings_LS_EMC), (min(self.rankings_LS_EMC))) = 0 {
				self.LS <- "SP1.1";
				my_hogar.livelihood_strategy <- "SP1.1";
				write "---------LS 1.1 assigned to a plot.";
			}

			if index_of((self.rankings_LS_EMC), (min(self.rankings_LS_EMC))) = 1 {
				self.LS <- "SP1.2";
				my_hogar.livelihood_strategy <- "SP1.2";
				write "---------LS 1.2 assigned to a plot.";
			}

			if index_of((self.rankings_LS_EMC), (min(self.rankings_LS_EMC))) = 2 {
				self.LS <- "SP1.3";
				my_hogar.livelihood_strategy <- "SP1.3";
				write "---------LS 1.3 assigned to a plot.";
			}

			if index_of((self.rankings_LS_EMC), (min(self.rankings_LS_EMC))) = 3 {
				self.LS <- "SP2";
				my_hogar.livelihood_strategy <- "SP2";
				write "---------LS 2 assigned to a plot.";
			}

			if index_of((self.rankings_LS_EMC), (min(self.rankings_LS_EMC))) = 4 {
				self.LS <- "SP3";
				my_hogar.livelihood_strategy <- "SP3";
				write "---------LS 3 assigned to a plot.";
			}

		}

	}

}
//
// DEFINITION OF PATCHES FOR INIT
//
species patches {
	string type;
	predios my_predio;
	string id;
}
//
// DEFINITION OF SECTORES
//
species sectores {
	string dpa_secdis;
	list<hogares> hogares_inside;
	list<personas> personas_inside;
	int nb_hogares;
	int nb_personas;
	rgb color <- rnd_color(255);

	action carto_pop { //A TRANSFORMER EN REFLEX POUR LES SECTORES ?
		hogares_inside <- hogares inside self;
		personas_inside <- personas inside self;
		nb_hogares <- length(hogares_inside);
		nb_personas <- length(personas_inside);
	}

	aspect default {
		draw shape color: #transparent border: #black;
	}

}
