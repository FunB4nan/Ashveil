extends Node2D

class_name Main

signal cellEdited
signal deleteObstacle
signal playerLivingObstacle

const START_RADIUS = 3
const CHUNK_SIZE = 24

const MINE_AMOUNT = 24
const SLIME_AMOUNT = 10

var obstacle = preload("res://prefabs/obstacle.tscn")
var label = preload("res://prefabs/hintLabel.tscn")

var map : Dictionary[Vector2i, int]

var inventorySize : int = 10

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
		if map[pos] == 100:
			createMine(pos)
		elif map[pos] == 5:
			createSlime(pos)
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

func createMine(pos : Vector2i):
	var mineInst = obstacle.instantiate()
	mineInst.gridPos = pos
	mineInst.info = load("res://premadeResources/obstacles/mine.tres")
	add_child(mineInst)

func createSlime(pos : Vector2i):
	var slimeInst = obstacle.instantiate()
	slimeInst.gridPos = pos
	slimeInst.info = load("res://premadeResources/obstacles/enemies/slime.tres")
	add_child(slimeInst)

func createChest(pos : Vector2i, loot):
	var chestInst = obstacle.instantiate()
	chestInst.gridPos = pos
	chestInst.info = load("res://premadeResources/obstacles/chest.tres")
	chestInst.info.loot = loot
	add_child(chestInst)
	Global.main.map[pos] = 0
	Global.main.cellEdited.emit(pos)

func createLabel(pos : Vector2i, value : int):
	var labelInst = label.instantiate()
	labelInst.value = value
	labelInst.gridPos = pos
	add_child(labelInst)

func generateChunk(restrictedCells : Array[Vector2]):
	var mines : Array[Vector2]
	var slimes : Array[Vector2]
	for i in range(MINE_AMOUNT):
		mines.append(randomizeObstaclePos(mines, restrictedCells))
	restrictedCells.append_array(mines)
	for i in range(SLIME_AMOUNT):
		slimes.append(randomizeObstaclePos(slimes, restrictedCells))
	restrictedCells.append_array(slimes)
	for i in range(-CHUNK_SIZE / 2,CHUNK_SIZE / 2):
		for j in range(-CHUNK_SIZE / 2,CHUNK_SIZE / 2):
			if Vector2(i, j) in mines:
				map[Vector2i(i, j)] = 100
			elif Vector2(i, j) in slimes:
				map[Vector2i(i, j)] = 5
			else:
				map[Vector2i(i, j)] = 0

func randomizeObstaclePos(obstacles : Array[Vector2], restrictedCells : Array[Vector2]):
	var pos : Vector2 = Vector2(randi_range(-CHUNK_SIZE / 2 - 1,CHUNK_SIZE / 2 - 1), randi_range(-CHUNK_SIZE / 2 - 1,CHUNK_SIZE / 2 - 1))
	if pos in obstacles || pos in restrictedCells:
		pos = randomizeObstaclePos(obstacles, restrictedCells)
	return pos
