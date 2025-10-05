extends ItemAction

class_name ThrowCocktail

func act(source):
	source.hideTooltip()
	var cell = await Global.main.chooseCellToAct(5)
	await Global.main.throwProjectile("cocktail", cell)
	AudioManager.play("molotov")
	if Global.main.map[cell] != 0:
		Global.main.map[cell] = Global.main.map[cell] - 3
		Global.main.cellEdited.emit(cell)
	for x in range(cell.x - 1, cell.x + 2):
		for y in range(cell.y - 1, cell.y + 2):
			Global.main.openTile(Vector2i(x, y))
	source.subAmount(1)
