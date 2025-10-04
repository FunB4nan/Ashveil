extends TextureButton

@export var item : Item
var amount : int = 0
var parent : Obstacle

func _ready() -> void:
	texture_normal = item.sprite
	%Name.text = tr(item.title) 
	%Description.text = tr(item.title + "Desc")
	mouse_entered.connect(showTooltip)
	mouse_exited.connect(hideTooltip)
	pressed.connect(addItem)

func addItem():
	if UI.getItemCount() < Global.main.inventorySize:
		UI.addItem(item, amount)
		parent.deleteItem(self)

func showTooltip():
	$tooltip.visible = true

func hideTooltip():
	$tooltip.visible = false
