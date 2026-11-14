extends Node3D

func _ready() -> void:
	var musique := AudioStreamPlayer.new()
	musique.stream = preload("res://assets/audio/shepherd_dog.wav")
	add_child(musique)
	musique.play()
