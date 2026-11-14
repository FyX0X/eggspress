extends Area3D

@export var truck: VehicleBody3D
@export var cluck_player: AudioStreamPlayer3D
@export var cluck_sounds: Array[AudioStream]
@export var min_interval := 6.0   # time between clucks when the bed is full
@export var max_interval := 12.0   # time between clucks with a single chicken
@export var full_bed_count := 10  # chicken count at which min_interval applies

var _chickens: Array[Chicken] = []
var _cluck_timer := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_cluck_timer = max_interval

func _on_body_entered(body: Node3D) -> void:
	if body is Chicken:
		body.carrier = truck
		body.cancel_fuse()
		_chickens.append(body)
		print("[ChickenArea] Added Chicken")

func _on_body_exited(body: Node3D) -> void:
	if body is Chicken:
		body.carrier = null
		body.light_fuse()
		_chickens.erase(body)
		print("[ChickenArea] Removed Chicken")

func _process(delta: float) -> void:
	if _chickens.is_empty() or cluck_sounds.is_empty():
		return

	_cluck_timer -= delta
	if _cluck_timer > 0.0:
		return

	# More chickens in the bed means more frequent clucks
	var fullness := clampf(float(_chickens.size()) / full_bed_count, 0.0, 1.0)
	_cluck_timer = lerpf(max_interval, min_interval, fullness) * randf_range(0.7, 1.3)

	if cluck_player.playing:
		return

	# Cluck from a random chicken's position so it doesn't always come from the truck centre
	var source: Chicken = _chickens.pick_random()
	if is_instance_valid(source):
		cluck_player.global_position = source.global_position

	cluck_player.stream = cluck_sounds.pick_random()
	cluck_player.pitch_scale = randf_range(0.9, 1.15)
	cluck_player.play()
	print("sound")
