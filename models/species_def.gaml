/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model species_def
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
	float laborcost_SC1_1 <- 3.7; //rapporté à 90m*90m
	float laborcost_SC1_2 <- 1.575;
	float laborcost_SC2 <- 2.55;
	float laborcost_SC3_1 <- 15.64;
	float laborcost_SC4_1 <- 2.32;
	float laborcost_SC4_2 <- 1.87;
	float laborcost_SE1_1 <- 0.8113; //pour 70 px= 56.79;
	float laborcost_SE1_2 <- 0.6278; //pour 15px = 9.417;
	float laborcost_SE2_1 <- 1.6875;
	float laborcost_SE2_2 <- 4.03;
	float laborcost_SE2_3 <- 7.28;
	float laborcost_SE3 <- 2.589;
	float laborcost_install_SC1 <- 29.25;
	float laborcost_install_SC2 <- 19.35;
	float laborcost_install_SC3 <- 8.5; //TODO: à vérifier...
	float laborcost_install_SC4 <- 8.5; //TODO: à vérifier...
	float laborcost_install_SE1 <- 32.5;
	
	
	//Profits for profit LUC
	float profit_SC1_1 -> ((yld_cacao1 * price_cacao) - costmaint_cacaoinputs) / laborcost_SC1_1 ;
	float profit_SC1_2 -> ((yld_cacao2 * price_cacao) - costmaint_cacaoinputs) / laborcost_SC1_2;
	float profit_SC2 -> ((yld_coffee * price_cacao) - costmaint_cacaoinputs) / laborcost_SC2 ;
	float profit_SE1_1 -> ((yld_veaux1 * price_veaux) + (yld_vachereforme1 * price_vachereforme) + (yld_cheese1 * price_cheese) - costmaint_cattle_1) / laborcost_SE1_1 ;
	float profit_SE1_2 -> ((yld_veaux2 * price_veaux) + (yld_vachereforme2 * price_vachereforme) + (yld_cheese2 * price_cheese) - costmaint_cattle_2) / laborcost_SE1_2 ;
	//
	list profits_SP1_2 -> [profit_SC1_1,profit_SC1_2,profit_SC2];
	list profits_SP1_3 -> [profit_SC1_2,profit_SC2,profit_SE1_2];
}
