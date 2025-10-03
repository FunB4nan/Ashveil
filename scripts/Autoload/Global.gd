extends Node

signal localeChaged

var musicValume = 100
var sfxValume = 100
var crtOn = true

const languages = ["english","русский"]

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	await Talo.players.identify("dev", "me")
	Talo.events.track("New Entry", {"Level" : "0"})
	print("success")
