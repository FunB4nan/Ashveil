extends ItemAction

class_name UsePills

func act(source):
	AudioManager.play("heal")
	Global.player.hp += 5
	UI.updateUI()
	source.subAmount(1)
