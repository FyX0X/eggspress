extends Node3D

var truck_in_zone: Truck = null
#var spawn_timer: float = 0.0

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	pass
	#
	#if truck_in_zone == null:
		#return
	##spawn_timer -= delta
	##if spawn_timer <= 0.0:
		#if not spawn_chicken():
			#return
		#spawn_timer = 1.0 / UpgradeManager.get_load_speed()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and truck_in_zone:
		print("Bennnnnn there")
		truck_in_zone.try_spawn_chicken()


#func _watch_chicken(chicken: Chicken, truck: Truck) -> void:
	#await get_tree().create_timer(4.0).timeout
#	if is_instance_valid(chicken) and is_instance_valid(truck) and not truck.has_chicken(chicken):
		#truck.cancel_reservation()
		#chicken.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is Truck:
		truck_in_zone = body
		print("[Farm] truck entered.")

func _on_body_exited(body: Node3D) -> void:
	if body == truck_in_zone:
		truck_in_zone = null
		print("[Farm] truck exited.")
