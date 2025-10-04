extends TextureButton

var itemButton = preload("res://prefabs/UI/itemButton.tscn")
@export var item : Item
var amount : int = 1

func _ready() -> void:
	$tooltip.position = Vector2(-$tooltip.size.x / 2, - $tooltip.size.y - 32)
	$tooltip.visible = false
	texture_normal = item.sprite
	%Name.text = tr(item.title) 
	%Description.text = tr(item.title + "Desc")
	update()
	for button in item.buttons:
		var buttonInst = itemButton.instantiate()
		buttonInst.action = button
		%actionButtons.add_child(buttonInst)
	pressed.connect(toggleTooltip)

func toggleTooltip():
	$tooltip.visible = !$tooltip.visible

func update():
	$amount.text = str(item.amount)
