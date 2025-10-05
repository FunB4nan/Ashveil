extends ItemAction

class_name Flashlight

func act(source):
	var playerPos = Global.player.gridPos
	for x in range(playerPos.x - 1, playerPos.x + 2):
		for y in range(playerPos.y - 1, playerPos.x + 2):
			Global.main.openTile(Vector2i(x, y))
	source.subAmount(1)
