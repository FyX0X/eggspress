extends Node

signal money_changed(new_amount: int)
signal chicken_delivered_changed(new_amount: int)
signal win

var money : int = 0
var chicken_value : int = 10
var chicken_delivered: int = 0
var chicken_delivery_total: int = 75
var truck: Truck = null

func _init() -> void:
	pass

func _change_money(amount : int) -> void:
	money += amount
	money_changed.emit(money)

func _change_delivered(amount: int) -> void:
	chicken_delivered += amount
	chicken_delivered_changed.emit(chicken_delivered)
	if chicken_delivered > chicken_delivery_total:
		win.emit()

func is_buyable(price : int) -> bool:
	return money >= price

func remove_money(price : int) -> bool:
	if money >= price:
		#Add the purchase of the upgrade
		_change_money(-price)
		return true
	else:
		return false

func deliver_chickens(amount : int):
	_change_money(amount * chicken_value)
	_change_delivered(amount)
		
