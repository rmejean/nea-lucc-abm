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
import "init/init_data_import.gaml"
import "init/init_MCA_criteria.gaml"
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
import "species/empresas.gaml"
import "species/patches.gaml"
import "species/sectores.gaml"


global {

//-----------------------------
//Farming activities parameters
//-----------------------------

//MOF -------------------------
	int cost_employees <- 250;
	
	float laborcost_SC1_1 <- 3.7;//rapporté à 90m*90m
	float laborcost_SC1_2 <- 1.575;
	float laborcost_SC2 <- 2.55;
	float laborcost_SC3_1 <- 15.64;
	float laborcost_SC4_1 <- 2.32;
	float laborcost_SC4_2 <- 1.87;
	float laborcost_SE1_1 <- 0.8113;//pour 70 px= 56.79;
	float laborcost_SE1_2 <- 0.6278;//pour 15px = 9.417;
	float laborcost_SE2_1 <- 1.51;
	float laborcost_SE2_2 <- 3.63;
	float laborcost_SE2_3 <- 6.56;
	float laborcost_SE3 <- 2.33;
	
	
}
