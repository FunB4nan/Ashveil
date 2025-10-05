extends Control

var line : String = ""

func _ready() -> void:
	$value.text = tr(line)
