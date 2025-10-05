extends TextureButton

@export var item : Item
var amount : int = 0
var parent : Obstacle

func _ready() -> void:
	texture_normal = item.sprite
	%Name.text = tr(item.title) 
	%Description.text = tr(item.title + "Desc")
	$amount.text = str(amount)
	$tooltip.position = Vector2(-$tooltip.size.x / 4, - $tooltip.size.y - 32)
	$tooltip.visible = false
	mouse_entered.connect(showTooltip)
	mouse_exited.connect(hideTooltip)
	pressed.connect(addItem)

func addItem():
	var willStack = UI.findItem(item.title) != null && item.canStack
	if UI.getItemCount() < Global.main.inventorySize || willStack:
		AudioManager.play("pickup", false, true)
		UI.addItem(item, amount)
		parent.deleteItem(self)

func showTooltip():
	UI._on_any_button_mouse_entered()
	AudioManager.play("Abstract", false, true)
	$tooltip.visible = true
	TweenManager.scaleTween(self, Vector2(1.1, 1.1))

func hideTooltip():
	UI._on_any_button_mouse_exited()
	$tooltip.visible = false
	TweenManager.scaleTween(self, Vector2.ONE)
