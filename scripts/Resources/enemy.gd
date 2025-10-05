extends ObstacleInfo

class_name Enemy

@export var loot : Dictionary[Item, Array] = {
	preload("res://premadeResources/items/bullets.tres") : [0,1]
}

func actBeforeDeath(source):
	if source.gridPos in Global.main.chests:
		return
	Global.main.createChest(source.gridPos, loot)
