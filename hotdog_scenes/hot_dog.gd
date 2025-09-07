extends RigidBody2D

signal toppings_updated 
signal hotdog_off_screen

var follow_speed := 10 #will adjust smoothness of lerp
var is_mouse_inside := false
var just_instantiated := false
var topping_dictionary = {
	"Ketchup" : false,
	"Mustard" : false,
	"Relish" : false,
	"ChiliFlakes" : false,
	"Cheese" : false,
	"Chives" : false,
	"Bacon" : false,
	"Fries" : false,
	"Jalapenos" : false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#this allows the hotdog to stay held once sausage and bun are combined
	#100 is a magic number that can be changed depending on how far away I want the hotdog to continue to be 
	#held once instantiated. if you get rid of this condition, holding mouse down snaps hotdog to it
	#regardless of where mouse is, and its weird!!
	if (get_global_mouse_position() - global_position).length() < 100:
		is_mouse_inside = true
	just_instantiated = true;
	
	call_deferred("update_topping_visibility") #waits unitl all children initialized before calling!
	
	connect("toppings_updated", Callable(get_parent(), "_on_toppings_updated"))
	connect("hotdog_off_screen", Callable(get_parent(), "_on_hotdog_off_screen"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_mouse_inside:
		set_sleeping(false)

func _integrate_forces(state):
	if just_instantiated:
		#make it wiggle a little or smt during instantiation
		state.apply_central_impulse(Vector2(0,-150.0))
		just_instantiated = false

	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position)
	var distance_to_mouse = direction.length()
	var normalized_direction = direction.normalized()
	var target_velocity = 300 * normalized_direction
	
	if Input.is_action_pressed("left_mouse") && is_mouse_inside:
		if direction.length() > 1000:
			direction = direction.normalized()*1000
		
		if distance_to_mouse > 10: #magic number to stop vibrating around mouse cursor
			state.linear_velocity = lerp(state.linear_velocity, target_velocity, follow_speed * state.step)
		state.apply_force(direction *100)
		#I know there is be a way to set the sausage position to mousecursor when its close
		#enough, but i think the small bouncing is cute


func _on_area_2d_mouse_entered() -> void:
	if !Input.is_action_pressed("left_mouse"):
		is_mouse_inside = true

func _on_area_2d_mouse_exited() -> void:
	if is_mouse_inside && Input.is_action_pressed("left_mouse"):
		is_mouse_inside = true
	else:
		is_mouse_inside = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	var topping_name := "default name (not in dictionary )"
	if area.name == "MouseHitBox":
		#collided with mousehitbox, not the topping hitbox - set the topping name to something that isnt in the dict
		pass
	else:
		topping_name = area.get_parent().name
	#evaluating toppings for bias calculation
	#print("Entered:", topping_name)
	if topping_dictionary.has( topping_name): #if name is a key in dict, add topping - there shouldnt be a bacon edgecase
		topping_dictionary[topping_name] = true
		update_topping_visibility()
		#send topping updated signal to world node
		emit_signal("toppings_updated")

func return_topping_dictionary() -> Dictionary:
	return topping_dictionary.duplicate()
	#to be called by parent world node
	
func update_topping_visibility() -> void:
	#print("Current toppings:", topping_dictionary)
	for key in topping_dictionary:
		if key == "Bacon": #specific case for bacon as it has a front and back sprite!
			var bacon_back = get_node_or_null("BaconBack")
			var bacon_front = get_node_or_null("BaconFront")
			
			if bacon_back:
				bacon_back.visible = topping_dictionary[key]
			if bacon_front:
				bacon_front.visible = topping_dictionary[key]
			continue 
		 
		var sprite = get_node_or_null(key)
		if sprite:
			sprite.visible = topping_dictionary[key]
		#else:
		#	print("Node not found for key:", key)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("hotdog_off_screen")
