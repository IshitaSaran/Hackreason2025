% FACTS
% Calories, food group, per standard measurement of food item
calories(beef, protein, 250). % Calories per pound
calories(milk, dairy, 50). % Calories per cup
calories(rice, grains, 200). % Calories per cup
calories(broccoli, vegetables, 50). % Calories per cup
calories(apple, fruits, 80). % Calories per apple
calories(oil, fats_and_oils, 120). % Calories per tbs
calories(pea, vegetables, 118). % Calories per cup

% Nutrients per food item, per standard food measurement
nutrients(beef, iron, 2). % Iron per pound (mg)
nutrients(milk, calcium, 300).   % Calcium per cup (mg)
nutrients(rice, vitaminB1, 0.2). % Vitamin B1 per cup (mg)
nutrients(broccoli, vitaminC, 80). % Vitamin C per cup (mg)
nutrients(apple, potassium, 200). % Potassium per apple (mg)
nutrients(oil, vitaminD, 0).     % Vitamin D per tbs (mg)
nutrients(pea, iron, 1.5).       % Iron per cup (mg)

% Define consumption for specific people
consumption(sarah, beef, 5). % Sarah eats 1 pound of beef
consumption(sarah, milk, 1). % Sarah drinks 1 cup of milk
consumption(john, rice, 2). % John eats 2 cups of rice
consumption(john, broccoli, 3). % John eats 3 cups of broccoli
consumption(john, pea, 2). % John eats 2 cups of peas

% Define calorie limit for specific people
calorie_limit(sarah, 10).
calorie_limit(john, 2000).

% Define what the total nutrient intake should be (per day)
ideal_nutrient_intake(fiber, 28). % mg
ideal_nutrient_intake(iron, 10).
ideal_nutrient_intake(calcium, 1000).
ideal_nutrient_intake(vitaminB1, 1.1).
ideal_nutrient_intake(potassium, 3000).
ideal_nutrient_intake(vitaminD, 1).

% Define good and bad foods for conditions
good_for(anemia, spinach).
good_for(anemia, beef).
bad_for(irritable_bowel_syndrome, spicy_food).
bad_for(irritable_bowel_syndrome, milk).

% Define some conditions for persons
has_condition(sarah, anemia).
has_condition(john, irritable_bowel_syndrome).

% Define preferences for each person
prefers(sarah, spinach).
prefers(sarah, beef).
prefers(john, milk).
prefers(john, spicy_food).

% Dietary preferences
prefers(sarah, apple).
prefers(sarah, broccoli).
prefers(sarah, spinach).
prefers(john, beef).
prefers(john, rice).
prefers(john, milk).

% Nutrients per food item
nutrients(broccoli, vitaminC, 80). % Vitamin C per cup (mg)
nutrients(apple, vitaminC, 10).    % Vitamin C per apple (mg)


% Define Mary's food preferences
prefers(mary, chocolate).
prefers(mary, ice_cream).

% Define comfort foods and stress reducers
comfort_food(chocolate).  
comfort_food(ice_cream).
stress_reducer(green_tea).
stress_reducer(dark_chocolate).








% RULES


% Calculate total calories consumed for each category
calories_per_category(Person, Category, TotalCalories) :-
    consumption(Person, FoodItem, Quantity),
    calories(FoodItem, Category, CaloriesPerUnit),
    TotalCalories = Quantity * CaloriesPerUnit.


% Calculate total nutrient consumed for each nutrient group
nutrients_per_category(Person, NutrientGroup, TotalNutrient) :-
    consumption(Person, FoodItem, Quantity),
    nutrients(FoodItem, NutrientGroup, NutrientPerUnit),
    TotalNutrient = Quantity * NutrientPerUnit.




% Sum total calories for each category
total_calories_per_category(Person, Category, TotalCalories) :-
    findall(Total, calories_per_category(Person, Category, Total), TotalList), % Collect all calories for a person and category
    list_sum(TotalList, TotalCalories).




% Sum total nutrients for each
total_nutrients_per_category(Person, NutrientGroup, TotalNutrient) :-
    findall(Total, nutrients_per_category(Person, NutrientGroup, Total), TotalList), % Collect all nutrients for a person and category
    list_sum(TotalList, TotalNutrient).


