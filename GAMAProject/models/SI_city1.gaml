/**
 *  model4
 *  This model illustrates how to use spatial operator
 */ 
model SI_city

global{ 
	int nb_people <- 546;
	int nb_infected_init <- 1;
	int nb_mosquito <- 1000;
	int nb_water_sources <- 5 update: water_source count(each.current_age>=0);
	int nb_eggs <- 0 update: egg count(each.age>=0);
	
	file roads_shapefile <- file("../includes/roads.shp");
	file buildings_shapefile <- file("../includes/buildings.shp");
	geometry shape <- envelope(roads_shapefile);
	int nb_people_infected <- nb_infected_init update: people count (each.is_infected);
	int nb_people_not_infected <- nb_people - nb_infected_init update: nb_people - nb_people_infected;
	float infected_rate update: nb_people_infected/nb_people;
	int nb_mosquito_infected <- 0 update: mosquito count (each.is_infected);
	int nb_egg_infected <- 0 update: egg count (each.is_infected);
	int nb_infected_cumulative <- nb_infected_init;
	
	/* Model tunable parameters */
	float probability_mating <- 0.2;
	float mosquito_sex_ratio <- 0.5;
	float sensor_range <- 3.0 #m;
	float probability_t1_park <- 0.5;
	float probability_t2_park <- 0.1;
	float mortality_rate <- 0.05; // per day
	int max_meals <- 2; // biting rate per day
	
	/* A global clock for syncronisation */
	float step <- 10 #mn;
	int current_hour update: (time/3600) mod 24;
	int days_passed update: int(time/86400);
	int current_month update: int(days_passed/30);
	bool is_night <- true update: current_hour < 7 or current_hour > 20;
	
	/* Climate Data */
	file climate_file <- file("../includes/St_Barthelemy_Climate.csv");
	matrix climate_data; // 12*4 matrix : TempHigh, TempLow, RainyDays, Inches
	int pools_per_rain <- 5; // adds rain_severity*pools_per_rain water sources
	
	/* Population Statistics */
	int nb_people_type0 <- 135;
	int nb_people_type1 <- 167;
	int nb_people_type2 <- 167;
	int nb_people_type3 <- 77;
	
	int nb_protected <- 0;
	
	/* City Details */
	building school;
	building office;
	park city_park;

	graph road_network;
	
	init{
		climate_data <- matrix(climate_file);
		
		create road from: roads_shapefile;
		road_network <- as_edge_graph(road);
		create building from: buildings_shapefile;
		create park number:1;
		create lake number:1;
		create people number:nb_people {
			my_house <- one_of(building);
			location <- any_location_in(my_house);
			type <- rnd_choice([nb_people_type0/nb_people,nb_people_type1/nb_people,nb_people_type2/nb_people,nb_people_type3/nb_people]);
			state_duration[1] <- 2+rnd(4); // 2-6 days
			state_duration[2] <- 4+rnd(3); // 4-7 days
			state_duration[3] <- 14+rnd(90); // 2 weeks to 3 months
		}
		
		create water_source number:nb_water_sources {
			create egg number:25{
				my_water_source <- myself;
				is_infected <- false;
				max_age <- (6 + 5 - int((int(climate_data[0,current_month])+int(climate_data[1,current_month]))/30));
				age <- 5;
			}
		}
		
		create mosquito  number:nb_mosquito {
			if flip(0.01){
				lake l <- one_of(lake);
				location <- any_location_in (square(150) at_location {75,1700});
				type <- rnd(1);
			}
			else{
				my_water_source <- one_of(water_source);
				location <- any_location_in(my_water_source);
				type <- rnd(1);
			}
		}
		
		ask nb_infected_init among people {
			is_infected <- true;
			state <- 1;
		}
		
		ask nb_protected among people {
			is_protected <- true;
		}
		
		school <- one_of(building);
		office <- one_of(building);
		city_park <- one_of(park);
		
	}
	
	reflex rain when: (time mod 86400 = 0) {
		float rain_probabilty <- float(climate_data[2,current_month])/30.0;
		float rain_severity <- float(climate_data[3,current_month]);
		if flip(rain_probabilty) {
			create water_source number:int(rain_severity*pools_per_rain*0.25);
		}
	} 
	
	reflex end_simulation when: infected_rate = 1.0 or (nb_people_infected=0 and nb_mosquito_infected=0 and nb_egg_infected=0){
		do pause;
	}
}

/* TO DO */
species egg {
	int age <- 0;
	water_source my_water_source;
	bool is_infected <- false;
	int max_age;
	
	reflex age when: time mod 86400=0{
		age <- age + 1;
		if(age>=max_age){
			if flip(mosquito_sex_ratio){
				create mosquito {
					my_water_source <- myself.my_water_source;
					location <- any_location_in(my_water_source);
					type <- rnd(1);
					is_infected <- is_infected;
				}
			}
			nb_mosquito <- nb_mosquito+1;
			do die;
		}
	}
}

