extends Node2D

signal next_level

var hint_1 = "Welcome to the Alien Hotdog Stand! Wade your way through customers from three different alien factions, 
			all with individual ingredient preferences and special preference modifiers indicated by differences in 
			their attire and quirks!"
var hint_2 = "The payout recievced from each alien can be influenced in three different ways: -- a base payout -- 
			that is the same regardless of your customer’s preferences -- a tip payout -- that is heavily 
			influenced by your customers preferences -- and an overall multiplier -- that will provide a small
			boost to your payout from both your base and tip pay"
var hint_3 = "Persuasive Powers: During each day you can spend money to receive a one time modification to one 
			aspect of your scoring for the next customer, the base, tip, or overall payout. These powers 
			can be used all at once but must be purchased separately. They increase in cost with each use 
			but reset at the end of the day, so be sure to get your use of them!"
var hint_4 = "Between each day you pay an increasing amount of rent to keep your intergalactic 
			shop open. Afterwards you are able to use the rest of your money to upgrade different
			 aspects of your base scoring and powers to increase the amount you earn from each 
			of your celestial sales in the future!"
var hint_5 = "If you ever don’t think your customer will love your latest hotdog, simply throw it off screen 
			to receive a new bun and sausage!"
var hint_6 = "Aliens like to get their fair share of toppings, but be careful of overwhelming their taste buds!
			Expect lower tips whenever too few or too many toppings are provided!"
var hint_7 = "Aliens can be picky eaters! If your customer has something different about their attire, expect
			them to pay more for their favourites, but also tip less for items they dont prefer. Its useful to 
			figure out each aliens base preferences as these shared favourites wont suffer penalties for not being 
			a part of their individual modifier categories!"
var hint_array = [hint_1, hint_2, hint_7, hint_3, hint_4, hint_5, hint_6]
var current_index = 0

func _ready() -> void:
	#if i want I can randomize
	update_hint_label(current_index) #starts at first hint
	connect("next_level", Callable(get_parent(), "_on_next_level"))
	
	await get_tree().create_timer(1.3).timeout
	$AnimatedTitle.show()
	$AnimatedTitle.play("windup")

func update_hint_label(index : int): #index goes from 0 to hint_array.size() -1
	$HintLabel.text = hint_array[index]

func _on_start_button_pressed() -> void:
	hide()
	emit_signal("next_level")

func _on_next_button_pressed() -> void:
	current_index = (current_index +1 ) % hint_array.size()
	update_hint_label(current_index)

func _on_prev_button_pressed() -> void:
	current_index = (hint_array.size() + current_index - 1 ) % hint_array.size()
	update_hint_label(current_index)



func _on_animated_title_animation_looped() -> void:
	if $AnimatedTitle.animation == "windup":
		$AnimatedTitle.play("default")
