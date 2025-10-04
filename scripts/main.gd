extends Node2D

class_name Main

signal cellEdited
signal deleteObstacle
signal playerLivingObstacle
signal cellSelected

const START_RADIUS = 3
const CHUNK_SIZE = 24

const MINE_AMOUNT = 24
const SLIME_AMOUNT = 10

var obstacle = preload("res://prefabs/obstacle.tscn")
var label = preload("res://prefabs/hintLabel.tscn")
var distanceCell = preload("res://prefabs/distancePreview.tscn")

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("showAllMap"):
		for pos in map.keys():
			openTile(pos)
	if event.is_action_pressed("LMB"):
		var mousePos = Vector2i(floor(get_global_mouse_position().x / 32), floor(get_global_mouse_position().y / 32))
		if mousePos in map:
			cellSelected.emit(mousePos)

func openTile(pos : Vector2i):
	if map.has(pos):
		cellEdited.emit(pos)
		if map[pos] == 100:
			createMine(pos)
		elif map[pos] == 5:
			createSlime(pos)
		else:
			createLabel(pos, getNeighboursSum(pos))
		$tiles.set_cell(pos, 0, Vector2i.ZERO)
		return map[pos]
	else:
		return null

func chooseCellToAct(distance : int):
	for x in range(Global.player.gridPos.x - distance, Global.player.gridPos.x + distance + 1):
		for y in range(Global.player.gridPos.y - distance, Global.player.gridPos.y + distance + 1):
			var previewInst = distanceCell.instantiate()
			previewInst.position = Vector2(x, y) * 32 + Vector2(16, 16)
			previewInst.scale = Vector2.ZERO
			$distancePreview.add_child(previewInst)
			TweenManager.scaleTween(previewInst, Vector2.ONE)
	var cell = await cellSelected
	for preview in $distancePreview.get_children():
		preview.queue_free()
	return cell

func getNeighboursSum(pos : Vector2i):
	var sum : int = 0
	for i in range(pos.x - 1, pos.x + 2):
		for j in range(pos.y - 1, pos.y + 2):
			if map.has(Vector2i(i, j)):
				sum += map[Vector2i(i, j)]
	return sum

func createMine(pos : Vector2i):
	if pos in $tiles.get_used_cells():
		return
	var mineInst = obstacle.instantiate()
	mineInst.gridPos = pos
	mineInst.info = load("res://premadeResources/obstacles/mine.tres")
	$playground.add_child(mineInst)

func createSlime(pos : Vector2i):
	if pos in $tiles.get_used_cells():
		return
	var slimeInst = obstacle.instantiate()
	slimeInst.gridPos = pos
	slimeInst.info = load("res://premadeResources/obstacles/enemies/slime.tres").duplicate()
	$playground.add_child(slimeInst)

func createChest(pos : Vector2i, loot):
	var chestInst = obstacle.instantiate()
	chestInst.gridPos = pos
	chestInst.info = load("res://premadeResources/obstacles/chest.tres")
	chestInst.info.loot = loot
	$playground.add_child(chestInst)
	Global.main.map[pos] = 0
	Global.main.cellEdited.emit(pos)

func createLabel(pos : Vector2i, value : int):
	var labelInst = label.instantiate()
	labelInst.value = value
	labelInst.gridPos = pos
	$playground.add_child(labelInst)

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
