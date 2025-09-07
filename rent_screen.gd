extends Node2D

signal rent_paid
signal game_over

var rent
var money
var animating = false
var anim_time_passed = 0

func _ready() -> void:
	connect("game_over", Callable(get_parent(), "_on_game_over"))
	connect("rent_paid", Callable(get_parent(), "_on_rent_paid"))
	#test()

func _process(delta: float) -> void:
	if animating:
		var velocity_right = Vector2(320, 0)
		var amplitude = 4
		anim_time_passed += delta
		var vertical_offset = amplitude * sin(2*PI * anim_time_passed + PI/2)
	
		$Rent.position += velocity_right * delta
		$Rent.position.y += vertical_offset
		if anim_time_passed > 5:
			animating = false

func test():
	initialize(100, 15)

func initialize(given_money : int, given_rent : int):
	rent = given_rent * -1
	money = given_money
	$Rent/Label.text = str(rent)
	$MoneyLabel.text = str(money)+"g"
	await get_tree().create_timer(0.7).timeout
	animating = true

func _on_rent_hit_box_area_entered(_area: Area2D) -> void:
	animating = false
	$Rent.hide()
	money += rent
	$MoneyLabel.text = str(money)+"g"
	
	await get_tree().create_timer(0.5).timeout
	if money < 0:
		emit_signal("game_over")
	else:
		emit_signal("rent_paid")
