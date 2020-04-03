/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model empresas_def
//
// DEFINITION OF OIL COMPAGNIES
//

species empresas {
	int nb_jobs <- 50;
	int nb_oc_jobs;
	int job_wages <- 350;
	//
	aspect default {
		draw shape color: #black border: #black;
	}

}
