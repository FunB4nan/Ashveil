extends ItemAction

class_name Shoot

func act(source):
	source.hideTooltip()
	var bullets = UI.findItem("bullets")
	if bullets == null || bullets.item.amount < source.item.usage:
		UI.showMessage("no_bullets")
		return
	var cell = await Global.main.chooseCellToAct(source.item.distance)
	if cell == null:
		return
	AudioManager.play("shoot")
	await Global.player.playAnimation("shoot")
	if Global.main.map[cell] != 0:
		Global.main.map[cell] = Global.main.map[cell] - source.item.damage
		Global.main.cellEdited.emit(cell)
	Global.main.openTile(cell)
	bullets.subAmount(source.item.usage)