% Sum TOTAL calorie intake
total_calorie_intake(Person, TotalCalorieIntake) :-
    findall(Total, total_calories_per_category(Person, Category, Total), TotalList),
    list_sum(TotalList, TotalCalorieIntake).




% Recursive sum function
list_sum([], 0).                              % base case
list_sum([Head | Tail], TotalSum) :-
    list_sum(Tail, Sum1),                    
    TotalSum = Head + Sum1.          
   
% Provide calorie warnings
exceeds_calorie_limit(Person) :-
    calorie_limit(Person, Limit),
    total_calorie_intake(Person, TotalCalorieIntake),
    TotalCalorieIntake > Limit.


% Detect vitamin deficiency
vitaminDeficiency(Person, Vitamin) :-
    prefers(Person, Food),
    not nutrients(Food, Vitamin, _).  % Check if the food contains the vitamin


% Detect mineral deficiency
mineralDeficiency(Person, Mineral) :-
    prefers(Person, Food),
    not nutrients(Food, Mineral, _).  % Check if the food contains the mineral


% RISKS FOR DISEASES BASED ON NUTRIENT INTAKE
% check risk for iron deficiency anemia based on current diet
anemia_risk(Person) :-
    total_nutrients_per_category(Person, iron, TotalNutrient),
    ideal_nutrient_intake(iron, NutrientAmount),
    TotalNutrient < NutrientAmount.


% check risk of scurvy (lack of vitamin C)
scruvy_risk(Person) :-
    total_nutrients_per_category(Person, vitaminC, TotalNutrient),
    ideal_nutrient_intake(vitaminC, NutrientAmount),
    TotalNutrient < NutrientAmount.


% check risk of Rickets/Osteomalacia (vitamin D or calcium lack)
rickets_risk(Person) :-
    total_nutrients_per_category(Person, vitaminD, TotalNutrient),
    ideal_nutrient_intake(vitaminD, NutrientAmount),
    TotalNutrient < NutrientAmount.


% check risk of Beriberi (lack of vitamin B1)
beriberi_risk(Person) :-
    total_nutrients_per_category(Person, vitaminB1, TotalNutrient),
    ideal_nutrient_intake(vitaminB1, NutrientAmount),
    TotalNutrient < NutrientAmount.


% check risk of Hypokalemia (lack of potassium)
hypokalemia_risk(Person) :-
    total_nutrients_per_category(Person, potassium, TotalNutrient),
    ideal_nutrient_intake(potassium, NutrientAmount),
    TotalNutrient < NutrientAmount.


% Check if the food is suitable for the condition
good_for_condition(Person, Condition) :-
    has_condition(Person, Condition),
    good_for(Condition, Food),
    prefers(Person, Food).

bad_for_condition(Person, Condition) :- 
    has_condition(Person, Condition),
    bad_for(Condition, Food),
    prefers(Person, Food).

% Suggest alternatives for emotional eaters
suggest_emotional_eater(Person, Suggestion) :-
    prefers(Person, ComfortFood),
    comfort_food(ComfortFood),
    Suggestion = ComfortFood.

suggest_stress_reducer(Person, Suggestion) :-
    prefers(Person, Reducer),
    stress_reducer(Reducer),
    Suggestion = Reducer.

% check if the person has a healthy food plan
% if not at risk of any diseases, not over the calorie limit)
healthy_plan(Person) :-
    not anemia_risk,
    not scurvy_risk,
    not rickets_risk,
    not beriberi_risk,
    not hypokalemia_risk,
    not constipation_risk,
    not exceeds_calorie_limit.

% List the risks of a person's diet
risk(Person, anemia) :- anemia_risk(Person).
risk(Person, scurvy) :- scurvy_risk(Person).
risk(Person, rickets) :- rickets_risk(Person).
risk(Person, beriberi) :- beriberi_risk(Person).
risk(Person, hypokalemia) :- hypokalemia_risk(Person).
risk(Person, constipation) :- constipation_risk(Person).
risk(Person, exceeds_calories) :- exceeds_calorie_limit(Person).

% Get all the risks
list_risk(Person, Risks) :-
    findall(Risk, risk(Person, Risk), Risks).