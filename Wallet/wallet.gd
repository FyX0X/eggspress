extends Node

signal money_changed(new_amount: int)

var money : int = 0
var chicken_value : int = 10

func _init() -> void:
	pass

func change_money(amount : int) -> void:
	money += amount
	money_changed.emit(money)

func is_buyable(price : int) -> bool:
	return money >= price

func remove_money(price : int) -> bool:
	if money >= price:
		#Add the purchase of the upgrade
		change_money(-price)
		return true
	else:
		return false

func deliver_chickens(amount : int):
	change_money(amount * chicken_value)
