class_name Truck
extends VehicleBody3D


signal engine_drowned_changed(drowned: bool)

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.9
const BRAKE_STRENGTH = 3.0



@export var engine_force_value := 160.0
@export var spawn_point: Marker3D
@export var chicken_scene: PackedScene
@export var distance_reward: float = 0.01

@export_group("Rotation Control")
@export var enabled: bool = false
@export var pitch_torque := 6.0
@export var side_torque := 6.0
@export var side_is_roll := true        # true: A/D roll the truck, false: A/D yaw it
@export var only_when_airborne := true  # avoids fighting the wheels/steering on the ground

var previous_speed := 0.0
var _steer_target := 0.0
var _teleport_requested := false

@onready var engine_sound: AudioStreamPlayer3D = $EngineSound
@onready var desired_engine_pitch: float = engine_sound.pitch_scale
@onready var chicken_spawn_point: Marker3D = $ChickenSpawnPoint
@onready var chicken_area: ChickenArea = $ChickenArea
var capacity: int = 4


var waterproof := false   # set to true from your upgrade code
var engine_drowned := false


func _ready() -> void:
	can_sleep = false
	GameManager.truck = self
	previous_speed = linear_velocity.length()
	
	assert(spawn_point)
	assert(is_instance_valid(chicken_spawn_point))
	
	_teleport_requested = true
	#assert(turbometer)
	#assert(turbo_animator)


func _physics_process(delta: float) -> void:
	_steer_target = Input.get_axis(&"right", &"left")
	_steer_target *= STEER_LIMIT

	# Engine sound simulation (not realistic, as this car script has no notion of gear or engine RPM).
	desired_engine_pitch = 0.05 + linear_velocity.length() / (engine_force_value * 0.5)
	# Change pitch smoothly to avoid abrupt change on collision.
	engine_sound.pitch_scale = lerpf(engine_sound.pitch_scale, desired_engine_pitch, 0.2)

	if absf(linear_velocity.length() - previous_speed) > 1.0:
		# Sudden velocity change, likely due to a collision. Play an impact sound to give audible feedback,
		# and vibrate for haptic feedback.
		
		# $ImpactSound.play() TODO
		Input.vibrate_handheld(100)
		for joypad in Input.get_connected_joypads():
			Input.start_joy_vibration(joypad, 0.0, 0.5, 0.1)



	# Automatically accelerate when using touch controls (reversing overrides acceleration).
	if DisplayServer.is_touchscreen_available() or Input.is_action_pressed(&"forward"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * 5.0 / speed, 0.0, engine_force_value * 5.0)
		else:
			engine_force = -engine_force_value
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"backward"):
		# Increase engine force at low speeds to make the initial reversing faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, engine_force_value * 5.0)
		else:
			engine_force = engine_force_value
	
	if engine_drowned:
		engine_force = 0.0

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)
	
	_apply_rotation_control()

	previous_speed = linear_velocity.length()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not _teleport_requested:
		return
	_teleport_requested = false

	var target := spawn_point.global_transform
	target.basis = target.basis.orthonormalized()

	state.transform = target
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO
	steering = 0.0
	previous_speed = 0.0

func _apply_rotation_control() -> void:
	if not enabled:
		return
	
	if only_when_airborne and _wheels_on_ground() > 0:
		return

	# Same sign convention as your steering: left = positive
	var pitch_input := Input.get_axis(&"forward", &"backward")  # S = nose up, W = nose down
	var side_input := Input.get_axis(&"right", &"left")         # A = left, D = right

	var local_torque := Vector3(pitch_input * pitch_torque, 0.0, 0.0)
	if side_is_roll:
		local_torque.z = side_input * side_torque   # A = roll left
	else:
		local_torque.y = side_input * side_torque   # A = yaw left

	# Convert to world space and scale by mass so tuning doesn't depend on truck weight
	apply_torque(global_transform.basis * local_torque * mass)


func _wheels_on_ground() -> int:
	var count := 0
	for child in get_children():
		if child is VehicleWheel3D and child.is_in_contact():
			count += 1
	return count

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"respawn"):
		repair_engine()
		_give_distance_reward()
		_teleport_requested = true
		for chicken in get_tree().get_nodes_in_group("chickens"):
			chicken.queue_free()
	
	if event.is_action_pressed(&"debug_spawn"):
		print("[DEBUG] Spawning Chicken")
		_force_spawn_chicken()


func _input(p_input_event: InputEvent) -> void:
	pass

	#if p_input_event.is_action_pressed(&"honk"):
		#$HonkSound.play() TODO

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
