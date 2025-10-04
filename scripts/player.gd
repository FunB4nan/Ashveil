extends Node2D

class_name Player

const OFFSET = Vector2(16, 16)

var isMoving = false
var hp = 100

func _ready() -> void:
	Global.player = self
	UI.updateUI()

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
	$anim.play("moving")
	Global.main.playerLivingObstacle.emit((global_position - OFFSET) / 32)
	var danger = Global.main.openTile((global_position - OFFSET + vector) / 32)
	if danger != null:
		await TweenManager.moveTween(self, global_position + vector, 0.3)
		if danger > hp:
			kill()
			return
		else:
			hp -= danger
			UI.updateUI()
			print(hp)
			var pos = (global_position - OFFSET) / 32
			Global.main.deleteObstacle.emit(pos)
			if danger > 0:
				await TweenManager.moveTween(self, global_position - vector, 0.3)
	isMoving = false
	print((position - OFFSET) / 32)

func kill():
	Global.camera.shake(200,0.1,300)
	$anim.play("death")
	UI.playAnimation("gameOver")
