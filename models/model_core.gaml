/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model core_model

/* Insert your model definition here */
import "model_data_import.gaml"
import "model_species.gaml"

global {

//Global variables for monitors
	int nb_menages -> length(hogares);
	int nb_personas -> length(personas);
	int nb_predios -> length(predios);
	float ratio_deforest_min -> predios min_of (each.def_rate);
	float ratio_deforest_max -> predios max_of (each.def_rate);
	float ratio_deforest_mean -> predios mean_of (each.def_rate);
	int area_min -> predios min_of (each.area_total);
	int area_max -> predios max_of (each.area_total);
	float area_mean -> predios mean_of (each.area_total);
	int area_deforest_min -> predios min_of (each.area_deforest);
	int area_deforest_max -> predios max_of (each.area_deforest);
	float area_deforest_mean -> predios mean_of (each.area_deforest);

	//-----------------------------
	//Farming activities parameters
	//-----------------------------
	//MOF -------------------------
	float MOFcost_maniocmais <- 9.0;
	float MOFcost_fruits <- 12.6;
	float MOFcost_s_livestock <- 6.4;
	float MOFcost_plantain <- 3.6;
	float MOFcost_coffee <- 3.1;
	float MOFcost_cacao <- 3.0;
	float MOFcost_livestock <- 20.5;
	float MOFcost_no_farming <- 0.0;
	//Life cost --------------------
	float $_ANFP <- 250.0; //AMOUNT NEEDED TO FEED A PERSON - à établir
	init {
		if AL_shp != nil and predios_shp != nil and hogares_shp != nil and personas_shp != nil {
			do import_init;
		} else {
			write "Caution: You must first use the initialization generator and save its outputs!";
		}

	}

	action import_init {
	}

}
	
