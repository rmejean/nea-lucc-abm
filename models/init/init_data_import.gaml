model data_import

// IMPORTATION OF DATA

global {

    //Importing population csv files (INEC, 2010)
	file f_PERSONAS_predios <- file("../../includes/censo/Personas_des_161_locsincom.csv");
	file f_HOGARES_predios <- file("../../includes/censo/Hogares_des_161_locsincom.csv");
	//	file f_PERSONAS_comunas <- file("../includes/censo/com_personas.csv");
	//	file f_HOGARES_comunas <- file("../includes/censo/com_hogares.csv");

	//Import csv frequency tables for the landscape generator
	file f_FREQ_SP1_1 <- file("../../includes/LS_patchwork_frequencies/SP1_1.csv");
	file f_FREQ_SP1_2 <- file("../../includes/LS_patchwork_frequencies/SP1_2.csv");
	file f_FREQ_SP1_3 <- file("../../includes/LS_patchwork_frequencies/SP1_3.csv");
	file f_FREQ_SP2 <- file("../../includes/LS_patchwork_frequencies/SP2.csv");
	file f_FREQ_SP3 <- file("../../includes/LS_patchwork_frequencies/SP3.csv");

	//Importing GIS files
	file buildings_shp <- file("../../includes/constructions_dayuma_SIGTIERRAS.shp");
	file sectores_shp <- file("../../includes/sectores_entiers.shp");
	file predios_con_def_shp <- file("../../includes/predios_con_def.shp");
	//file predios_sin_def_shp <- file("../../includes/predios_sin_def.shp");
	file vias_shp <- shape_file("../../includes/routes_SIGTIERRAS_cut.shp");
	file comunas_shp <- file("../../includes/comunas.shp");

	//Importing Land Cover (MAE, 2008)
	file MAE_2008 <- file("../../includes/MAE2008_90m.asc"); //spatial resolution: 90m
	
	//CORRESPONDENCE FOR MAPPING PROCESS WITH GENSTAR
	//name of the property that contains the id of the census spatial areas in the shapefile
	string stringOfCensusIdInShapefile <- "DPA_SECDIS";
	//name of the property that contains the id of the census spatial areas in the csv file (and population)
	string stringOfCensusIdInCSVfile <- "sec_id";
	//
	geometry shape <- envelope(MAE_2008); //spatial extension
}