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
	bool oil_worker <- false;
	int work_pace;
	int contract_term;
	int working_months;
	int job_wages;
	int annual_inc;
	empresas empresa;
	list<hogares> co_workers_hog;

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

	action update {
		if current_month = self.mes_nac { //when it's my birthday!
			Age <- Age + 1;
			do labour_value_and_needs;
			ask my_hogar {
				labor_force <- (sum(membres_hogar collect each.labor_value) * 30);
				available_workers <- labor_force - occupied_workers;
			}
			//DEATH
			if between(Age, 70, 80) {
				if flip(0.2) {
					remove self from: my_hogar.membres_hogar;
					ask my_hogar {
						labor_force <- labor_force - 30;
						occupied_workers <- occupied_workers - 30;
						if occupied_workers > labor_force {
							write "there's a problem: the death disrupted the balance of the workforce";
							//TODO: à régler (réorganisation du travail après décès)
						}

					}

					do die;
					ask hogares {do update_needs;}
				}

			}

			if Age > 80 {
				if flip(0.33) {
					remove self from: my_hogar.membres_hogar;
					ask my_hogar {
						labor_force <- labor_force - 30;
						occupied_workers <- occupied_workers - 30;
						if occupied_workers > labor_force {
							write "there's a problem: the death disrupted the balance of the workforce";
							//TODO: à régler (réorganisation du travail après décès)
						}

					}

					do die;
					ask hogares {do update_needs;}
				}

			}

			if oil_worker = true {
				working_months <- working_months + 1;
				if working_months > contract_term { //if my employment contract is over...
					oil_worker <- false;
					contract_term <- nil;
					working_months <- nil;
					job_wages <- 0;
					annual_inc <- 0; //TODO: éventuelle erreur ? car ça annule ce qui a été gagné avant
					co_workers_hog <- nil;
					ask empresa {
						remove myself from: workers;
					}

					ask my_hogar {
						available_workers <- available_workers + myself.work_pace;
						oil_workers <- oil_workers - 1;
					}

					work_pace <- nil;
					empresa <- nil;
				}

			}

		}

	}

	aspect default {
		draw circle(6) color: #blue border: #black;
	}

}
