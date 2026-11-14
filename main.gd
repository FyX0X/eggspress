extends Node3D

func _ready() -> void:
	var musique := AudioStreamPlayer.new()
	musique.stream = preload("res://assets/audio/shepherd_dog.ogg")
	add_child(musique)
	musique.play()
