extends Node2D

class_name Main

signal cellEdited

const START_RADIUS = 3
const CHUNK_SIZE = 24
const MINE_AMOUNT = 24

var mine = preload("res://prefabs/mine.tscn")
var label = preload("res://prefabs/hintLabel.tscn")

var map : Dictionary[Vector2i, int]

func _ready() -> void:
	var restrictedCells : Array[Vector2]
	for i in range(-START_RADIUS, START_RADIUS):
		for j in range(-START_RADIUS, START_RADIUS):
			restrictedCells.append(Vector2(i, j))
	Global.main = self
	generateChunk(restrictedCells)
	for i in range(-START_RADIUS, START_RADIUS + 1):
		for j in range(-START_RADIUS, START_RADIUS + 1):
			openTile(Vector2(i, j))

func openTile(pos : Vector2i):
	if map.has(pos):
		$tiles.set_cell(pos, 0, Vector2i.ZERO)
		cellEdited.emit(pos)
		if map[pos] == 11:
			createMine(pos * 32)
		else:
			createLabel(pos, getNeighboursSum(pos))
		return map[pos]
	else:
		return null

func getNeighboursSum(pos : Vector2i):
	var sum : int = 0
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if map.has(Vector2i(i, j)):
				sum += map[Vector2i(i, j)]
	return sum

func createMine(pos : Vector2):
	var mineInst = mine.instantiate()
	mineInst.position = pos
	add_child(mineInst)

func createLabel(pos : Vector2i, value : int):
	var labelInst = label.instantiate()
	labelInst.value = value
	labelInst.gridPos = pos
	add_child(labelInst)

func generateChunk(restrictedCells : Array[Vector2]):
	var mines : Array[Vector2]
	for i in range(MINE_AMOUNT):
		mines.append(randomizeMinePos(mines, restrictedCells))
	print(mines)
	for i in range(-CHUNK_SIZE / 2,CHUNK_SIZE / 2):
		for j in range(-CHUNK_SIZE / 2,CHUNK_SIZE / 2):
			if Vector2(i, j) in mines:
				map[Vector2i(i, j)] = 11
			else:
				map[Vector2i(i, j)] = 0

func randomizeMinePos(mines : Array[Vector2], restrictedCells : Array[Vector2]):
	var pos : Vector2 = Vector2(randi_range(-CHUNK_SIZE / 2 - 1,CHUNK_SIZE / 2 - 1), randi_range(-CHUNK_SIZE / 2 - 1,CHUNK_SIZE / 2 - 1))
	if pos in mines || pos in restrictedCells:
		pos = randomizeMinePos(mines, restrictedCells)
	return pos
