class_name Truck
extends VehicleBody3D


signal engine_drowned_changed(drowned: bool)


# --- Tuning ---
@export_group("Tuning")
@export var max_engine_force: float = 150.0
@export var max_brake_force: float = 25.0
@export var max_steer_angle: float = 0.5      # radians (~28°)
@export var steer_speed: float = 3.0          # how fast steering responds
@export var steer_return_speed: float = 5.0   # how fast it returns to center
@export var reverse_force_multiplier: float = 0.5

# --- State ---
var current_steer: float = 0.0

@export_group("Misc")
@export var spawn_point: Marker3D
@export var chicken_scene: PackedScene
@export var distance_reward: float = 0.01

var _teleport_requested := false

@onready var engine_sound: AudioStreamPlayer3D = $EngineSound
@onready var desired_engine_pitch: float = engine_sound.pitch_scale
@onready var chicken_spawn_point: Marker3D = $ChickenSpawnPoint
@onready var chicken_area: ChickenArea = $ChickenArea
var capacity: int = 4


var waterproof := false   # set to true from your upgrade code
var engine_drowned := false

@export_group("Impact Sound")
@export var impact_min_speed: float = 3.0        # m/s below which we ignore (prevents ticking on small bumps)
@export var impact_max_speed: float = 25.0       # m/s at which sound hits full volume
@export var impact_min_volume_db: float = -20.0
@export var impact_max_volume_db: float = 0.0
@export var impact_cooldown: float = 0.15        # seconds between sounds (avoid machine-gun)

var _last_impact_time: float = -100.0
var _pre_collision_speed: float = 0.0

@onready var impact_sound: AudioStreamPlayer3D = $ImpactSound


func _ready() -> void:
	can_sleep = false
	GameManager.truck = self
	
	assert(spawn_point)
	assert(is_instance_valid(chicken_spawn_point))
	
	_teleport_requested = true
	
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_handle_steering(delta)
	_handle_throttle()
	_handle_brakes()
	

	var speed := linear_velocity.length()
	var normalized := clampf(speed / 40.0, 0.0, 1.0)
	desired_engine_pitch = lerpf(0.8, 1.6, normalized)

	# $ImpactSound.play() TODO
	# previous_speed = linear_velocity.length()




func _handle_steering(delta: float) -> void:
	var steer_input := Input.get_axis("right", "left")  # -1..1

	if abs(steer_input) > 0.01:
		# Turn toward input smoothly
		current_steer = move_toward(
			current_steer,
			steer_input * max_steer_angle,
			steer_speed * delta
		)
	else:
		# Return to center smoothly
		current_steer = move_toward(current_steer, 0.0, steer_return_speed * delta)

	steering = current_steer


func _handle_throttle() -> void:
	if engine_drowned:
		engine_force = 0.0
		return
	var throttle := Input.get_action_strength("forward")    # forward
	var reverse := Input.get_action_strength("backward")   # backward
	
	# TEMP SWAP TO FIX ORIENTATION
	var tmp = throttle
	throttle = reverse
	reverse = tmp

	if throttle > 0.0:
		engine_force = throttle * max_engine_force
	elif reverse > 0.0:
		engine_force = -reverse * max_engine_force * reverse_force_multiplier
	else:
		engine_force = 0.0


func _handle_brakes() -> void:
	if Input.is_action_pressed("jump"):  # Space = handbrake
		brake = max_brake_force
	else:
		brake = 0.0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_pre_collision_speed = state.linear_velocity.length()
	
	if not _teleport_requested:
		return
	_teleport_requested = false

	var target := spawn_point.global_transform
	target.basis = target.basis.orthonormalized()

	state.transform = target
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO
	steering = 0.0
	#previous_speed = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"respawn"):
		repair_engine()
		_give_distance_reward()
		_teleport_requested = true
		for chicken in get_tree().get_nodes_in_group("chickens"):
			chicken.queue_free()


func get_top_chicken() -> Chicken:
	var top: Chicken = null
	for chicken: Chicken in chicken_area.chickens:
		if not top || top.global_position.y < chicken.global_position.y:
			top = chicken
	return top

func get_chicken_count() -> int:
	return chicken_area.chickens.size()

func is_full() -> bool:
	return get_chicken_count() >= capacity


func try_spawn_chicken() -> bool:
	print("Been ther")
	if is_full(): # TODO FIXME so i can't spawn more chickens
		return false
	_force_spawn_chicken()
	return true


func _force_spawn_chicken() -> void:
	var chicken := chicken_scene.instantiate() as Chicken
	get_tree().current_scene.add_child(chicken)
	# Spawn au-dessus du camion (même point pour load et unload)
	chicken.global_position = chicken_spawn_point.global_position


func drown_engine() -> void:
	print("Drowning Engine")
	if waterproof or engine_drowned:
		return
	engine_drowned = true
	engine_force = 0.0
	engine_sound.stream_paused = true
	engine_drowned_changed.emit(true)


func repair_engine() -> void:
	if not engine_drowned:
		return
	engine_drowned = false
	engine_sound.stream_paused = false
	engine_drowned_changed.emit(false)

func _give_distance_reward() -> void:
	var distance: float = (global_position - spawn_point.global_position).length()
	GameManager._change_money(distance * get_chicken_count() * distance_reward)


func _on_body_entered(_body: Node) -> void:
	# Godot gives us the *current* velocity here, not pre-impact velocity,
	# because the solver already resolved the collision. For a decent approximation
	# we use the velocity magnitude we had going into the frame, cached below.
	var speed := _pre_collision_speed
	if speed < impact_min_speed:
		return

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_impact_time < impact_cooldown:
		return
	_last_impact_time = now

	var t := clampf(
		(speed - impact_min_speed) / (impact_max_speed - impact_min_speed),
		0.0, 1.0
	)
	impact_sound.volume_db = lerpf(impact_min_volume_db, impact_max_volume_db, t)
	impact_sound.pitch_scale = randf_range(0.9, 1.1)  # subtle variation
	impact_sound.play()
