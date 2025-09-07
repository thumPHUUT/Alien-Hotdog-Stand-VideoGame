extends Node2D

var base_pay := 1.0
var default_base_scaler := 1.0
var power_base_scaler := 1.5

var muliplier := 10.0
var default_mult_scaler := 1.0
var power_mult_scaler := 1.25

var tip : float
var default_tip_scaler := 1.0
var power_tip_scaler := 1.75

var tip_power := false
var mult_power := false
var base_power := false


func return_power_values():
	return {"base": power_base_scaler, "mult" : power_mult_scaler, "tip": power_tip_scaler}


func print_values():
	var text = "--------------------------
base_default: "+ str(default_base_scaler)+ " base_power: "+ str(power_base_scaler) +"
mult_default: "+ str(default_mult_scaler)+ " mult_power: "+ str(power_mult_scaler) +"
tip_default: "+ str(default_tip_scaler)+ " tip_power: "+ str(power_tip_scaler) + "
--------------------------"
	print(text)

func payout(hotdog_dict : Dictionary, bias_dict : Dictionary):
	tip = get_tip(hotdog_dict, bias_dict)
	
	var base_scaler = default_base_scaler
	var mult_scaler = default_mult_scaler
	var tip_scaler = default_tip_scaler
	
	if tip_power:
		tip_scaler *= power_tip_scaler
		tip_power = false
	if mult_power:
		mult_scaler *= power_mult_scaler
		mult_power = false
	if base_power:
		base_scaler *= power_base_scaler
		base_power = false
	
	tip = tip * tip_scaler * (muliplier * mult_scaler)
	var base = base_pay * base_scaler * (muliplier * mult_scaler)
	var total = tip + base

	return {"payout" : total, "base": base, "tip": tip}



func get_tip(hotdog_dict : Dictionary, bias_dict : Dictionary):
	var absolute_score = 0
	var score : float
	var counter = 0
	for topping in hotdog_dict:
		if hotdog_dict[topping] == true:
			absolute_score += bias_dict[topping]
			counter += 1
	if counter == 0 || absolute_score == 0:
		return 0.0
	
	score = float(absolute_score) / counter
	if counter < 3:
		score = score /8
	elif counter > 6:
		score = score /2
	return score

func tip_power_on():
	tip_power = true

func mult_power_on():
	mult_power = true

func base_power_on():
	base_power = true


func scale_tip_power(num : float):
	power_tip_scaler += num

func scale_mult_power(num : float):
	power_mult_scaler += num

func scale_base_power(num : float):
	power_base_scaler += num


func scale_tip_default(num : float):
	default_tip_scaler += num

func scale_mult_default(num : float):
	default_mult_scaler += num

func scale_base_default(num : float):
	default_base_scaler += num