species mosquito skills:[moving]{	
	float speed <- (0.1 + rnd(1.0)) #km/#h;
	bool is_infected <- false;
	water_source my_water_source;
	int type <- 0; // 0->A.Aegypti 1->A.Albopictus
	int num_meals_today <- 0;
	bool carry_eggs <- false;
	int time_passed_eggs <- 0;
	int time_passed_virus <- 0;
	int time_to_mature <- 3 + abs(int(((int(climate_data[0,current_month])-32)*5/9+(int(climate_data[1,current_month])-32)*5/9)/2)-21)/5;
	
	reflex move when:  !is_night{
		do wander amplitude:350 #m;
	}

	
	/* TO DO */
	reflex feed when:  current_hour>=9 and current_hour<=18 and time mod 600 = 0 and num_meals_today<max_meals{
		if is_infected{
			ask any (people at_distance sensor_range) {
				if !(is_protected and in_my_house){
					myself.num_meals_today <- myself.num_meals_today + 1;
					if myself.is_infected{
						float p_trans <- 0.6;//myself.time_passed_virus/10 < 1.0 ? myself.time_passed_virus/10:1.0;//#e^(myself.time_passed_virus-10) <1 ? #e^(myself.time_passed_virus-10) : 1.0;
						if (state=0){
							if flip(p_trans){	
								is_infected <- true;
								state <- 1;
								nb_infected_cumulative <- nb_infected_cumulative+1;
							}
						}
					}
				}
			}
		}
		else {
			ask any (people at_distance sensor_range) {
				if !(is_protected and in_my_house) {
					myself.num_meals_today <- myself.num_meals_today + 1;
					if is_infected{
						float p_trans <- 0.275;//days_infected/state_duration[1] <1.0 ? days_infected/state_duration[1] : 1.0;//#e^(days_infected-state_duration[1]) <1 ? #e^(days_infected-state_duration[1]) : 1.0;
						if flip(p_trans) {
							myself.is_infected <- true;
						}
					}
				}
			}
		}
	}
	
	reflex reproduce when: time_passed_eggs>5 and time mod 600 = 0{
		ask water_source at_distance 20 #m {
			bool infection <-  myself.is_infected;
			create egg number:100{
				my_water_source <- myself;
				is_infected <- infection;
				max_age <- 8 + abs(int(((int(climate_data[0,current_month])-32)*5/9+(int(climate_data[1,current_month])-32)*5/9)/2)-25);
			}
		}
		time_passed_eggs <- 0;
		carry_eggs <- false;
	}
	
	reflex startDay when: time mod 86400 = 0{
		
		if flip(mortality_rate){
			nb_mosquito <- nb_mosquito-1;
			do die;
		}
		num_meals_today <- 0;
		if(carry_eggs){
			time_passed_eggs <- time_passed_eggs+1;
		}
		if(is_infected){
			time_passed_virus <- time_passed_virus;
		}
		if(!carry_eggs){
			if flip(probability_mating){
				carry_eggs <- true;
			}
		}
	}
	
	aspect triangle{
		draw triangle(10) color:is_infected ? #red : #green;
	}
}

