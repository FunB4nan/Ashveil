extends Node2D

class_name Obstacle

var chestItem = preload("res://prefabs/UI/itemInChest.tscn")

@export var info : ObstacleInfo

var gridPos : Vector2i

func _ready() -> void:
	position = gridPos * 32
	update()
	Global.main.deleteObstacle.connect(delete)
	Global.main.playerLivingObstacle.connect(doAfterLiving)
	if info is Chest:
		for item in info.loot.keys():
			var itemInst = chestItem.instantiate()
			itemInst.item = item
			itemInst.amount = info.loot[item]
			itemInst.parent = self
			%loot.add_child(itemInst)
	$lootPanel.position = Vector2(-$lootPanel.size.x / 2, - $lootPanel.size.y - 32)
	$lootPanel.visible = false
	$value.text = str(info.value)

func update():
	$sprite.texture = info.sprite

func delete(pos : Vector2i):
	if pos != gridPos:
		return
	if info.has_method("actBeforeDeath"):
		await info.actBeforeDeath(self)
	Global.main.map[gridPos] = 0
	Global.main.cellEdited.emit(gridPos)
	if !(info is Chest):
		queue_free()

func doAfterLiving(pos : Vector2i):
	if gridPos != pos:
		return
	if info.has_method("onObstacleLiving"):
		info.onObstacleLiving(self)

func deleteItem(item):
	item.queue_free()
	await get_tree().create_timer(0.1).timeout
	if %loot.get_child_count() == 0:
		Global.main.map[gridPos] = 0
		Global.main.cellEdited.emit(gridPos)
		queue_free()

func showPanel():
	$lootPanel.visible = true

func hidePanel():
	$lootPanel.visible = false
