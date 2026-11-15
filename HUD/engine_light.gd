extends TextureRect

# Control the speed of light/dark changes (larger values flash faster)
@export var speed: float = 2.0
# Control the minimum brightness (0 is black, 1 is original brightness)
@export var min_brightness: float = 0.5

func _process(delta: float) -> void:
	# Use a continuously accumulating time variable to avoid precision issues with large values
	var time = Time.get_ticks_msec() / 1000.0
	
	# sin() returns -1 to 1. Map it to 0 to 1:
	# (sin(...) + 1.0) / 2.0  results in 0 to 1
	var wave = (sin(time * speed) + 1.0) / 2.0
	
	# Interpolate between minimum brightness and 1.0 (original brightness) based on the wave value
	var brightness = lerp(min_brightness, 1.0, wave)
	
	# Set modulate. Color(brightness, brightness, brightness, 1.0) means RGB channels are darkened/lightened proportionally, Alpha remains opaque
	modulate = Color(brightness, brightness, brightness, 1.0)
