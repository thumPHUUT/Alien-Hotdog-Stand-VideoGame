extends Node2D

#add script to make the thing upgrade when you press the buttons! - for now change the local scoringNode
#later change these to sibling references. Make sure that the appropriate sections of the labels update appropriately!

signal next_level

var money = 0
var power_cost_scaler = 2 #this is a multiplicative scaler
var default_cost_scaler = 2 #this is a multiplicative scaler

var base_power_cost = 20
var base_default_cost = 15
var base_power_val = 1.50
var base_default_val = 1.0
var base_power_scaler = 0.5
var base_default_scaler = 0.5

var mult_power_cost = 30
var mult_default_cost = 20
var mult_power_val = 1.25
var mult_default_val = 1.0
var mult_power_scaler = 0.25
var mult_default_scaler = 0.25

var tip_power_cost = 40
var tip_default_cost = 25
var tip_power_val = 1.75
var tip_default_val = 1.0
var tip_power_scaler = 0.75
var tip_default_scaler = 0.2

var ScoringNode

func set_money(new_money : int):
	money = new_money
	update_money_label()

func get_money():
	return money

func _ready() -> void:
	ScoringNode = get_parent().get_node("ScoringNode")
	connect("next_level", Callable(get_parent(), "_on_next_level"))

func update_money_label():
	$MoneyLabel.text = "Current Money: "+str(money)

func _on_base_power_pressed() -> void:
	if money >= base_power_cost:
		ScoringNode.scale_base_power(base_power_scaler)
		money -= base_power_cost
		base_power_cost *= power_cost_scaler
		base_power_val += base_power_scaler
		update_money_label()
		$BasePower.text = "Upgrade -Sure Shot Approach-
("+str(base_power_val)+"x -> "+str(base_power_val+base_power_scaler)+"x Base Payout)
- "+str(base_power_cost)+"g -"


func _on_mult_power_pressed() -> void:
	if money >= mult_power_cost:
		ScoringNode.scale_mult_power(mult_power_scaler)
		money -= mult_power_cost
		mult_power_cost *= power_cost_scaler
		mult_power_val += mult_power_scaler
		update_money_label()
		$MultPower.text = "Upgrade -All Rounder Power-
("+str(mult_power_val)+"x -> "+str(mult_power_val+mult_power_scaler)+"x Total Payout)
- "+str(mult_power_cost)+"g -"


func _on_tip_power_pressed() -> void:
	if money >= tip_power_cost:
		ScoringNode.scale_tip_power(tip_power_scaler)
		money -= tip_power_cost
		tip_power_cost *= power_cost_scaler
		tip_power_val += tip_power_scaler
		update_money_label()
		$TipPower.text = "Upgrade -Premium Service Technique-
("+str(tip_power_val)+"x -> "+str(tip_power_val+tip_power_scaler)+"x Tip Payout)
- "+str(tip_power_cost)+"g -"


func _on_base_default_pressed() -> void:
	if money >= base_default_cost:
		ScoringNode.scale_base_default(base_default_scaler)
		money -= base_default_cost
		base_default_cost *= default_cost_scaler
		base_default_val += base_default_scaler
		update_money_label()
		$BaseDefault.text = "Increase Default Base Payout
("+str(base_default_val)+"x -> "+str(base_default_val+base_default_scaler)+"x)
- "+str(base_default_cost)+"g -"


func _on_mult_default_pressed() -> void:
	if money >= mult_default_cost:
		ScoringNode.scale_mult_default(mult_default_scaler)
		money -= mult_default_cost
		mult_default_cost *= default_cost_scaler
		mult_default_val += mult_default_scaler
		update_money_label()
		$MultDefault.text = "Increase Default Total Payout
("+str(mult_default_val)+"x -> "+str(mult_default_val+mult_default_scaler)+"x)
- "+str(mult_default_cost)+"g -"


func _on_tip_default_pressed() -> void:
	if money >= tip_default_cost:
		ScoringNode.scale_mult_default(tip_default_scaler)
		money -= tip_default_cost
		tip_default_cost *= default_cost_scaler
		tip_default_val += tip_default_scaler
		update_money_label()
		$TipDefault.text = "Increase Default Tip Payout
("+str(tip_default_val)+"x -> "+str(tip_default_val+tip_default_scaler)+"x)
- "+str(tip_default_cost)+"g -"


func _on_next_level_pressed() -> void:
	emit_signal("next_level")
	#go to next level!
