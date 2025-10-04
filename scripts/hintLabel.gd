extends Node2D

var value = 0
var gridPos : Vector2i = Vector2i.ZERO

func _ready() -> void:
	position = gridPos * 32
	Global.main.cellEdited.connect(updateInfo)
	updateInfo(gridPos)

func updateInfo(pos : Vector2i):
	var directions = [Vector2i(0,0),Vector2i(0,1),Vector2i(0,-1),
	Vector2i(1,0),Vector2i(1,1),Vector2i(1,-1),
	Vector2i(-1,0),Vector2i(-1,1),Vector2i(-1,-1)]
	if gridPos - pos in directions:
		value = Global.main.getNeighboursSum(gridPos)
	$value.text = str(value)
