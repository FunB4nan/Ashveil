extends ObstacleInfo

class_name Chest

@export var loot : Dictionary[Item, int]

func actBeforeDeath(source):
	source.showPanel()

func onObstacleLiving(source):
	source.hidePanel()
