extends ObstacleInfo

class_name Chest

@export var loot : Dictionary[Item, Array]

func actBeforeDeath(source):
	source.showPanel()

func onObstacleLiving(source):
	source.hidePanel()
