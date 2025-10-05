extends Node2D

class_name Obstacle

var chestItem = preload("res://prefabs/UI/itemInChest.tscn")

@export var info : ObstacleInfo

var gridPos : Vector2i

func _ready() -> void:
	position = gridPos * 32
	update()
	Global.main.playerLivingObstacle.connect(doAfterLiving)
	Global.main.cellEdited.connect(updateValue)
	if info is Chest:
		for item in info.loot.keys():
			var amount = randi_range(info.loot[item][0], info.loot[item][1])
			if amount == 0:
				continue
			var itemInst = chestItem.instantiate()
			itemInst.item = item
			print(info.loot[item])
			itemInst.amount = amount
			itemInst.parent = self
			%loot.add_child(itemInst)

func update():
	$sprite.texture.region = info.sprite.region
	$shadow.texture.region = info.sprite.region
	$value.visible= info.value > 0
	$value.text = str(info.value)

func updateValue(pos : Vector2i):
	if pos != gridPos:
		return
	info.value = Global.main.map[pos]
	if info.value <= 0:
		delete(gridPos)
	update()

func delete(pos : Vector2i):
	if pos != gridPos:
		return
	if info.has_method("actBeforeDeath"):
		await info.actBeforeDeath(self)
	Global.main.map[gridPos] = 0
	if !(info is Chest):
		$anim.play("death")
		await $anim.animation_finished
		queue_free()

func plaAudio(title : String):
	AudioManager.play(title)

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
		Global.main.enemiesOnMap.erase(gridPos)
		Global.main.openTile(gridPos)
		queue_free()

func showPanel():
	$lootPanel.visible = true

func hidePanel():
	$lootPanel.visible = false
