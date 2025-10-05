extends CanvasLayer

var itemSlot = preload("res://prefabs/UI/itemSlot.tscn")
var damageLabel = preload("res://prefabs/UI/damageLabel.tscn")
var messageLabel = preload("res://prefabs/UI/messageLabel.tscn")

var gameLoaded = false
var languageIndex = 0

var itemUseShown = false

func _ready() -> void:
	updateSettings()
	connect_all_buttons(self)

func connect_all_buttons(node: Node) -> void:
	if node is BaseButton:
		node.mouse_entered.connect(_on_any_button_mouse_entered)
		node.mouse_exited.connect(_on_any_button_mouse_exited)
	for child in node.get_children():
		connect_all_buttons(child)

func _on_any_button_mouse_entered():
	$cursor.switchState($cursor.sprites.CLICK)
	
func _on_any_button_mouse_exited():
	$cursor.switchState($cursor.sprites.DEFAULT)

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

func updateUI():
	if int(%hp.text) != Global.player.hp:
		var labelInst = damageLabel.instantiate()
		labelInst.value = Global.player.hp - int(%hp.text)
		labelInst.position = Vector2(507, 638)
		add_child(labelInst)
	%hp.text = str(Global.player.hp)

func hideAllTooltips(source):
	for slot in %inventory.get_children():
		if slot != source:
			slot.hideTooltip()

func addItem(item : Item, amount = 0):
	for slot in %inventory.get_children():
		if slot.item.title == item.title && item.canStack:
			slot.item.amount += amount
			slot.update()
			return
	var slotInst = itemSlot.instantiate()
	slotInst.item = item
	slotInst.item.amount = amount
	%inventory.add_child(slotInst)
	slotInst.mouse_entered.connect(_on_any_button_mouse_entered)
	slotInst.mouse_exited.connect(_on_any_button_mouse_exited)
	if !itemUseShown:
		$anim.play("pointOnItem")
		itemUseShown = true

func findItem(title : String):
	for slot in %inventory.get_children():
		if slot.item.title == title:
			return slot
	return null

func getItemCount():
	return %inventory.get_child_count()

func showMessage(line : String):
	var labelInst = messageLabel.instantiate()
	labelInst.line = line
	labelInst.global_position = $cursor.position
	add_child(labelInst)

func toggleHint(state : bool):
	%cancelHint.visible = state

func playAnimation(anim : String):
	$anim.play(anim)

func hideMoveTutorial():
	if $howToMove.modulate == Color(1.0, 1.0, 1.0, 0.0):
		return
	$anim.play("hideTutorial")

func showTutorial(sprite : String):
	$tutorial.visible = true
	%tutorTitle.text = tr(sprite)
	%tutorDescription.text = tr(sprite + "Desc")
	%tutorImage.texture = load("res://sprites/%s.png" % sprite)

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


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
	$anim.play("RESET")
	for item in %inventory.get_children():
		item.queue_free()
	await get_tree().create_timer(0.1).timeout
	addItem(load("res://premadeResources/weapons/pistol.tres"), 1)


func _on_close_tutor_pressed() -> void:
	$tutorial.visible = false
	if %tutorTitle.text == tr("sumTutor"):
		showTutorial("checkTutor")


func _on_continue_button_pressed() -> void:
	AudioManager.play("forest")
	$anim.play_backwards("win")
