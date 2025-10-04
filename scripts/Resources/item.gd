extends Resource

class_name Item

@export var sprite : Texture = preload("res://premadeResources/defaultObstacleSprite.tres")
@export var title : String
@export var buttons : Array[ItemAction] = []
@export var initialEffects : Array[ItemAction] = []
@export var amount : int = 1
@export var canStack : bool = true
