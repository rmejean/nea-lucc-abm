/***
* Name: modelimportinit
* Author: Romain Mejean
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model model_import_init

// IMPORTATION OF INIT DATA
global {

//Importing species files
	file AL_shp <- file("../initGENfiles/agricultural_landscape.shp");
	file predios_shp <- file("../initGENfiles/hogares.shp");
	file hogares_shp <- file("../initGENfiles/hogares.shp");
	file personas_shp <- file("../initGENfiles/personas.shp");

	//Importing GIS files
	file buildings_shp <- file("../includes/constructions_dayuma_SIGTIERRAS.shp");
	file sectores_shp <- file("../includes/sectores_entiers.shp");
	file predios_con_def_shp <- file("../includes/predios_con_def.shp");
	//file predios_sin_def_shp <- file("../includes/predios_sin_def.shp");
	file vias_shp <- shape_file("../includes/routes_SIGTIERRAS_cut.shp");
	file comunas_shp <- file("../includes/comunas.shp");

	//Importing Land Cover (MAE, 2008)
	file MAE_2008 <- file("../includes/MAE2008_90m.asc"); //spatial resolution: 90m
	geometry shape <- envelope(MAE_2008); //spatial extension
}
