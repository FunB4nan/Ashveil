extends Control

@export var value : int = 0

func _ready() -> void:
	$value.text = str(value)
	if value < 0:
		modulate = Color(1.0, 0.0, 0.0)
	else:
		modulate = Color(0.0, 1.0, 0.0)
