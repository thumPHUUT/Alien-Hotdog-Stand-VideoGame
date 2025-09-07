extends Node2D

var alien_queue : Array
var num_aliens := 0 #decidied by parent node
var total_modifiers_in_queue := 0 #this is what scales difficulty
var maximum_avaliable_modifiers = 3 #there is also a last ditch check in alien script to prevent a value too high
									#still these values should be intentionally coordinated to prevent needless rng
									#if I change the number of base mods NEEDS TO EDIT CANDIDATE LIST IN BACKTRACKER

func _ready() -> void: #for testing only
	randomize()
	#test()

func test():
	initialize_new_queue(5, 8)
	print(alien_queue.size())
	initialize_new_queue(5, 45)
	print(alien_queue.size())
	print_modifiers_in_queue()
	display_aliens()

func initialize_new_queue(number_aliens :int, total_mods : int) -> void:
	alien_queue = []
	num_aliens = number_aliens
	total_modifiers_in_queue = total_mods
	#using avg mod per and num alien, populate alien queue
	populate_alien_array()

func get_alien_queue() -> Array:
	return alien_queue.duplicate(true)

func color_conflict(color_counter : Dictionary):
	var nums = color_counter.values()
	var keys = color_counter.keys()
	var min_val = nums.min()
	var max_val = nums.max()
	
	if max_val - min_val >= 3:
		return keys[nums.find(min_val) ] #returns key for the alien w minimum count!
	else:
		return "no conflict"

func populate_alien_array():
	var number_array : Array #will be of length num_aliens!
	var base_colors = ["yellow", "green", "purple"]
	var color_array = base_colors.duplicate(true)
	var color_counter = {"yellow": 1, "green": 1, "purple": 1} #used to track difference in numbers
	
	#populating number array
	number_array = get_random_combination(total_modifiers_in_queue, num_aliens)
	
	
	#populating color array
	while color_array.size() != num_aliens:
		if color_array.size() < num_aliens:#must add aditional elements
			var next_color  = base_colors.pick_random()
			#incrementing and then checking avoids bug where it doesnt validate the final alien added
			color_counter[next_color] += 1
			
			if color_conflict(color_counter) != "no conflict":
				var temp_color = next_color
				next_color = color_conflict(color_counter)
				color_counter[temp_color] -= 1
				color_counter[next_color] += 1
			
			color_array.push_back(next_color)
			
		elif color_array.size() > num_aliens:#must remove elements. resizing is most efficient way to remove last element
			color_array.shuffle() #color_arr shuffled to make removed color different each repeat iteration
			color_array.resize(color_array.size() - 1)
	
	number_array.shuffle()
	color_array.shuffle()
	
	#populating alien array
	for i in range(num_aliens):
		var num = number_array[i]
		var color = color_array[i]
		
		var alien_child_scene = preload("res://alien_scenes/alien.tscn")
		var alien_child = alien_child_scene.instantiate()
		alien_child.initialize_alien(color, num)
		alien_queue.push_back(alien_child)
		
		#print(number_array, " ", color_array)

func print_modifiers_in_queue():
	for alien in alien_queue:
		alien.print_alien()

func display_aliens():
	var screen_size = get_viewport_rect().size
	var horiz_spacing_per_alien = screen_size.x / num_aliens
	var vertical_location = screen_size.y /2
	var current_horiz_spot = horiz_spacing_per_alien/2
	
	for alien in alien_queue:
		alien.global_position = Vector2(current_horiz_spot, vertical_location)
		current_horiz_spot += horiz_spacing_per_alien
		call_deferred("add_child", alien)

#backtracking used to find single unique combination of values that add up to the target. 
#used for pseudo random modifier picking (queue always has target number of modifiers
func get_random_combination(target : int, num_vals : int) -> Array:
	if target > 3* num_vals: target = 3* num_vals
	var result : Array
	get_unique_sol([], result, target, num_vals, 0)
	return result[0]

func get_unique_sol(current : Array, result : Array, target : int, remaining : int, current_sum : int) -> bool:
	if remaining == 0:
		if current_sum == target:
			result.append(current) #instead of full backtracking, only need first random (valid) solution
			return true
		return false
	
	var candidate_additions = [0, 1, 2, 3] #corresponds to the number of base mods possible. will need dif call for behaviour mods
	candidate_additions.shuffle()
	
	for num in candidate_additions:
		if num + current_sum > target:
			continue
		
		current.append(num)
		if get_unique_sol(current, result, target, remaining - 1, current_sum + num): return true #if found return true - terminate backtrack
		#if not true, backtrack!
		current.pop_back()
	return false
