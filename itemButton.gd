extends Button

@export var action : ItemAction

@onready var parent = get_parent().get_parent().get_parent().get_parent()

func _ready() -> void:
	text = action.title
	pressed.connect(useAction)

func useAction():
	action.act(parent)
