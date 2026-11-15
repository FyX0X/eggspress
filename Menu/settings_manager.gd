extends Node

# Noms des bus (doivent correspondre EXACTEMENT à ceux de l'onglet Audio)
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"

# Valeurs par défaut (0.0 = silencieux, 1.0 = volume max)
var music_volume: float = 0.5
var sfx_volume: float = 0.5

func _ready() -> void:
	load_settings()
	apply_settings()

# Applique les volumes aux bus audio
func apply_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_MUSIC), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_SFX), linear_to_db(sfx_volume))

# Sauvegarde les settings
func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.save("user://settings.cfg")

# Charge les settings
func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		music_volume = config.get_value("audio", "music", 0.5)
		sfx_volume = config.get_value("audio", "sfx", 0.7)

# Fonctions appelées par les sliders
func set_music_volume(value: float) -> void:
	music_volume = value
	apply_settings()
	save_settings()

func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	apply_settings()
	save_settings()
