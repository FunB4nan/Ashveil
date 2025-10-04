extends Node2D

var isMoving = false

func _input(event: InputEvent) -> void:
	if isMoving:
		return
	if event.is_action_pressed("ui_right"):
		move(Vector2(32, 0))
	elif event.is_action_pressed("ui_left"):
		move(Vector2(-32, 0))
	elif event.is_action_pressed("ui_up"):
		move(Vector2(0, -32))
	elif event.is_action_pressed("ui_down"):
		move(Vector2(0, 32))

func move(vector : Vector2):
	isMoving = true
	await TweenManager.moveTween(self, global_position + vector)
	isMoving = false
