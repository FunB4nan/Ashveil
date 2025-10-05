extends Button

@export var action : ItemAction

@onready var parent = get_parent().get_parent().get_parent().get_parent()

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	text = tr(action.title)
	pressed.connect(useAction)

func useAction():
	action.act(parent)
