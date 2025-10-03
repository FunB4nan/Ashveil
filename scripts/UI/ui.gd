extends CanvasLayer

var gameLoaded = false
var languageIndex = 0

func _ready() -> void:
	updateSettings()

func updateSettings(value = 0.0):
	if gameLoaded:
		if value is bool:
			Global.crtOn = value
		Global.musicValume = %musicSlider.value
		Global.sfxValume = %sfxSlider.value
	else:
		%crt.button_pressed = Global.crtOn
		%musicSlider.value = Global.musicValume
		%sfxSlider.value = Global.sfxValume
		gameLoaded = true
	match Global.languages[languageIndex]:
		"русский":
			if TranslationServer.get_locale() != "ru":
				TranslationServer.set_locale("ru")
				Global.localeChaged.emit()
		"english":
			if TranslationServer.get_locale() != "en":
				TranslationServer.set_locale("en")
				Global.localeChaged.emit()
	$crt.visible = Global.crtOn
	if Global.musicValume > 0:
		AudioServer.set_bus_volume_db(1, Global.musicValume / 4.16 - 24)
		AudioServer.set_bus_mute(1,false)
	else:
		AudioServer.set_bus_mute(1,true)
	if Global.sfxValume > 0:
		AudioServer.set_bus_volume_db(2, Global.sfxValume / 4.16 - 24)
		AudioServer.set_bus_mute(2,false)
	else:
		AudioServer.set_bus_mute(2,true)
	%previousLanguage.disabled = languageIndex == 0
	%nextLanguage.disabled = languageIndex == Global.languages.size() - 1
	%languageTitle.text = Global.languages[languageIndex]
	%music.text = str(int(%musicSlider.value),"%")
	%sfx.text = str(int(%sfxSlider.value),"%")


func _on_previous_language_pressed() -> void:
	if languageIndex > 0:
		languageIndex -= 1
	updateSettings()


func _on_next_language_pressed() -> void:
	if languageIndex < Global.languages.size() - 1:
		languageIndex += 1
	updateSettings()


func _on_close_settings_pressed() -> void:
	%settings.visible = false


func _on_settings_pressed() -> void:
	%settings.visible = true
