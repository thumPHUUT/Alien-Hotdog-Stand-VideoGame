extends RigidBody2D

signal sausage_bun_merged #used for sausage bun merging
var follow_speed := 10 #will adjust smoothness of lerp
var is_mouse_inside := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("sausage_bun_merged", Callable(get_parent(), "_on_sausage_bun_merged"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_mouse_inside:
		set_sleeping(false)

func _integrate_forces(state):
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position)
	var distance_to_mouse = direction.length()
	var normalized_direction = direction.normalized()
	var target_velocity = 300 * normalized_direction
	
	if Input.is_action_pressed("left_mouse") && is_mouse_inside:
		
		if direction.length() > 1000:
			direction = direction.normalized()*1000
		
		if distance_to_mouse > 10:
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Bun"):
		emit_signal("sausage_bun_merged", self, body)  # Notify World node
