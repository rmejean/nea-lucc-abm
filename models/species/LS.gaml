/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model LS_def
//
// DEFINITION OF LS AGENTS
//
import "../species_def.gaml"
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
		
		loop while: (length(predios where (each.is_free_MCA = true)) != 0) {
			list<list> cands <- predios_eval();
			int choice <- code_LS = "SP1.1" ? weighted_means_DM(cands, criteria_WM_SP1_1) : (code_LS = "SP1.2" ? weighted_means_DM(cands, criteria_WM_SP1_2) : (code_LS = "SP1.3" ?
			weighted_means_DM(cands, criteria_WM_SP1_3) : (code_LS = "SP2" ? weighted_means_DM(cands, criteria_WM_SP2) : weighted_means_DM(cands, criteria_WM_SP3))));
			if choice >= 0 {
				ask predios where (each.is_free_MCA = true) at choice {
					LS <- myself.code_LS;
					is_free_MCA <- false;
					my_hogar.livelihood_strategy <- LS;
					write "LS" + LS + "affectée";
				}

			}

		}
				
//				ask predios {
//				
//				if is_free = true { //TODO: pourquoi j'ai besoin de forcer en rajoutant cette instruction ??
//				LS <- "none";
//			}
//			
//			}
				
			
				
//				ask hogares {
//					livelihood_strategy <- my_predio.LS;
//				}
				

		
		
		
//		switch code_LS {
//			match "1.1" {
//				write "------START OF RANKING FOR LS 1.1";
//				loop while: (length(predios where (each.is_free_MCA = true)) != 0) {
//					list<list> cands <- predios_eval();
//					int choice <- weighted_means_DM(cands, criteria_WM_SP1_1);
//					if choice >= 0 {
//						ask predios where (each.is_free_MCA = true) at choice {
//							id_EMC_LS1_1 <- predios max_of (each.id_EMC_LS1_1) + 1;
//							add id_EMC_LS1_1 to: rankings_LS_EMC;
//							is_free_MCA <- false;
//							write "---------Ranking of a plot for the LS 1.1";
//						}
//
//					}
//
//				}
//
//				ask hogares {
//					ask my_predio {
//						is_free_MCA <- true;
//					}
//
//				}
//
//			}
//
//			match "1.2" {
//				write "------START OF RANKING FOR LS 1.2";
//				loop while: (length(predios where (each.is_free_MCA = true)) != 0) {
//					list<list> cands <- predios_eval();
//					int choice <- weighted_means_DM(cands, criteria_WM_SP1_2);
//					if choice >= 0 {
//						ask predios where (each.is_free_MCA = true) at choice {
//							id_EMC_LS1_2 <- predios max_of (each.id_EMC_LS1_2) + 1;
//							add id_EMC_LS1_2 to: rankings_LS_EMC;
//							is_free_MCA <- false;
//							write "---------Ranking of a plot for the LS 1.2";
//						}
//
//					}
//
//				}
//
//				ask hogares {
//					ask my_predio {
//						is_free_MCA <- true;
//					}
//
//				}
//
//			}
//
//			match "1.3" {
//				write "------START OF RANKING FOR LS 1.3";
//				loop while: (length(predios where (each.is_free_MCA = true)) != 0) {
//					list<list> cands <- predios_eval();
//					int choice <- weighted_means_DM(cands, criteria_WM_SP1_3);
//					if choice >= 0 {
//						ask predios where (each.is_free_MCA = true) at choice {
//							id_EMC_LS1_3 <- predios max_of (each.id_EMC_LS1_3) + 1;
//							add id_EMC_LS1_3 to: rankings_LS_EMC;
//							is_free_MCA <- false;
//							write "---------Ranking of a plot for the LS 1.3";
//						}
//
//					}
//
//				}
//
//				ask hogares {
//					ask my_predio {
//						is_free_MCA <- true;
//					}
//
//				}
//
//			}
//
//			match "2" {
//				write "------START OF RANKING FOR LS 2";
//				loop while: (length(predios where (each.is_free_MCA = true)) != 0) {
//					list<list> cands <- predios_eval();
//					int choice <- weighted_means_DM(cands, criteria_WM_SP2);
//					if choice >= 0 {
//						ask predios where (each.is_free_MCA = true) at choice {
//							id_EMC_LS2 <- predios max_of (each.id_EMC_LS2) + 1;
//							add id_EMC_LS2 to: rankings_LS_EMC;
//							is_free_MCA <- false;
//							write "---------Ranking of a plot for the LS 2";
//						}
//
//					}
//
//				}
//
//				ask hogares {
//					ask my_predio {
//						is_free_MCA <- true;
//					}
//
//				}
//
//			}
//
//			match "3" {
//				write "------START OF RANKING FOR LS 3";
//				loop while: (length(predios where (each.is_free_MCA = true)) != 0) {
//					list<list> cands <- predios_eval();
//					int choice <- weighted_means_DM(cands, criteria_WM_SP3);
//					if choice >= 0 {
//						ask predios where (each.is_free_MCA = true) at choice {
//							id_EMC_LS3 <- predios max_of (each.id_EMC_LS3) + 1;
//							add id_EMC_LS3 to: rankings_LS_EMC;
//							is_free_MCA <- false;
//							write "---------Ranking of a plot for the LS 3";
//						}
//
//					}
//
//				}
//
//			}
//
//		}
//
//		ask hogares {
//			ask my_predio {
//				is_free_MCA <- true;
//			}
//
//		}

	}

	action apply_MCA {
		ask predios {
			if index_of(rankings_LS_EMC, min(rankings_LS_EMC)) = 0 {
				LS <- "SP1.1";
				write "---------LS 1.1 assigned to a plot.";
			}

			if index_of(rankings_LS_EMC, min(rankings_LS_EMC)) = 1 {
				LS <- "SP1.2";
				write "---------LS 1.2 assigned to a plot.";
			}

			if index_of(rankings_LS_EMC, min(rankings_LS_EMC)) = 2 {
				LS <- "SP1.3";
				write "---------LS 1.3 assigned to a plot.";
			}

			if index_of(rankings_LS_EMC, min(rankings_LS_EMC)) = 3 {
				LS <- "SP2";
				write "---------LS 2 assigned to a plot.";
			}

			if index_of(rankings_LS_EMC, min(rankings_LS_EMC)) = 4 {
				LS <- "SP3";
				write "---------LS 3 assigned to a plot.";
			}

			if is_empty = true { //TODO: pourquoi j'ai besoin de forcer en rajoutant cette instruction ??
				LS <- "none";
			}

		}

		ask hogares {
			livelihood_strategy <- my_predio.LS;
		}

	}

}