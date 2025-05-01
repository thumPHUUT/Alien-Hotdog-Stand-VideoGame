extends Node2D

@export var hotdog_scene: PackedScene  

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_sausage_bun_merged(body1, body2):
	var merge_position = (body1.global_position + body2.global_position) / 2  #midpoint
	
	# call_deferred ensures the call happens at a safe time during the physics queries/steps
	body1.call_deferred("queue_free")
	body2.call_deferred("queue_free")

	# call_defered should be used during instantiation aswell
	var hotdog = hotdog_scene.instantiate()
	hotdog.global_position = merge_position
	call_deferred("add_child", hotdog)
