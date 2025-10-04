extends Node2D

@export var info : ObstacleInfo

var gridPos : Vector2i

func _ready() -> void:
	position = gridPos * 32
	$sprite.texture = info.sprite
	Global.main.deleteObstacle.connect(delete)

func delete(pos : Vector2i):
	if pos == gridPos:
		Global.main.map[gridPos] = 0
		Global.main.cellEdited.emit(gridPos)
		queue_free()
