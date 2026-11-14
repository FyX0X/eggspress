class_name Truck
extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.9
const BRAKE_STRENGTH = 3.0

@export var engine_force_value := 160.0
@export var spawn_point: Marker3D


var previous_speed := 0.0
var _steer_target := 0.0
var _teleport_requested := false

@onready var engine_sound: AudioStreamPlayer3D = $EngineSound
@onready var desired_engine_pitch: float = engine_sound.pitch_scale
@onready var chicken_spawn_point: Marker3D = $ChickenSpawnPoint
@onready var chicken_area: ChickenArea = $ChickenArea
var chicken_limit: int = 4


func _ready() -> void:
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
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, engine_force_value * 5.0)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"backward"):
		# Increase engine force at low speeds to make the initial reversing faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * 5.0 / speed, 0.0, engine_force_value * 5.0)
		else:
			engine_force = -engine_force_value

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"respawn"):
		_teleport_requested = true
		for chicken in get_tree().get_nodes_in_group("chickens"):
			chicken.queue_free()


func _input(p_input_event: InputEvent) -> void:
	pass

	#if p_input_event.is_action_pressed(&"honk"):
		#$HonkSound.play() TODO


func is_full() -> bool:
	return chicken_area.chickens.size() >= chicken_limit
