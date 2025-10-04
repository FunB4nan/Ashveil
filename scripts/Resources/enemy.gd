extends ObstacleInfo

class_name Enemy

@export var loot : Dictionary[Item, int]
@export var createdChest = false

#func actBeforeDeath(source):
	#if createdChest:
		#return
	#Global.main.createChest(source.gridPos, loot)
	#createdChest = true
