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
import "model_simulations.gaml"

//Import species

import "species/cells.gaml"
import "species/predios.gaml"
import "species/comunas.gaml"
import "species/hogares.gaml"
import "species/personas.gaml"
import "species/vias.gaml"
import "species/LS.gaml"
import "species/patches.gaml"
import "species/sectores.gaml"


global {

//-----------------------------
//Farming activities parameters
//-----------------------------

//MOF -------------------------
	float MOFcost_maniocmais <- 8.1;
	float MOFcost_fruits <- 11.34;
	float MOFcost_s_livestock <- 5.76;
	float MOFcost_plantain <- 3.24;
	float MOFcost_coffee <- 2.79;
	float MOFcost_cacao <- 2.7;
	float MOFcost_livestock <- 18.45;
	float MOFcost_no_farming <- 0.0;
}
