class_name Truck
extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.9
const BRAKE_STRENGTH = 3.0

@export var engine_force_value := 160.0

# var turbometer: Range
# var turbo_animator: AnimationPlayer

var previous_speed := linear_velocity.length()
var turbo_active := false
var headlights_active := false
var _steer_target := 0.0
var is_compatibility := RenderingServer.get_current_rendering_method() == "gl_compatibility"

@onready var desired_engine_pitch: float = $EngineSound.pitch_scale
@onready var engine_sound: AudioStreamPlayer3D = $EngineSound


func _ready() -> void:
	pass
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
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0.0

	if Input.is_action_pressed(&"backward"):
		# Increase engine force at low speeds to make the initial reversing faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = -engine_force_value

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_speed = linear_velocity.length()


func _input(p_input_event: InputEvent) -> void:
	pass

	#if p_input_event.is_action_pressed(&"honk"):
		#$HonkSound.play() TODO
