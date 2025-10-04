extends Node2D

@export var testAction : ItemAction

func _ready() -> void:
	testAction.act()
