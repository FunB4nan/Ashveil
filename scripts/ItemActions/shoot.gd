extends ItemAction

class_name Shoot

func act(source):
	source.hideTooltip()
	var bullets = UI.findItem("bullets")
	if bullets == null || bullets.item.amount < source.item.usage:
		return
	var cell = await Global.main.chooseCellToAct(source.item.distance)
	AudioManager.play("shoot")
	await Global.player.playAnimation("shoot")
	if Global.main.map[cell] != 0:
		Global.main.map[cell] = Global.main.map[cell] - source.item.damage
		Global.main.cellEdited.emit(cell)
	bullets.subAmount(source.item.usage)
