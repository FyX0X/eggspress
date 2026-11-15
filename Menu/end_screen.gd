extends Control

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var money_label: Label = $VBoxContainer/MoneyLabel
@onready var menu_button: Button = $VBoxContainer/MenuButton

func _ready() -> void:
	
	# 2. On affiche les statistiques finales
	time_label.text = "Elapsed time : " + GameManager.get_formatted_time()
	money_label.text = "Total money won: " + str(GameManager.total_money) + " $"
	
	# 3. On connecte le bouton
	menu_button.pressed.connect(_on_menu_button_pressed)

func _on_menu_button_pressed() -> void:
	GameManager._reset_game()
	# Retour au menu principal (ajuste le chemin si ton menu est ailleurs)
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn") 
	
