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
import "../species_def.gaml"
species empresas {
	int nb_jobs;
	int free_jobs;
	float job_wages <- 350.0;
	list<personas> workers;

	action generate_jobs {
		if flip(0.5) = true {
			nb_jobs <- nb_jobs + nb_new_jobs;
			free_jobs <- free_jobs + nb_new_jobs;
		}

	}

	aspect default {
		draw shape color: #black border: #black;
	}

}
