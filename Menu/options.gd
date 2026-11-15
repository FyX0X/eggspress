extends Control

@onready var music_slider: HSlider = $VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXContainer/SFXSlider
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	# 1. Initialiser les sliders avec les valeurs sauvegardées
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	
	# 2. Connecter les signaux des sliders
	music_slider.value_changed.connect(SettingsManager.set_music_volume)
	sfx_slider.value_changed.connect(SettingsManager.set_sfx_volume)
	
	# 3. Bouton retour
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	# Retour au menu principal (ajuste le chemin si besoin)
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
