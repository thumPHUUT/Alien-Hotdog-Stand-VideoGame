extends Node2D

var new_level_scene = preload("res://world.tscn")
var rent_screen_scene = preload("res://rent_screen.tscn")

var rent_screen
var current_level
#variables for scaling!
var base_rent = 15.0 #starting value!
var rent_scaler = 0.7 #will scale exponentially btw
var rent
var num_aliens
var num_mods
var level_counter = 0 #start at level 0, i.e. the upgrade screen
#player values (scaling of scoring handled by scoring node)
var money = 0


func _ready() -> void:
	#need one pre_increment while level_counter is at 0
	increment_difficulty()
	$Background.z_index = -2


func _on_next_level():
	#difficulty is scaled in on_level_finished and when game initialized, not here
	$RentLabel.show()
	if $UpgradeScreen.visible:
		money = $UpgradeScreen.get_money()
	
	current_level = new_level_scene.instantiate()
	current_level.initialize(money, int(round(num_aliens)), num_mods)
	
	$StartMenu.hide()
	$UpgradeScreen.hide()
	add_child(current_level)


func increment_difficulty():
	num_aliens = 3.0 + 0.5 * level_counter
	num_mods = 1 + 2 * level_counter
	rent = base_rent * (1 + rent_scaler*level_counter)**2
	level_counter += 1
	update_rent_label()


func update_rent_label():
	$RentLabel.text = "Next Days Rent: "+ str( int( round (rent) )) +"g"


func _on_level_finished():
	money = current_level.get_money()
	#queue free the old new_level
	#instantiate and go to rentscreen
	
	rent_screen = rent_screen_scene.instantiate()
	current_level.queue_free()
	add_child(rent_screen)
	rent_screen.initialize(money, rent) 
	money -= rent
	
	increment_difficulty()


func _on_game_over():
	rent_screen.queue_free()
	#queue_free rent screen
	#display game over message, go to start screen
	
	$GameOverLabel.show()
	await get_tree().create_timer(1.5).timeout
	$GameOverLabel.hide()
	$StartMenu.show()


func _on_rent_paid():
	rent_screen.queue_free()
	#queue_free rent screen
	#go to upgrade screen
	
	#$ScoringNode.print_values()
	
	$UpgradeScreen.show()
	$UpgradeScreen.set_money(money)
