extends Node

func scaleTween(node, newValue : Vector2, time : float = 0.1):
	var tween = create_tween().bind_node(node)
	tween.tween_property(node, "scale", newValue, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.play()
	await tween.finished

func moveTween(node, newValue : Vector2, time : float = 0.1):
	var tween = create_tween().bind_node(node)
	tween.tween_property(node, "position", newValue, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.play()
	await tween.finished

func rotationTween(node, newValue : float, time : float = 0.1):
	var tween = create_tween().bind_node(node)
	tween.tween_property(node, "rotation_degrees", newValue, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.play()
	await tween.finished
