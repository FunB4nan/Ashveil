extends TextureButton

var itemButton = preload("res://prefabs/UI/itemButton.tscn")
@export var item : Item
var amount : int = 1

func _ready() -> void:
	updateTooltip()
	$tooltip.visible = false
	update()
	for button in item.buttons:
		var buttonInst = itemButton.instantiate()
		buttonInst.action = button
		%actionButtons.add_child(buttonInst)
		buttonInst.mouse_entered.connect(UI._on_any_button_mouse_entered)
		buttonInst.mouse_exited.connect(UI._on_any_button_mouse_exited)
	pressed.connect(toggleTooltip)
	mouse_entered.connect(onMouseEntered)
	mouse_exited.connect(onMouseExited)

func onMouseEntered():
	AudioManager.play("Abstract", false, true)
	TweenManager.scaleTween(self, Vector2(1.1, 1.1))

func onMouseExited():
	TweenManager.scaleTween(self, Vector2.ONE)

func toggleTooltip():
	if Global.main.isChoosingCell || Global.player.isMoving:
		return
	if UI.get_node("itemTutor").visible:
		UI.get_node("anim").stop()
		UI.get_node("itemTutor").visible = false
	AudioManager.play("Abstract", false, true)
	UI.hideAllTooltips(self)
	$tooltip.visible = !$tooltip.visible
	updateTooltip()

func hideTooltip():
	$tooltip.visible = false

func updateTooltip():
	$tooltip.position = Vector2(-$tooltip.size.x / 4, - $tooltip.size.y)
	texture_normal.region = item.sprite.region
	%Name.text = tr(item.title)
	if item is Weapon:
		%Description.text = tr("weaponStats") % [item.damage, item.distance, item.usage]
	else:
		%Description.text = tr(item.title + "Desc")

func subAmount(value : int):
	item.amount -= value
	update()
	if item.amount <= 0:
		throw()

func throw():
	pivot_offset = Vector2(24, 24)
	$tooltip.visible = false
	$back.visible = false
	$amount.visible = false
	TweenManager.moveTween(self, position + Vector2(0, 100), 2)
	await TweenManager.rotationTween(self, 360, 2)
	queue_free()

func update():
	$amount.text = str(item.amount)
