extends Control

# Chemin vers ta scène de jeu (ajuste le chemin selon ton projet)
@export var game_scene_path: String = "res://main.tscn"
@export var option_scene : String = "res://Menu/options.tscn"

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var option_button : Button = $VBoxContainer/OptionButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	# On connecte les signaux des boutons
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Optionnel : Capturer la souris pour le menu (ou la laisser libre)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play_pressed() -> void:
	# Reset l'argent et les stats si tu veux recommencer à zéro à chaque partie
	# GameManager.reset_game() 
	# Wallet.money = 0
	
	# Change la scène vers le jeu
	get_tree().change_scene_to_file(game_scene_path)

func _on_quit_pressed() -> void:
	# Ferme le jeu
	get_tree().quit()


func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_file(option_scene)
