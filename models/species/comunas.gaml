/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model comunas_def
//
// DEFINITION OF COMUNAS (community plots)
//
import "../species_def.gaml"
//
species comunas {
	string clave_cata;
	int area_total -> length(cells_inside);
	int area_deforest -> length(cells_deforest);
	int area_forest -> length(cells_forest);
	list<cell> cells_inside <- cell overlapping self; //trouver mieux que overlapping ?
	list<cell> cells_deforest -> cells_inside where (each.is_deforest = true);
	list<cell> cells_forest -> cells_inside where (each.is_deforest = false);

	aspect default {
		draw shape color: #black border: #black;
	}

}