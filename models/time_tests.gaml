/***
* Name: NewModel
* Author: romai
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

/* Insert your model definition here */

global {
	bool stop_simulation <- false;
	date starting_date <- date("2008-01-01");
	date current_date <- starting_date;
	string current_month;
	float step <- 1 #month update: step+1;
	
	reflex dynamic when: (stop_simulation = false) {
		current_date <- plus_months (current_date,1);
		current_month <- string(current_date,"MMMM",'es');
		write "-------------------------------------------";
		write "Current date at cycle " + cycle + ":" + current_date;
		write "Months elapsed: " + months_between(starting_date,current_date);
		write "time " + time;
		write "Current month is " + current_month;
		if current_date > date("2016-01-01") {
			stop_simulation <- true;
			do pause;
			write "END OF SIMULATION";
		}
	}
}


experiment Simulation type: gui until: stop_simulation = true {
	
	
}

