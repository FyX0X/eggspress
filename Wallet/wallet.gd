extends RefCounted

var money : int = 0

func _init() -> void:
	pass

func change_money(amount : int) -> void:
	money += amount

func is_buyable(price : int) -> bool:
	return money >= price

func remove_money(price : int) -> bool:
	if money >= price:
		#Add the purchase of the upgrade
		change_money(-price)
		return true
	else:
		return false
