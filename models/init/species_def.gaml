model species_def
//
//
// DEFINITION OF SPECIES ATTRIBUTES & ACTIONS
//
//
import "data_import.gaml"
import "MCA_criteria.gaml"
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
	rgb color <- grid_value = 1 ? #blue : (grid_value = 2 ? rgb(35,75,0) : (grid_value = 3 ? #burlywood : #red));

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
			color <- rgb(177,107,94);
		}

		if cult = 'livestock' {
			rev <- rnd((1240 / 12), (1010 / 12));
			color <- rgb(112, 141, 61);
		}

		if cult = 'friche' {
			rev <- 0.0;
			color <- rgb(81,75,0);
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
 	int indigena; //indigenous index
	string LS; //livelihood strategy
	rgb color;
	rgb color_tx_def;
	rgb LS_color;
	hogares my_hogar;
	list<cell> cells_inside -> {cell overlapping self}; //trouver mieux que overlapping ?
 	list<cell> cells_deforest -> cells_inside where (each.grid_value = 3);
 	list<cell> cells_forest -> cells_inside where (each.grid_value = 2);
	list<int> rankings_LS_EMC <- ([]);

	action calcul_tx_deforest {
		if area_total > 0 {
			def_rate <- (area_deforest / area_total) * 100;
			forest_rate <- (area_forest / area_total) * 100;
		} else {
			def_rate <- 0.0;
		}

	}

	action carto_tx_deforest {
		color_tx_def <- def_rate = 0 ? #white : (between(def_rate, 10, 25) ? rgb(253, 204, 138) : (between(def_rate, 25, 50) ?
		rgb(253, 204, 138) : (between(def_rate, 50, 75) ? rgb(252, 141, 89) : rgb(215, 48, 31))));
	}

	action carto_LS {
		LS_color <- my_hogar.livelihood_strategy = 'SP3' ? #lightseagreen : (my_hogar.livelihood_strategy = 'SP2' ? #paleturquoise : (my_hogar.livelihood_strategy = 'SP1.1' ?
		#greenyellow : (my_hogar.livelihood_strategy = 'SP1.2' ? #tan : #rosybrown)));
	}

	aspect default {
		draw shape color: #transparent border: #black;
	}

	aspect carto_tx_def {
		draw shape color: color_tx_def border: #black;
	}

	aspect carto_LS {
		draw shape color: LS_color border: #black;
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
	float common_pot_inc;
	string livelihood_strategy;

	action MOF_calc {
		MOF <- (sum(membres_hogar collect each.vMOF) * 30);
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
	string Sexo;
	int orden_en_hogar;
	float vMOF;
	float inc;
	string auto_id;
	bool chef;

	action vMOF_calc {
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
			add cand to: candidates;
		}

		return candidates;
	}

	action ranking_MCA { //PROCEDURE D'EVALUATION MULTI CRITERES
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