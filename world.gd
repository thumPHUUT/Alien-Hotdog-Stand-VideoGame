extends Node2D

signal level_finished

var ScoringNode

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
var animate_payout = false
var starting_tip_label_pos 
var starting_base_label_pos
var target_tip_pos
var target_base_pos
var sausage
var bun
var current_hotdog
var current_alien
var current_queue
var level_started = false #used to prevent start button from being repeatably pressed
var total_money = 0

var tip_power_current_cost = 35
var tip_power_default_cost = 35
var tip_power_val

var base_power_current_cost = 5
var base_power_default_cost = 5
var base_power_val = 0

var mult_power_current_cost = 10
var mult_power_default_cost = 10
var mult_power_val

var tip_power_on = false
var base_power_on = false
var mult_power_on = false
#these two are set to tester values
var num_aliens := 3
var num_mods := 7
#var alternate_hotdog #eventually use a sister variable to make the shadow modifier work. leaving this here for later
#var num_hotdogs #can use this with sister var to track number of dogs that are supposed to exist so that the correct num
				 #of dogs can be recycled, so when the modifier ends we dont permemantly have 2 hotodgs

func _process(delta: float) -> void:
	var speed = 3
	if animate_payout:
		$MoneyLabels/RecentBaseLabel.show()
		$MoneyLabels/RecentTipLabel.show()
		#position = position.lerp(mouse_pos, follow_speed* delta)
		$MoneyLabels/RecentTipLabel.position = $MoneyLabels/RecentTipLabel.position.lerp(target_tip_pos, speed*delta)
		$MoneyLabels/RecentBaseLabel.position = $MoneyLabels/RecentBaseLabel.position.lerp(target_base_pos, speed*delta)
		if $MoneyLabels/RecentTipLabel.position.y < starting_tip_label_pos.y - 70:
			animate_payout = false
			await get_tree().create_timer(0.5).timeout
			$MoneyLabels/RecentTipLabel.position = starting_tip_label_pos
			$MoneyLabels/RecentBaseLabel.position = starting_base_label_pos
			$MoneyLabels/RecentBaseLabel.hide()
			$MoneyLabels/RecentTipLabel.hide()

func _ready() -> void:
	starting_tip_label_pos = $MoneyLabels/RecentTipLabel.position
	starting_base_label_pos = $MoneyLabels/RecentBaseLabel.position
	target_tip_pos = starting_tip_label_pos - Vector2(0, 105)
	target_base_pos = starting_base_label_pos - Vector2(0, 105)
	
	topping_dictionary = default_topping_dictionary.duplicate(true)
	$NextLevelButton.hide()
	connect("level_finished", Callable(get_parent(), "_on_level_finished"))

	ScoringNode = get_parent().get_node("ScoringNode")
	
	var power_value_dict = ScoringNode.return_power_values()
	tip_power_val = power_value_dict["tip"]
	base_power_val = power_value_dict["base"]
	mult_power_val = power_value_dict["mult"]
	update_power_labels()


func initialize(money : int, number_aliens : int, number_mods : int):
	total_money = money
	num_aliens = number_aliens
	num_mods = number_mods
	$MoneyLabels/TotalMoneyLabel.text = "Total Money: "+str(total_money)+"g"

#START BUTTON
func _on_button_pressed() -> void: #start game button
	#used as a temporary starter for alien queue! Makes a simple queue as specified below!
	if !level_started:
		instantiate_sausage_and_bun()
		
		level_started = true
		if current_alien != null:
			current_alien.queue_free()
		
		$AlienQueue.initialize_new_queue(num_aliens, num_mods)
		current_queue = $AlienQueue.get_alien_queue().duplicate()
		$AlienRemainingLabel.text = "Remaining Aliens: " + str(current_queue.size())
		current_alien = current_queue.pop_back()
		display_current_alien()

func get_money():
	return total_money

func instantiate_sausage_and_bun():
	instantiate_bun()
	instantiate_sausage()

