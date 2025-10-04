extends Node2D

class_name Player

const OFFSET = Vector2(16, 16)

var gridPos : Vector2i = Vector2i.ZERO
var isMoving = false
var hp = 20

func _ready() -> void:
	Global.player = self
	UI.updateUI()

func _input(event: InputEvent) -> void:
	if isMoving:
		return
	if event.is_action_pressed("ui_right"):
		move(Vector2i(1, 0))
	elif event.is_action_pressed("ui_left"):
		move(Vector2i(-1, 0))
	elif event.is_action_pressed("ui_up"):
		move(Vector2i(0, -1))
	elif event.is_action_pressed("ui_down"):
		move(Vector2i(0, 1))

func move(vector : Vector2i):
	isMoving = true
	$anim.play("moving")
	Global.main.playerLivingObstacle.emit(gridPos)
	var danger = Global.main.openTile(gridPos + vector)
	if danger != null:
		gridPos += vector
		Global.main.moveDay()
		await TweenManager.moveTween(self, global_position + Vector2(vector) * 32, 0.3)
		if danger > hp:
			kill()
			return
		else:
			hp -= danger
			Global.main.map[gridPos] -= danger
			Global.main.cellEdited.emit(gridPos)
			UI.updateUI()
			print(hp)
			if danger > 0:
				gridPos -= vector
				await TweenManager.moveTween(self, global_position - Vector2(vector) * 32, 0.3)
				Global.main.openTile(gridPos + vector)
	isMoving = false
	print((position - OFFSET) / 32)

func kill():
	Global.camera.shake(200,0.1,300)
	$anim.play("death")
	UI.playAnimation("gameOver")
