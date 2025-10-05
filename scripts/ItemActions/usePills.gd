extends ItemAction

class_name UsePills

func act(source):
	Global.player.hp += 5
	UI.updateUI()
	source.subAmount(1)
