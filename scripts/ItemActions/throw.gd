extends ItemAction

class_name Throw

func act(source):
	AudioManager.play("pickup")
	source.throw()
