/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model patches_def
//
// DEFINITION OF PATCHES FOR INIT
//
import "../species_def.gaml"

species patches {
	predios my_predio;
	string id;
	bool is_deforest;
	bool is_free;
	string type;
	int months;
	float rev;
	predios predio;
	hogares my_hogar;
}