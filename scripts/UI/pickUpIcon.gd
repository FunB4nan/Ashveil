extends TextureRect

func _ready() -> void:
	await TweenManager.moveTween(self, Vector2(386, 652), 0.1, true)
	queue_free()
