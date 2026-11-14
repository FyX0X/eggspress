class_name Chicken
extends RigidBody3D

@export var walk_speed: float = 2.0
var walk_timer: float = 0.0
var random_direction: Vector3 = Vector3.ZERO

func _ready():
	# Lock rotation if you don't want the chickens tumbling over constantly
	# (Or leave it unlocked if you want hilarious physics chaos in the truck)
	lock_rotation = true 
	pick_new_direction()

func _physics_process(delta):
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
