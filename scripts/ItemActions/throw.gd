extends ItemAction

class_name Throw

func act(source):
	source.queue_free()
