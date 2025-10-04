extends ObstacleInfo

class_name Enemy

@export var loot : Dictionary[Item, int]

func actBeforeDeath(source):
	Global.main.createChest(source.gridPos, loot)
