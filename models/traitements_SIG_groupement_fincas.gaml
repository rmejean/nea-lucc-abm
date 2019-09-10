/***
* Name: traitements
* Author: Romain Mejean
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model traitements

/* Insert your model definition here */
global {
	file shapefile_predios <- shape_file("includes/predios_dayuma_SIGTIERRAS.shp");

	file shapefile_construcciones <- shape_file('includes/constructions_dayuma_SIGTIERRAS.shp');
	geometry shape <- envelope(shapefile_predios);

	init {
		write "Initialisation de la simulation";
		create predios from: shapefile_predios with: [finca_id::int(read('finca_id'))];
		write "Parcelles chargées";
		create construcciones from: shapefile_construcciones with: [building_id::int(read("cons_id"))];
		write "Buildings chargés";
		
		ask predios {
			do attribuer_parcelle;
			write "Parcelles attribuées aux buildings";
		}
		
		ask construcciones {
			do sauvegarder;
			write "Fichier CSV écrit";
		}

	}
}

species predios {
	int finca_id;

	action attribuer_parcelle {
		ask construcciones inside (self) {
			finca_id <- myself.finca_id;
		}

	}

	aspect parcelle {
		draw shape color: #green;
	}

}

species construcciones {
	int building_id;
	int finca_id;

	action sauvegarder {
		save [building_id, finca_id] to: "/results/output1.csv" type: "csv" rewrite: false;
	}

	aspect building {
		draw shape color: #red;
	}

}

experiment sim1 type: gui {
	output {
		display map {
			species predios aspect: parcelle;
			species construcciones aspect: building;
		}

	}

}