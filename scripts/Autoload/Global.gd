extends Node

signal localeChaged

const languages = ["english","русский"]

var musicValume = 100
var sfxValume = 100
var crtOn = true

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	await get_tree().create_timer(1).timeout
	await Talo.players.identify("dev", str(rng.seed))
	Talo.events.track("New Entry")
	print("success")
