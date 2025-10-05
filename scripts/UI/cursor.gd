extends TextureRect

enum sprites{
	DEFAULT,
	AIM,
	CLICK
}
var state = sprites.DEFAULT

func _process(delta: float) -> void:
	global_position = get_global_mouse_position() - Vector2(10, 10)

func switchState(s):
	if Global.main.isChoosingCell:
		return
	state = s
	match state:
		sprites.DEFAULT:
			texture.region = Rect2(709, 5, 22, 23)
		sprites.AIM:
			texture.region = Rect2(677, 36, 23, 23)
		sprites.CLICK:
			texture.region = Rect2(711, 38, 22, 23)
