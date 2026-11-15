extends Node

signal money_changed(new_amount: int)
signal chicken_delivered_changed(new_amount: int)
signal win
signal upgrade_purchased(upgrade: Upgrade)

var money : int
var chicken_value : int
var chicken_delivered: int
var chicken_delivery_total: int = 25
var truck: Truck = null
var player_hud: PlayerHUD = null
var bridge: Bridge = null

var time_elapsed: float
var is_timer_running: bool

var unloading_speed: float


# UPGRADES

class Upgrade:
	var id: String
	var name: String
	var description: String
	var price: int
	var level: int = 0
	var max_level: int = 1
	var apply: Callable  # what happens on purchase

	func _init(p_id, p_name, p_desc, p_price, p_max_level, p_apply):
		id = p_id
		name = p_name
		description = p_desc
		price = p_price
		max_level = p_max_level
		apply = p_apply


var upgrades: Array[Upgrade] = []

func _ready() -> void:
	_reset_game()
	upgrades = [
		Upgrade.new("bridge", "Unlock Bridge", "Adds a bridge over the canion",
			100, 1, func(): bridge.set_active(true)),
		Upgrade.new("bigger_load", "Bigger Load", "x2 chicken per trip",
			20, 5, func(): truck.capacity *= 2; truck.chicken_area.chickens_changed.emit(truck.get_chicken_count())),
		Upgrade.new("better_value", "Premium Chicken", "+5 per chicken",
			20, 10, func(): chicken_value += 5),
		Upgrade.new("waterproof", "Water Proof", "Makes engine waterproof",
			80, 1, func(): truck.waterproof = true),
	]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_add_money"):
		_change_money(10000)
	if event.is_action_pressed("ui_cancel"):
		_reset_game()
		get_tree().change_scene_to_file("res://Menu/main_menu.tscn")

func _process(delta: float) -> void:
	if is_timer_running:
		time_elapsed += delta

func get_formatted_time() -> String:
	var total_seconds: int = int(time_elapsed)
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func set_timer_running(running: bool) -> void:
	is_timer_running = running

func reset_timer() -> void:
	time_elapsed = 0.0

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
	
	
## UPGRADES
func try_buy_upgrade(id: String) -> bool:
	var upg := get_upgrade(id)
	if upg == null:
		return false
	if upg.level >= upg.max_level:
		return false
	if not remove_money(upg.price):
		return false
	
	upg.level += 1
	upg.apply.call()
	upg.price = int(upg.price * 1.5)  # optional price scaling
	upgrade_purchased.emit(upg)
	return true

func get_upgrade(id: String) -> Upgrade:
	for u in upgrades:
		if u.id == id:
			return u
	return null

func _reset_game():
	money = 0
	chicken_delivered = 0
	chicken_value = 10
	time_elapsed = 0.0
	is_timer_running = true
	unloading_speed = 1.0
	pass