func instantiate_bun():
	if bun != null: bun.queue_free()
	bun = bun_scene.instantiate()
	bun.global_position = Vector2(310, 510)
	add_child(bun)

func instantiate_sausage():
	if sausage != null: sausage.queue_free()
	sausage = sausage_scene.instantiate()
	sausage.global_position = Vector2(650, 510)
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

func _on_sausage_off_screen():
	await get_tree().create_timer(0.2).timeout
	instantiate_sausage()

func _on_bun_off_screen():
	await get_tree().create_timer(0.2).timeout
	instantiate_bun()

func _on_hotdog_off_screen(): #need to despawn hotdog and then respawn bun and sausage
	reset_hotdog(0.5)


func reset_hotdog(wait_time : float):
	current_hotdog.queue_free()
	current_hotdog = null
	topping_dictionary = default_topping_dictionary.duplicate(true)
	await get_tree().create_timer(wait_time).timeout #oneshot timer
	instantiate_sausage_and_bun()

func _on_scoring_detector_body_entered(body: Node2D) -> void:
	if body.name == "HotDog" && current_alien != null:
		var recent_payout_dict = ScoringNode.payout(topping_dictionary, current_alien.get_bias())
		var score = recent_payout_dict["payout"]
		score = int(round(score))
		tip_power_on = false
		base_power_on = false
		mult_power_on = false
		
		#print(topping_dictionary)
		current_alien.queue_free()
		reset_hotdog(0.5)
		
		total_money += score
		$MoneyLabels/TotalMoneyLabel.text = "Total Money: "+str(total_money)+"g"
		$MoneyLabels/RecentMoneyLabel.text = "Most Recent Payout: "+str(score)+"g"
		$AlienRemainingLabel.text = "Remaining Aliens: "+ str(current_queue.size())
		animate_recent_payout(recent_payout_dict)
		
		if current_queue.size() > 0:
			current_alien = current_queue.pop_back()
			await get_tree().create_timer(0.2).timeout
			display_current_alien()
		else: #queue empty
			await get_tree().create_timer(0.5).timeout
			$NextLevelButton.show()

func animate_recent_payout(payout_dict : Dictionary):
	var base = round(payout_dict["base"])
	var tip = round(payout_dict["tip"])
	
	$MoneyLabels/RecentTipLabel.text = "+"+str(tip)+"g Tip"
	$MoneyLabels/RecentBaseLabel.text = "+"+str(base)+"g Base"
	animate_payout = true

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
		ScoringNode.base_power_on()
		total_money -= base_power_current_cost
		$MoneyLabels/TotalMoneyLabel.text = "Total Money: "+str(total_money)
		base_power_current_cost += base_power_default_cost
		update_power_labels()

func _on_overall_mult_power_pressed() -> void:
	if total_money >= mult_power_current_cost && !mult_power_on:
		mult_power_on = true
		ScoringNode.mult_power_on()
		total_money -= mult_power_current_cost
		$MoneyLabels/TotalMoneyLabel.text = "Total Money: "+str(total_money)
		mult_power_current_cost += mult_power_default_cost
		update_power_labels()

func _on_tip_power_pressed() -> void:
	if total_money >= tip_power_current_cost && !tip_power_on:
		tip_power_on = true
		$ScoringNode.tip_power_on()
		total_money -= tip_power_current_cost
		$MoneyLabels/TotalMoneyLabel.text = "Total Money: "+str(total_money)
		tip_power_current_cost += tip_power_default_cost
		update_power_labels()


func _on_next_level_button_pressed() -> void:
	emit_signal("level_finished")


func update_power_labels():
	$PowerButtons/TipPower.text = str(tip_power_val)+"x Tip Payout
- costs "+str(tip_power_current_cost)+"g -"
	
	$PowerButtons/OverallMultPower.text = str(mult_power_val)+"x Total Payout
- costs "+str(mult_power_current_cost)+"g -"
	
	$PowerButtons/BasePayPower.text = str(base_power_val)+"x Base Payout
		- costs "+str(base_power_current_cost)+"g -"
