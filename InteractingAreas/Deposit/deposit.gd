extends Node3D

@export var price_per_chicken: int = 15
@export var fly_duration: float = 0.9

@onready var delivery_point: Marker3D = $DeliveryPoint

var truck_in_zone: Truck = null
var is_unloading: bool = false
var unload_timer: float = 0.0

func _ready() -> void:
	assert(delivery_point)
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if not is_unloading or truck_in_zone == null:
		return
	unload_timer -= delta
	if unload_timer <= 0.0:
		if not unload_chicken():
			is_unloading = false
			print("Déchargement terminé")
			return
		unload_timer = 1.0 / UpgradeManager.get_unload_speed()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and truck_in_zone:
		if truck_in_zone.get_chicken_count() > 0:
			is_unloading = not is_unloading
			unload_timer = 0.0

func unload_chicken() -> bool:
	var chicken : Chicken = truck_in_zone.get_top_chicken()
	if chicken == null:
		return false
	# La poule décolle depuis le spawn point du camion
	_launch(chicken)
	return true

func _launch(chicken: Chicken) -> void:
	await chicken.fly_to(delivery_point.global_position, fly_duration)
	GameManager.deliver_chickens(1)
	

func _on_body_entered(body: Node3D) -> void:
	if body is Truck:
		truck_in_zone = body

func _on_body_exited(body: Node3D) -> void:
	if body == truck_in_zone:
		is_unloading = false
		truck_in_zone = null
