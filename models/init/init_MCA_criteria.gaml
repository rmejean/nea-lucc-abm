/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model init_MCA_criteria


/* DEFINITION OF MCA CRITERIA & PARAMETERS
 * 
 * The multi-criteria analysis assigns
 *  a livelihood strategy (LS) to each household
 *  at the initialization of the model.
 */
global {

//List and definition of criteria for each LS
	list<string> criterias <- ["def_rate", "forest_rate", "dist_via_auca", "prox_via_auca", "indigena"]; // deforestation rate of the plot, distance to a first-order road (the via auca), self-identification as indigenous
	list
	criteria_WM_SP1_1 <- [["name"::"def_rate", "weight"::SP1_1_weight_def_rate], ["name"::"forest_rate", "weight"::SP1_1_weight_forest_rate], ["name"::"dist_via_auca", "weight"::SP1_1_weight_dist_via_auca], ["name"::"prox_via_auca", "weight"::SP1_1_weight_prox_via_auca], ["name"::"indigena", "weight"::SP1_1_weight_indigena]];
	list
	criteria_WM_SP1_2 <- [["name"::"def_rate", "weight"::SP1_2_weight_def_rate], ["name"::"forest_rate", "weight"::SP1_2_weight_forest_rate], ["name"::"dist_via_auca", "weight"::SP1_2_weight_dist_via_auca], ["name"::"prox_via_auca", "weight"::SP1_2_weight_prox_via_auca], ["name"::"indigena", "weight"::SP1_2_weight_indigena]];
	list
	criteria_WM_SP1_3 <- [["name"::"def_rate", "weight"::SP1_3_weight_def_rate], ["name"::"forest_rate", "weight"::SP1_3_weight_forest_rate], ["name"::"dist_via_auca", "weight"::SP1_3_weight_dist_via_auca], ["name"::"prox_via_auca", "weight"::SP1_3_weight_prox_via_auca], ["name"::"indigena", "weight"::SP1_3_weight_indigena]];
	list
	criteria_WM_SP2 <- [["name"::"def_rate", "weight"::SP2_weight_def_rate], ["name"::"forest_rate", "weight"::SP2_weight_forest_rate], ["name"::"dist_via_auca", "weight"::SP2_weight_dist_via_auca], ["name"::"prox_via_auca", "weight"::SP2_weight_prox_via_auca], ["name"::"indigena", "weight"::SP2_weight_indigena]];
	list
	criteria_WM_SP3 <- [["name"::"def_rate", "weight"::SP3_weight_def_rate], ["name"::"forest_rate", "weight"::SP3_weight_forest_rate], ["name"::"dist_via_auca", "weight"::SP3_weight_dist_via_auca], ["name"::"prox_via_auca", "weight"::SP3_weight_prox_via_auca], ["name"::"indigena", "weight"::SP3_weight_indigena]];

//Parameters for each criterion and for each LS
	//SP1.1
	float SP1_1_weight_def_rate <- 0.0;
	float SP1_1_weight_forest_rate <- 2.0;
	float SP1_1_weight_dist_via_auca <- 1.0;
	float SP1_1_weight_prox_via_auca <- 0.0;
	float SP1_1_weight_indigena <- 0.0;
	//SP1.2
	float SP1_2_weight_def_rate <- 0.0;
	float SP1_2_weight_forest_rate <- 2.0;
	float SP1_2_weight_dist_via_auca <- 0.5;
	float SP1_2_weight_prox_via_auca <- 0.0;
	float SP1_2_weight_indigena <- 0.0;
	//SP1.3
	float SP1_3_weight_def_rate <- 1.0;
	float SP1_3_weight_forest_rate <- 1.0;
	float SP1_3_weight_dist_via_auca <- 0.0;
	float SP1_3_weight_prox_via_auca <- 0.0;
	float SP1_3_weight_indigena <- 0.0;
	//SP2
	float SP2_weight_def_rate <- 3.0;
	float SP2_weight_forest_rate <- 0.0;
	float SP2_weight_dist_via_auca <- 0.0;
	float SP2_weight_prox_via_auca <- 2.0;
	float SP2_weight_indigena <- 0.0;
	//SP3
	float SP3_weight_def_rate <- 3.0;
	float SP3_weight_forest_rate <- 0.0;
	float SP3_weight_dist_via_auca <- 0.0;
	float SP3_weight_prox_via_auca <- 0.0;
	float SP3_weight_indigena <- 0.0;
}