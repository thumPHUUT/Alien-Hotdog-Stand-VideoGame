extends Node2D

signal hit_hotdog

var follow_speed := 10
var angular_follow_speed := 8
var is_mouse_inside := false
var starting_position
var starting_rotation := 0.0
var target_rotation := PI

func _ready() -> void:
	starting_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	#monitoring calls means will only add toppings when picked up - not when stationary
	if Input.is_action_pressed("left_mouse") && is_mouse_inside:
		$SauceHitBox.monitorable = true
		
		position = position.lerp(mouse_pos, follow_speed* delta)
		rotation = lerp_angle(rotation, target_rotation, angular_follow_speed*delta)
	else: #move back to starting position if not pressed + make i
		$SauceHitBox.monitorable = false
		
		position = position.lerp(starting_position, follow_speed*2.0/3.0* delta)
		rotation = lerp_angle(rotation, starting_rotation, angular_follow_speed*delta)


func _on_mouse_hit_box_mouse_entered() -> void:
	if !Input.is_action_pressed("left_mouse"):
		is_mouse_inside = true

func _on_mouse_hit_box_mouse_exited() -> void:
	if is_mouse_inside && Input.is_action_pressed("left_mouse"):
		is_mouse_inside = true
	else:
		is_mouse_inside = false

func _on_sauce_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "HotDog":
		emit_signal("hit_hotdog")
		#print("Entered: ", body.name)