species people skills:[moving]{		
	float speed <- (2 + rnd(3)) #km/#h;
	bool is_infected <- false;
	building my_house;
	point target;
	bool in_my_house <- true;
	int state <- 0; // 0->Susceptible 1->Exposed 2->Infected 3->Chronic Immune 4-> Immune
	list<int> state_duration <- [0,0,0,0,0]; 
	int days_infected <- 0;
	int current_location <- 0; // 0->my house 1->school 2->office 3->random house 4->park
	int type <-0; // 0->student 1->white collar 2->stationary 3->continously moving
	bool is_protected <- false;
	
		
	reflex move when: target != nil and !is_night and type!=2 and (state=0 or state=1 or state=4){
		do goto target:target on: road_network;
		if (location = target) {
			target <- nil;
		} 
	}
	
	reflex health when: (state=1 or state=2) and (time mod 86400 = 0){
		write "days infected,days left = " + days_infected + " " + state_duration[1] +" " + state_duration[2] + " " + state;
		days_infected <- days_infected+1;
		if state = 1 and (days_infected - state_duration[1] = 0){
				state <- 2;
		}
		else if state = 2 and (days_infected - state_duration[1] - state_duration[2] = 0){
				if flip(0.95){
					state <- 3;
				}
				else{
					state <-4;
				}
				is_infected <- false;
		}
		else if state = 3 and (days_infected - state_duration[1] - state_duration[2] - state_duration[3] = 0){
			state <- 4;
		}
	}
	
	reflex set_target when: target=nil {
		if type = 0{
			if current_hour = 7 and (time mod 3600 = 0){
				target <- any_location_in (school);
				current_location <- 1;
				in_my_house <- false;
			}
			else if current_hour = 15 and (time mod 3600 = 0){
				target <- any_location_in (my_house);
				current_location <- 0;
				in_my_house <- true;
			}
			else if current_hour = 16 and (time mod 3600 = 0){
				if flip(probability_t1_park){
					target <- any_location_in (square(400) at_location {200,1600});
					current_location <- 4;
					in_my_house <- false;
				}
			}
			else if  current_hour = 19{
				target <- any_location_in (my_house);
				current_location <- 0;
				in_my_house <- true;
			}
		}
		else if type = 1{
			if current_hour = 7 and (time mod 3600 = 0){
				target <- any_location_in (office);
				current_location <- 2;
				in_my_house <- false;
			}
			else if current_hour = 15 and (time mod 3600 = 0){
				target <- any_location_in (my_house);
				current_location <- 0;
				in_my_house <- true;
			}
			else if current_hour = 16 and (time mod 3600 = 0){
				if flip(probability_t2_park){
					target <- any_location_in (square(400) at_location {200,1600});
					current_location <- 4;
					in_my_house <- false;
				}
			}
			else if  current_hour = 19 and (time mod 3600 = 0){
				target <- any_location_in (my_house);
				current_location <- 0;
				in_my_house <- true;
			}
		}
		else if type = 3{
			if current_hour >= 7 and (time mod 7200 = 0){
				building bd_target <- one_of(building);
				target <- any_location_in (bd_target);
				current_location <- 3;
				in_my_house <- false;
			}
			if current_hour = 19  and (time mod 3600 = 0){
				target <- any_location_in(my_house);
				current_location <- 0;
				in_my_house <- true;
			}
		}
	}
	aspect circle{
		draw circle(10) color:is_infected ? #red : #green;
	}
}

species road {
	aspect geom {
		draw shape color: #black;
	}
}

species building {
	int type <- 0; // 0-> home, 1->school, 2->office
	aspect geom {
		draw shape color: #gray;
	}
}

species park{
	aspect square{
		draw square(400) at: {200,1600} color: #grey;
	}
}

species lake{
	aspect square{
		draw square(150) at: {75,1700} color: #blue;
	}
}

species water_source {
	int current_age <- 0; // in days
	aspect square{
		draw square(20) color: #blue;
	}
	reflex age when: (time mod 86400 = 0) {
		current_age <- current_age + 1;
	}
	reflex vanish when: current_age = 7 {
		do die;
	}
}

experiment main_experiment type:gui{
	parameter "Nb people infected at init" var: nb_infected_init min: 1 max: 1000;
	parameter "Mosquito Sex Ratio" var: mosquito_sex_ratio min: 0.0 max: 1.0;
	parameter "Mosquito Mating Probability" var: probability_mating min: 0.0 max: 1.0;
	parameter "Mosquito Sensory Range" var: sensor_range min: 2.0 #m max: 6.0 #m;
	parameter "Probability_t1_park" var: probability_t1_park min: 0.0 max: 1.0;
	parameter "Probability_t2_park" var: probability_t2_park min: 0.0 max: 1.0;
	parameter "Mortality_rate" var: mortality_rate min: 0.0 max: 1.0;
	parameter "Max_meals" var: max_meals min: 1 max: 10;
	
	
	output {
		monitor "Infected people rate" value: infected_rate;
		monitor "Current Day" value: days_passed;
		monitor "Current Hour" value: current_hour;
		monitor "Current Month" value: current_month;
		monitor "Current Time" value: time/60;
		monitor "Current water sources" value: nb_water_sources;
		monitor "Infected people" value: nb_people_infected; 
		monitor "Infected mosqutios" value: nb_mosquito_infected;
		monitor "Infected eggs" value: nb_egg_infected; 
		
//		display map type: opengl ambient_light: is_night ? 30 : 120{
//			image "../includes/soil.jpg";
//			species road aspect:geom;
//			species building aspect:geom;
//			species park aspect:square;	
//			species lake aspect:square;
//			species water_source aspect:square;
//			species people aspect:circle;		
//			species mosquito aspect:triangle; 
//		}
		
		display chart1 refresh_every: 10 {
			chart "Disease spreading" type: series {
//				data "susceptible" value: nb_people_not_infected color: #green;
				data "infected" value: nb_people_infected color: #red;
				data "infected cumulative (/500)" value: nb_infected_cumulative color: #blue;
			}
		}
		display chart2 refresh_every: 10 {
			chart "Mosquito Population" type: series {
				data "num_mosquitoes" value: nb_mosquito color: #green;
				data "infected" value: nb_mosquito_infected color: #red;
				data "num_eggs" value: nb_eggs color: #black;
			}
		}
	}
}