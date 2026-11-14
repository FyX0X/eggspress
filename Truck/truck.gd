class_name Truck
extends VehicleBody3D

var steer: float = 0.9
var power: float = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _physics_process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("right", "left") * steer, delta)
	engine_force = Input.get_axis("forward", "backward") * power
