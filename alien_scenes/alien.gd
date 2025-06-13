extends Node2D

var toppings := { 
	#attributes are: .name // .colour // .consistency // .flavor
	# format is:  toppings["Kecthup"].colour 
	"Ketchup": preload("res://resources/topping_resources/Ketchup.tres"),
	"Mustard": preload("res://resources/topping_resources/Mustard.tres"),
	"Relish": preload("res://resources/topping_resources/Relish.tres"),
	"ChiliFlakes": preload("res://resources/topping_resources/ChiliFlakes.tres"),
	"Cheese": preload("res://resources/topping_resources/Cheese.tres"),
	"Chives": preload("res://resources/topping_resources/Chives.tres"),
	"Bacon": preload("res://resources/topping_resources/Bacon.tres"),
	"Fries": preload("res://resources/topping_resources/Fries.tres"),
	"Jalapenos": preload("res://resources/topping_resources/Jalapenos.tres")
}

var base_alien_dict = { #keys are names, values are bias dictionaries 
	"YellowAlien": preload("res://resources/alien_bias_resources/YellowAlien.tres").bias,
	"PurpleAlien": preload("res://resources/alien_bias_resources/PurpleAlien.tres").bias,
	"GreenAlien": preload("res://resources/alien_bias_resources/GreenAlien.tres").bias
}

var modifiers_dict = { #used to randomly select modifiers, calculate bias using topping attributes, then displaying proper sprite
	"Colour" : ["Red", "Yellow", "Green"],
	"Consistency" : ["Liquid", "Solid", "Sprinkles"],
	"Flavor" : ["Salty", "Spicy", "Zesty"]
}

var overall_bias_matrix : Dictionary
var selected_modifiers_dict : Dictionary
var selected_alien_name
var num_modifiers := 0 #i want this variable editable by parent node - I want to control how many modifiers there are!
var maximum_avaliable_modifiers = 3 #current number of modifiers implemented!
var currently_animating = false
var starting_position = position
var anim_time_passed = 0.0

func _ready() -> void:  #-> for testing!!
	randomize()
	#test()
	pass

func _process(delta: float) -> void: #used for walk in animations
	if currently_animating:
		match selected_alien_name:
			"PurpleAlien":
				purple_entry(delta)
			"YellowAlien":
				yellow_entry(delta)
			"GreenAlien":
				green_entry(delta)

func test():
	initialize_alien("ran color", 5)
	animate_alien_walk_in()

func print_alien():
	print(selected_alien_name, " ", selected_modifiers_dict)

func print_bias():
	print(overall_bias_matrix)

func alien_name():
	return selected_alien_name

func get_bias():
	return overall_bias_matrix.duplicate(true)

func initialize_alien(color : String, num : int) -> void:
	if num > 3: num = maximum_avaliable_modifiers
	num_modifiers = num
	generate_alien(color)
	set_bias_dict()

func generate_alien(color : String): #shows appropriate sprites and initializes selected_modifiers_dict
	#avaliable inputs are "purple", "yellow", and "green"
	#if input is none of 3 base inputs, a random color will be chosen (not sure if Ill need this functionality but ill add it anyway)
	if color == "purple":
		selected_alien_name = "PurpleAlien"
	elif color == "yellow":
		selected_alien_name = "YellowAlien"
	elif color == "green":
		selected_alien_name = "GreenAlien"
	else:
		selected_alien_name = base_alien_dict.keys().pick_random()

	var selected_modifier_array := []
	var avaliable_modifiers_array = modifiers_dict.keys().duplicate(true)
	var alien_chosen = get_node(selected_alien_name)
	alien_chosen.show()
	#for now I am randomizing num_modifiers for testing. in practice I want to be able to set num_modifiers
	#in parent node to control 'difficulty' of the alien
	#num_modifiers = randi_range(0, modifiers_dict.size())

	#this loop will populate selected_mods by popping elements from the copied modifiers list
	for i in range(0, num_modifiers):
		if avaliable_modifiers_array.size() == 0: break
		var ran_index = randi() % avaliable_modifiers_array.size()
		selected_modifier_array.push_back( avaliable_modifiers_array.pop_at(ran_index) )
	
	#i know these loops can be condensed but im tired and this works so i dont care
	for modifier_type in selected_modifier_array:
		var modifier_type_node = alien_chosen.get_node(modifier_type)
		var selected_modifier = modifiers_dict[modifier_type].pick_random()
		var modifier_node = modifier_type_node.get_node(selected_modifier)
		modifier_node.show()
		#populating selected_modifiers_dict
		selected_modifiers_dict[modifier_type] = selected_modifier
	
	#print(selected_modifiers_dict)

func set_bias_dict():
	overall_bias_matrix = base_alien_dict[selected_alien_name].duplicate(true)
	#print(overall_bias_matrix)
	for modifier_category in selected_modifiers_dict:
		var thing_to_modify = selected_modifiers_dict[modifier_category]
		#modifier type is the attribute of topping, modifier is the value stored in the field
		for topping_name in toppings:
			var topping_object = toppings[topping_name]
			#print(thing_to_modify," : ", topping_name, " : Topping's value:", topping_object.get(modifier_category))
			
			if topping_object.get(modifier_category) == thing_to_modify: #if the topping is of the right category:
				overall_bias_matrix[topping_name] = overall_bias_matrix[topping_name] + 2 #changing this +X to dif number changes modifier weighting!
	#print(overall_bias_matrix)


func animate_alien_walk_in():
	show()
	position.x = -220
	currently_animating = true

func yellow_entry(delta : float):
	var velocity_right = Vector2(300,0)
	anim_time_passed += delta
	var wobble_percent = sin(anim_time_passed*2.5 + PI/1.4)/5
	
	if position.distance_to(starting_position) > 10:
		position += delta * velocity_right
		rotation = wobble_percent
	elif position.distance_to(starting_position) > 1:
		position = position.lerp(starting_position, delta*10)
		rotation = lerp_angle(rotation, 0, delta*10)
	else:
		position = starting_position
		currently_animating = false
		anim_time_passed = 0.0 

func wobble_sprite(offset: float, phase_shifty : float) -> void: #setting phase shift to 1 seems to solve issue for some reason
	var time = Time.get_ticks_msec() / 1000.0 
	var wobble_percent = sin(time *2.5 + phase_shifty) 
	rotation = offset * wobble_percent

func green_entry(delta: float):
	var velocity_right = Vector2(300, 0)
	var amplitude = 40
	anim_time_passed += delta
	var vertical_offset = amplitude * sin(2*PI * anim_time_passed + PI/2)
	
	if position.distance_to(starting_position) > 40:
		position += velocity_right * delta
		position.y = starting_position.y + vertical_offset
	elif position.distance_to(starting_position) > 1:
		position = position.lerp(starting_position, delta* 10)
		position += Vector2(20,0) * delta
	else:
		position = starting_position
		currently_animating = false
		anim_time_passed = 0.0 

func purple_entry(delta : float):
	var velocity_right = Vector2(200, 0)
	var amplitude = 40
	anim_time_passed += delta
	var vertical_offset = -1 * amplitude * abs(sin(2*PI * anim_time_passed + PI/2))
	
	if position.distance_to(starting_position) > 40:
		position += velocity_right * delta *1.5
		position.y = starting_position.y + vertical_offset
	elif position.distance_to(starting_position) > 1:
		position = position.lerp(starting_position, delta* 10)
		position += Vector2(20,0) * delta
	else:
		position = starting_position
		currently_animating = false
		anim_time_passed = 0.0 
