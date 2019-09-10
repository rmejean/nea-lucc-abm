/***
* Name: Main
* Author: Romain Mejean
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main

/* Insert your model definition here */
global {
	file shapefile_predios <- shape_file('../includes/predios_dayuma_SIGTIERRAS.shp');
	file shapefile_construcciones <- shape_file('../includes/constructions_dayuma_SIGTIERRAS_group2.shp');
	file shapefile_sectores <- shape_file('../includes/sectores_dayuma_INEC_v2.shp');
	geometry shape <- envelope(shapefile_predios);

	init {
		write "Initialisation de la simulation...";
		create predios from: shapefile_predios with: [parcelle_id::int(read("finca_id")), tipo::string(read("tipo"))];
		write "Parcelles chargées.";
		create construcciones from: shapefile_construcciones with: [finca_id::int(read("finca_id")), sec_id::int(read("sector_id"))];
		write "Batiments chargés.";
		create sectores from: shapefile_sectores with: [nb_hogares::int(read("NB_HOGARES"))];
		write "Secteurs chargés.";
		do genstar;
	}

	action genstar {
		write "Début de la génération de population...";
		ask sectores {
			create hogares number: self.nb_hogares; //with [location <- any_location_in  ] ;

		}

		ask hogares {
			do spatialization;
		}

	}

}

species predios {
	int parcelle_id;
	string tipo;

	aspect parcelle {
		if (tipo = 'parcelle') {
			draw shape color: #green;
		} else {
			draw shape color: #darkgreen;
		}

	}

}

species construcciones {
	int finca_id;
	int sec_id;
	bool is_free <- true;

	aspect building {
		draw shape color: #red;
	}

}

species hogares {

	action spatialization {
		
	}

	aspect point {
		draw circle(2) color: #yellow border: #black;
	}

}

species sectores {
	int nb_hogares;
}

experiment sim1 type: gui {
	output {
		display map {
			species predios aspect: parcelle;
			species construcciones aspect: building;
			species hogares aspect: point;
		}

	}

}