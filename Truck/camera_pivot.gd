extends Node3D

@export var mouse_sensitivity: float = 0.005
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 5.0   # Distance minimum
@export var max_zoom: float = 20.0  # Distance maximum

# Limites pour l'inclinaison du SpringArm (Haut/Bas)
@export var min_pitch: float = -1.2 # Regard vers le bas (~ -70°)
@export var max_pitch: float = 0.5  # Regard vers le haut (~ 30°)

var yaw_offset: float = 0.0
var pitch_offset: float = 0.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	# 1. ROTATION (Clic gauche maintenu)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Gauche/Droite : on tourne le Pivot
		yaw_offset -= event.relative.x * mouse_sensitivity
		
		# Haut/Bas : on incline le SpringArm
		pitch_offset -= event.relative.y * mouse_sensitivity
		pitch_offset = clampf(pitch_offset, min_pitch, max_pitch)

	# 2. ZOOM (Molette de la souris)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = clampf(spring_arm.spring_length - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = clampf(spring_arm.spring_length + zoom_speed, min_zoom, max_zoom)

func _process(_delta: float) -> void:
	# Le Yaw (Gauche/Droite) s'applique au Pivot
	rotation.y = yaw_offset
	
	# Le Pitch (Haut/Bas) s'applique au SpringArm
	spring_arm.rotation.x = pitch_offset
	
	# On s'assure que la caméra elle-même reste bien droite (pas de roulis)
	camera.rotation = Vector3.ZERO
