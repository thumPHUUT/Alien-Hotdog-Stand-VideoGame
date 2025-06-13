extends Node2D

signal hit_hotdog

var follow_speed := 10
var angular_follow_speed := 8
var wobble_offset := 0.8
var is_mouse_inside := false
var starting_position
var starting_rotation := 0.0
var target_rotation := PI
var phase_shift = 0.0
var phase_shift_set := false

func _ready() -> void:
	starting_position = position

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	if Input.is_action_pressed("left_mouse") && is_mouse_inside:
		if not phase_shift_set:
			#set phase shift to a current value
			phase_shift = fmod( Time.get_ticks_msec() / 1000.0 , 2*PI)
			phase_shift_set = true
		
		$ToppingHitBox.monitorable = true
		var wobble_offset_multiplier = clamp((position - mouse_pos ).length()/50, 0.0, 1 ) #div by 50 makes the clamp happen over longer time/more smoothly
		position = position.lerp(mouse_pos, follow_speed* delta)
		wobble_sprite(wobble_offset * wobble_offset_multiplier, phase_shift) # wobble gets less as reaches to mouse
	else: 
		if phase_shift_set:
			phase_shift_set = false
		$ToppingHitBox.monitorable = false
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

func _on_topping_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "HotDog":
		emit_signal("hit_hotdog")
		#print("Entered: ", body.name)
		
func wobble_sprite(offset: float, phase_shifty : float) -> void: #setting phase shift to 1 seems to solve issue for some reason
	var time = Time.get_ticks_msec() / 1000.0 
	var wobble_percent = sin(time * angular_follow_speed/2 + phase_shifty) 
	rotation = offset * wobble_percent
