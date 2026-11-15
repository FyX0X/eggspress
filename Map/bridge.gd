class_name Bridge
extends StaticBody3D

@onready var mesh: Node3D = $bridge_center_woodRound2
@onready var wall_left: CollisionShape3D = $WallLeft
@onready var wall_right: CollisionShape3D = $WallRight
@onready var road: CollisionShape3D = $Road

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.bridge = self
	set_active(false)


func set_active(active: bool) -> void:
	mesh.visible = active
	wall_left.set_deferred(&"disabled", not active)
	wall_right.set_deferred(&"disabled", not active)
	road.set_deferred(&"disabled", not active)
	
