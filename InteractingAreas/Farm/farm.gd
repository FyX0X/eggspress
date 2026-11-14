extends Node3D

@export var chicken_scene: PackedScene

@onready var loading_zone: Area3D = $LoadingZone

var truck_in_zone: Truck = null
var is_loading: bool = false
var spawn_timer: float = 0.0

func _ready() -> void:
	loading_zone.body_entered.connect(_on_body_entered)
	loading_zone.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if not is_loading or truck_in_zone == null:
		return
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		if not spawn_chicken():
			stop_loading()
			return
		spawn_timer = 1.0 / UpgradeManager.get_load_speed()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and truck_in_zone:
		if is_loading:
			stop_loading()
		elif not truck_in_zone.is_full():
			is_loading = true
			spawn_timer = 0.0
			print("Chargement...")

func stop_loading() -> void:
	is_loading = false

func spawn_chicken() -> bool:
	if not truck_in_zone.reserve_slot():
		return false

	var chicken := chicken_scene.instantiate() as Chicken
	get_tree().current_scene.add_child(chicken)
	# Spawn au-dessus du camion (même point pour load et unload)
	chicken.global_position = truck_in_zone.chicken_spawn_point.global_position

	_watch_chicken(chicken, truck_in_zone)
	return true

func _watch_chicken(chicken: Chicken, truck: Truck) -> void:
	await get_tree().create_timer(4.0).timeout
	if is_instance_valid(chicken) and is_instance_valid(truck) and not truck.has_chicken(chicken):
		truck.cancel_reservation()
		chicken.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is Truck:
		truck_in_zone = body

func _on_body_exited(body: Node3D) -> void:
	if body == truck_in_zone:
		is_loading = false
		truck_in_zone = null
