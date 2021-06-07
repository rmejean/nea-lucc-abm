/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model sectores_def
//
// DEFINITION OF SECTORES
//
import "../species_def.gaml"

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