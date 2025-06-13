extends Node2D

@export var hotdog_scene: PackedScene
@export var sausage_scene: PackedScene 
@export var bun_scene: PackedScene

var topping_dictionary : Dictionary

var default_topping_dictionary= {
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
var current_hotdog
var current_alien
var current_queue
var total_money = 0
var tip_power_current_cost = 35
var tip_power_default_cost = 35
var base_power_current_cost = 5
var base_power_default_cost = 5
var mult_power_current_cost = 10
var mult_power_default_cost = 10
var tip_power_on = false
var base_power_on = false
var mult_power_on = false
#var alternate_hotdog #eventually use a sister variable to make the shadow modifier work. leaving this here for later
#var num_hotdogs #can use this with sister var to track number of dogs that are supposed to exist so that the correct num
				 #of dogs can be recycled, so when the modifier ends we dont permemantly have 2 hotodgs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$ToppingCounterLabel.text = "Topping Number: 0"
	topping_dictionary = default_topping_dictionary.duplicate(true)
	instantiate_sausage_and_bun()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func instantiate_sausage_and_bun():
	var bun = bun_scene.instantiate()
	var sausage = sausage_scene.instantiate()
	bun.global_position = Vector2(310, 510)
	sausage.global_position = Vector2(650, 510)

	add_child(bun)
	add_child(sausage)

func _on_sausage_bun_merged(body1, body2):
	var merge_position = (body1.global_position + body2.global_position) / 2  #midpoint
	
	# call_deferred ensures the call happens at a safe time during the physics queries/steps
	body1.call_deferred("queue_free")
	body2.call_deferred("queue_free")

	# call_defered should be used during instantiation aswell
	current_hotdog = hotdog_scene.instantiate()
	current_hotdog.global_position = merge_position
	call_deferred("add_child", current_hotdog)

func _on_toppings_updated():
	topping_dictionary = current_hotdog.return_topping_dictionary()
	var num = 0
	for key in topping_dictionary:
		if topping_dictionary[key] == true:
			num += 1
	$ToppingCounterLabel.text = "Topping Number: "+str(num)

func _on_hotdog_off_screen(): #need to despawn hotdog and then respawn bun and sausage
	reset_hotdog(0.5)

func reset_hotdog(wait_time : float):
	current_hotdog.queue_free()
	current_hotdog = null
	$ToppingCounterLabel.text = "Topping Number: 0"
	topping_dictionary = default_topping_dictionary.duplicate(true)
	await get_tree().create_timer(wait_time).timeout #oneshot timer
	instantiate_sausage_and_bun()

func _on_scoring_detector_body_entered(body: Node2D) -> void:
	if body.name == "HotDog" && current_alien != null:
		var score = $ScoringNode.payout(topping_dictionary, current_alien.get_bias())
		score = int(round(score))
		tip_power_on = false
		base_power_on = false
		mult_power_on = false
		
		#print(topping_dictionary)
		current_alien.queue_free()
		reset_hotdog(0.5)
		
		total_money += score
		$TotalMoneyLabel.text = "Total Money: "+str(total_money)
		$RecentMoneyLabel.text = "Most Recent Payout: "+str(score)
		
		if current_queue.size() > 0:
			current_alien = current_queue.pop_back()
			await get_tree().create_timer(0.2).timeout
			display_current_alien()

func _on_button_pressed() -> void: #start game button
	#used as a temporary starter for alien queue! Makes a simple queue as specified below!
	if current_alien != null:
		current_alien.queue_free()
	
	$AlienQueue.initialize_new_queue(10, 25)
	current_queue = $AlienQueue.get_alien_queue().duplicate()
	current_alien = current_queue.pop_back()
	display_current_alien()

func display_current_alien():
	current_alien.z_index = -1

	call_deferred("add_child", current_alien)
	current_alien.animate_alien_walk_in()
	#current_alien.print_bias()

func print_alien_queue():
	for alien in current_queue:
		alien.print_alien()


func _on_base_pay_power_pressed() -> void:
	if total_money >= base_power_current_cost && !base_power_on:
		base_power_on = true
		$ScoringNode.base_power_on()
		total_money -= base_power_current_cost
		$TotalMoneyLabel.text = "Total Money: "+str(total_money)
		base_power_current_cost += base_power_default_cost
		$PowerButtons/BasePayPower.text = "1.5X Base Payout
- costs "+str(base_power_current_cost)+"g -"
		

func _on_overall_mult_power_pressed() -> void:
	if total_money >= mult_power_current_cost && !mult_power_on:
		mult_power_on = true
		$ScoringNode.mult_power_on()
		total_money -= mult_power_current_cost
		$TotalMoneyLabel.text = "Total Money: "+str(total_money)
		mult_power_current_cost += mult_power_default_cost
		$PowerButtons/OverallMultPower.text = "1.25X Total Payout
- costs "+str(mult_power_current_cost)+"g -"

func _on_tip_power_pressed() -> void:
	if total_money >= tip_power_current_cost && !tip_power_on:
		tip_power_on = true
		$ScoringNode.tip_power_on()
		total_money -= tip_power_current_cost
		$TotalMoneyLabel.text = "Total Money: "+str(total_money)
		tip_power_current_cost += tip_power_default_cost
		$PowerButtons/TipPower.text = "1.75X Tip Payout
- costs "+str(tip_power_current_cost)+"g -"
