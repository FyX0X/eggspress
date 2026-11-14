class_name Chicken
extends RigidBody3D

@export var walk_speed: float = 2.0
var walk_timer: float = 0.0
var random_direction: Vector3 = Vector3.ZERO

var is_flying: bool = false

func _ready():
	# Lock rotation if you don't want the chickens tumbling over constantly
	# (Or leave it unlocked if you want hilarious physics chaos in the truck)
	lock_rotation = true 
	pick_new_direction()

func _physics_process(delta):
	if is_flying:
		return
	walk_timer -= delta
	if walk_timer <= 0:
		pick_new_direction()
	
	# Apply velocity to simulate walking
	# We keep the Y velocity from gravity, but override X and Z
	linear_velocity.x = random_direction.x * walk_speed
	linear_velocity.z = random_direction.z * walk_speed

func pick_new_direction():
	# Pick a random direction on the horizontal plane
	var angle = randf_range(0, TAU)
	random_direction = Vector3(cos(angle), 0, sin(angle))
	# Set a random duration for this walk (1 to 3 seconds)
	walk_timer = randf_range(1.0, 3.0)
	
	# Optional: Stop moving occasionally for a "pecking" break
	if randf() < 0.3:
		random_direction = Vector3.ZERO

func fly_to(target: Vector3, duration: float = 0.9) -> void:
	if is_flying:
		return
	is_flying = true

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
