extends Node2D

class_name Player

const OFFSET = Vector2(16, 16)

var gridPos : Vector2i = Vector2i.ZERO
var isMoving = true
var hp = 20

func _ready() -> void:
	Global.player = self
	UI.updateUI()
	await Global.mapGenerated
	await get_tree().create_timer(0.3).timeout
	await TweenManager.moveTween($camera, Global.main.elementalPos * 32, 1.0)
	await TweenManager.moveTween($camera, Vector2.ZERO, 1.0)
	UI.playAnimation("showTutorial")
	isMoving = false

func _input(event: InputEvent) -> void:
	if isMoving || UI.get_node("tutorial").visible || Global.main.isChoosingCell:
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
	UI.hideMoveTutorial()
	isMoving = true
	$anim.play("moving")
	Global.main.playerLivingObstacle.emit(gridPos)
	var danger = await Global.main.openTile(gridPos + vector)
	AudioManager.play("step", true, true)
	if danger != null:
		gridPos += vector
		Global.main.moveDay()
		await TweenManager.moveTween(self, global_position + Vector2(vector) * 32, 0.4)
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
				await TweenManager.moveTween(self, global_position - Vector2(vector) * 32, 0.4)
				Global.main.openTile(gridPos + vector)
	isMoving = false
	print((position - OFFSET) / 32)

func playAnimation(anim : String):
	$anim.play(anim)
	await $anim.animation_finished

func kill():
	AudioManager.play("gameOver")
	Global.camera.shake(200,0.1,300)
	$anim.play("death")
	UI.playAnimation("gameOver")
