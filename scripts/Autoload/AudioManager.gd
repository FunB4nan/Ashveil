extends Node

@export var sounds : Dictionary[String, AudioStream]
@export var musics : Dictionary[String, AudioStream]

var currentMusic : String = ""

func _ready() -> void:
	for sound in sounds.keys():
		var soundInst = AudioStreamPlayer.new()
		soundInst.name = sound
		soundInst.stream = sounds[sound]
		soundInst.bus = "sfx"
		add_child(soundInst)
	for music in musics.keys():
		var musicInst = AudioStreamPlayer.new()
		musicInst.name = music
		musicInst.stream = musics[music]
		musicInst.bus = "music"
		add_child(musicInst)
		musicInst.finished.connect(_on_audio_finished)

func _on_audio_finished():
	if currentMusic == "mainStart" || currentMusic == "switchToMain":
		play("mainLoop", false)
		return
	if currentMusic == "switchToBoss":
		play("bossLoop", false)
		return

func play(title : String, withTransition : bool = true):
	if title in sounds.keys():
		get_node(title).play()
	elif title in musics.keys():
		if title == currentMusic:
			return
		var newMusic = get_node(title)
		if withTransition:
			newMusic.volume_db = -20.0
		else:
			newMusic.volume_db = 0.0
		newMusic.play()
		if withTransition:
			var tween = create_tween().bind_node(self)
			tween.tween_property(newMusic, "volume_db", 0.0, 0.5)
			tween.play()
			if currentMusic != "":
				var oldMusic = get_node(currentMusic)
				var oldTween = create_tween().bind_node(self)
				oldTween.tween_property(oldMusic, "volume_db", -20.0, 0.5)
				oldTween.play()
			await tween.finished
		if currentMusic != "":
			get_node(currentMusic).stop()
		currentMusic = title
	else:
		print("no audio found")

func stop(title : String):
	currentMusic = ""
	get_node(title).stop()
