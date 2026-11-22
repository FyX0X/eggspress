extends Node3D

@export var musics: Array[AudioStream] = []
var current_music: AudioStream = null

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func _ready() -> void:
	music_player.finished.connect(_on_music_finished)
	
	_start_random_music()

func _on_music_finished() -> void:
	_start_random_music()

func _start_random_music() -> void:
	var next_music: AudioStream = musics.pick_random()
	
	while (musics.size() > 1 and next_music == current_music):
		next_music = musics.pick_random()
	
	current_music = next_music
	music_player.stream = current_music
	music_player.play()
