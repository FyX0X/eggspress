class_name Chicken
extends RigidBody3D

signal exploded(chicken: Chicken)

@export var walk_speed: float = 2.0

@export_group("Explosion")
@export var time_before_explode: float = 3.0
@export var explosion_scene: PackedScene   # visual pop only (particles, sound...)
@export var visual: Node3D                 # mesh/model child used for the warning pulse

var walk_timer: float = 0.0
var random_direction: Vector3 = Vector3.ZERO
var is_flying: bool = false

# Set by the truck's Area3D while the chicken is inside the bed
var carrier: VehicleBody3D = null

var _fuse_lit: bool = false
var _time_left: float = 0.0


var visual_scale: Vector3

@onready var touching_floor : Area3D = $Area3D

func _ready():
	lock_rotation = false
	can_sleep = false
	visual_scale = visual.scale
	add_to_group("chickens")
	light_fuse()

func _physics_process(delta):
	
	if is_flying:
		return

	_update_fuse(delta)

	if touching_floor.get_overlapping_bodies().size()>1:
		walk_timer -= delta
		if walk_timer <= 0:
			pick_new_direction()

	# Velocity of the truck at the chicken's position (includes turning)
	var base := Vector3.ZERO
	if carrier:
		var offset := global_position - carrier.global_position
		base = carrier.linear_velocity + carrier.angular_velocity.cross(offset)

	# Keep Y from gravity, override X/Z relative to whatever carries us
	linear_velocity.x = base.x + random_direction.x * walk_speed
	linear_velocity.z = base.z + random_direction.z * walk_speed

# --- Fuse / explosion ---

func light_fuse() -> void:
	if _fuse_lit or is_flying:
		return
	_fuse_lit = true
	_time_left = time_before_explode

func cancel_fuse() -> void:
	if not _fuse_lit:
		return
	_fuse_lit = false
	if visual:
		visual.scale = visual_scale

func _update_fuse(delta: float) -> void:
	if not _fuse_lit:
		return
	_time_left -= delta
	if visual:
		var urgency := 1.0 - clampf(_time_left / time_before_explode, 0.0, 1.0)
		var pulse := 1.0 + 0.15 * sin(Time.get_ticks_msec() * 0.001 * 0.1 * lerpf(8.0, 30.0, urgency))
		visual.scale = visual_scale * pulse
	if _time_left <= 0.0:
		explode()

func explode() -> void:
	_fuse_lit = false
	if explosion_scene:
		var fx := explosion_scene.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.global_position = global_position
	exploded.emit(self)
	print("chicken exploded")
	queue_free()

# --- Walking ---

func pick_new_direction():
	var angle = randf_range(0, TAU)
	random_direction = Vector3(cos(angle), 0, sin(angle))
	walk_timer = randf_range(1.0, 2.0)
	if randf() < 0.2:
		random_direction = Vector3.ZERO

# --- Delivery ---

func fly_to(target: Vector3, duration: float = 0.9) -> void:
	if is_flying:
		return
	is_flying = true
	carrier = null
	cancel_fuse()

	freeze = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	collision_layer = 0
	collision_mask = 0
	lock_rotation = false

	var start := global_position
	var control := (start + target) * 0.5 + Vector3.UP * 6.0

	var tween := create_tween()
	tween.tween_method(_fly_arc.bind(start, control, target), 0.0, 1.0, duration)
	tween.parallel().tween_property(self, "rotation", rotation + Vector3(0, TAU * 2.0, 0), duration)
	await tween.finished
	queue_free()

func _fly_arc(t: float, start: Vector3, control: Vector3, target: Vector3) -> void:
	var a := start.lerp(control, t)
	var b := control.lerp(target, t)
	global_position = a.lerp(b, t)
