/*
* Name: Northern Ecuadorian Amazon Land Use & Cover Change Agent-Based Model
* Version: 0.1
* Year : 2020
* Author: Romain Mejean, PhD student in Geography @t UMR 5602 GEODE CNRS/Université Toulouse 2 Jean Jaurès
* Contact : romain.mejean@univ-tlse2.fr
* Description: a LUCC model in Northern Ecuadorian Amazon (parroquia de Dayuma)
* Tags: LUCC, deforestation dynamics, livelihood strategies
*/
model personas_def
//
//
// DEFINITION OF PERSONAS (people)
//
//
import "../species_def.gaml"

species personas parent: hogares {
	hogares my_hogar;
	int Age;
	string mes_nac;
	string Sexo;
	int orden_en_hogar;
	float labor_value;
	float food_needs;
	float inc;
	string auto_id;
	bool chef;

	action labour_value_and_needs {
		if Age < 11 {
			labor_value <- 0.0;
		}

		if Age = 11 {
			labor_value <- 0.16;
		}

		if Age = 12 {
			labor_value <- 0.33;
		}

		if Age = 13 {
			labor_value <- 0.5;
		}

		if Age = 14 {
			labor_value <- 0.66;
		}

		if Age = 15 {
			labor_value <- 0.83;
		}

		if Age >= 16 {
			labor_value <- 1.0;
		}

		food_needs <- 0.5;
	}

	action aging {
		if current_month = self.mes_nac { //when it's my birthday!
			Age <- Age + 1;
			do labour_value_and_needs;
			//MORT
			if between(Age, 70, 80) {
				if flip(0.1) {
					remove self from: my_hogar.membres_hogar;
					ask my_hogar {
						do values_calc;
					}

					do die;
				}

			}

			if Age > 80 {
				if flip(0.33) {
					remove self from: my_hogar.membres_hogar;
					ask my_hogar {
						do values_calc;
					}

					do die;
				}

			}

		}

	}

	aspect default {
		draw circle(6) color: #blue border: #black;
	}

}
