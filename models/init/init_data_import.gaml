/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 1.0
* Year : 2020-2021
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model data_import

// IMPORTATION OF DATA
import "../model_core.gaml"

global {

//Importing population csv files (INEC, 2010)
	file f_PERSONAS_predios <- csv_file("../../includes/censo/Personas_des_161_locsincom.csv");
	file f_HOGARES_predios <- csv_file("../../includes/censo/Hogares_des_161_locsincom.csv");
	file f_PERSONAS_comunas <- csv_file("../../includes/censo/Personas_des_28_loccom.csv");
	file f_HOGARES_comunas <- csv_file("../../includes/censo/Hogares_des_28_loccom.csv");

	//Import csv frequency tables for the landscape generator
	file f_FREQ_SP1_1 <- csv_file("../../includes/LS_patchwork_frequencies/SP1_1.csv");
	file f_FREQ_SP1_2 <- csv_file("../../includes/LS_patchwork_frequencies/SP1_2.csv");
	file f_FREQ_SP1_3 <- csv_file("../../includes/LS_patchwork_frequencies/SP1_3.csv");
	file f_FREQ_SP2 <- csv_file("../../includes/LS_patchwork_frequencies/SP2.csv");
	file f_FREQ_SP3 <- csv_file("../../includes/LS_patchwork_frequencies/SP3.csv");

	//Importing GIS files
	//file buildings_shp <- file("../../includes/constructions_dayuma_SIGTIERRAS.shp");
	file sectores_shp <- file("../../includes/sectores_entiers_v2.shp");
	file predios_con_def_shp <- file("../../includes/predios_con_def_noborder.shp");
	//file predios_sin_def_shp <- file("../../includes/predios_sin_def.shp");
	file vias_shp <- shape_file("../../includes/routes_SIGTIERRAS_cut.shp");
	file comunas_shp <- file("../../includes/comunas.shp");
	file plataformas_shp <- file("../../includes/plataformas.shp");

	//Importing Land Cover (MAE, 2008)
	file MAE_2008 <- new_init = true ? file("../../includes/MAE2008_90m.tif") : file("../../includes/initGENfiles/simplified_classif.tif"); //spatial resolution: 90m


	//CORRESPONDENCE FOR MAPPING PROCESS WITH GENSTAR
	//name of the property that contains the id of the census spatial areas in the shapefile
	string stringOfCensusIdInShapefile <- "DPA_SECDIS";
	//name of the property that contains the id of the census spatial areas in the csv file (and population)
	string stringOfCensusIdInCSVfile <- "sec_id";
	//
	geometry shape <- envelope(MAE_2008); //spatial extension

	//Importing saved files for init generator
	file saved_cells;
	file saved_vias;
	file saved_predios;
	file saved_comunas;
	file saved_hogares;
	file saved_personas;
	file saved_empresas;
}