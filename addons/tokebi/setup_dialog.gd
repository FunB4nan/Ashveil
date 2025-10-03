@tool
extends Control

var api_key_input: LineEdit

func _ready():
	_create_ui()

func _create_ui():
	var vbox = VBoxContainer.new()
	add_child(vbox)
	var title = Label.new()
	title.text = "Tokebi SDK Setup"
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())
	var game_info = Label.new()
	game_info.text = "Game: " + ProjectSettings.get_setting("application/config/name", "Unnamed Godot Game")
	game_info.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(game_info)
	vbox.add_child(HSeparator.new())
	var api_label = Label.new()
	api_label.text = "API Key:"
	vbox.add_child(api_label)
	api_key_input = LineEdit.new()
	api_key_input.placeholder_text = "Enter your API key"
	api_key_input.secret = true
	vbox.add_child(api_key_input)
	var install_btn = Button.new()
	install_btn.text = "Install SDK"
	install_btn.pressed.connect(_on_install_pressed)
	vbox.add_child(install_btn)

func _on_install_pressed():
	var api_key = api_key_input.text.strip_edges()
	if api_key.is_empty():
		print("[Tokebi] ERROR: API Key is required")
		return
	_install_sdk(api_key)

func _install_sdk(api_key: String):
	var sdk_content = "# Tokebi Analytics SDK\n"
	sdk_content += "extends Node\n\n"
	sdk_content += "const API_KEY = \"" + api_key + "\"\n"
	sdk_content += "const ENDPOINT = \"https://tokebi-api.vercel.app\"\n\n"
	sdk_content += "var game_name: String = \"\"\n"
	sdk_content += "var game_id: String = \"\"\n"
	sdk_content += "var player_id: String = \"\"\n\n"
	sdk_content += "func _ready():\n"
	sdk_content += "\tprint(\"[Tokebi] Initializing SDK...\")\n"
	sdk_content += "\tgame_name = ProjectSettings.get_setting(\"application/config/name\", \"Unnamed Godot Game\")\n"
	sdk_content += "\tprint(\"[Tokebi] Game Name: \", game_name)\n"
	sdk_content += "\tplayer_id = _get_or_create_player_id()\n"
	sdk_content += "\tprint(\"[Tokebi] Player ID: \", player_id)\n"
	sdk_content += "\t_detect_multiplayer_mode()\n"
	sdk_content += "\t_register_game()\n\n"
	sdk_content += "func _detect_multiplayer_mode():\n"
	sdk_content += "\tvar multiplayer_api = get_tree().get_multiplayer()\n"
	sdk_content += "\tif not multiplayer_api.has_multiplayer_peer():\n"
	sdk_content += "\t\tprint(\"[Tokebi] Mode: Single Player\")\n"
	sdk_content += "\t\treturn\n"
	sdk_content += "\tif multiplayer_api.is_server() or multiplayer_api.get_unique_id() == 1:\n"
	sdk_content += "\t\tprint(\"[Tokebi] Mode: Host/Server - Will track\")\n"
	sdk_content += "\t\treturn\n"
	sdk_content += "\telse:\n"
	sdk_content += "\t\tprint(\"[Tokebi] Mode: Client - Will NOT track\")\n"
	sdk_content += "\t\tgame_id = \"client_no_track\"\n\n"
	sdk_content += "func _get_or_create_player_id() -> String:\n"
	sdk_content += "\tvar file_path = \"user://tokebi_player_id\"\n"
	sdk_content += "\tif FileAccess.file_exists(file_path):\n"
	sdk_content += "\t\tvar file = FileAccess.open(file_path, FileAccess.READ)\n"
	sdk_content += "\t\tif file:\n"
	sdk_content += "\t\t\tvar id = file.get_line()\n"
	sdk_content += "\t\t\tfile.close()\n"
	sdk_content += "\t\t\treturn id\n"
	sdk_content += "\tvar new_id = \"player_\" + str(Time.get_unix_time_from_system()) + \"_\" + str(randi() % 10000)\n"
	sdk_content += "\tvar file = FileAccess.open(file_path, FileAccess.WRITE)\n"
	sdk_content += "\tif file:\n"
	sdk_content += "\t\tfile.store_line(new_id)\n"
	sdk_content += "\t\tfile.close()\n"
	sdk_content += "\treturn new_id\n\n"
	sdk_content += "func _register_game():\n"
	sdk_content += "\tvar http = HTTPRequest.new()\n"
	sdk_content += "\tadd_child(http)\n"
	sdk_content += "\thttp.request_completed.connect(_on_register_response)\n"
	sdk_content += "\tvar headers = [\"Authorization: \" + API_KEY, \"Content-Type: application/json\"]\n"
	sdk_content += "\tvar body = {\"gameName\": game_name, \"platform\": \"godot\"}\n"
	sdk_content += "\thttp.request(ENDPOINT + \"/api/games\", headers, HTTPClient.METHOD_POST, JSON.stringify(body))\n\n"
	sdk_content += "func _on_register_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):\n"
	sdk_content += "\tif response_code == 200 or response_code == 201:\n"
	sdk_content += "\t\tvar json = JSON.new()\n"
	sdk_content += "\t\tif json.parse(body.get_string_from_utf8()) == OK and json.data.has(\"game_id\"):\n"
	sdk_content += "\t\t\tgame_id = str(json.data.game_id)\n"
	sdk_content += "\t\t\tprint(\"[Tokebi] Game registered! ID: \", game_id)\n"
	sdk_content += "\t\telse:\n"
	sdk_content += "\t\t\tprint(\"[Tokebi] No game_id in response\")\n"
	sdk_content += "\telse:\n"
	sdk_content += "\t\tprint(\"[Tokebi] Registration failed with code: \", response_code)\n\n"
	sdk_content += "func track(event_type: String, payload: Dictionary = {}, force_track: bool = false):\n"
	sdk_content += "\tif game_id == \"client_no_track\" and not force_track:\n"
	sdk_content += "\t\tprint(\"[Tokebi] Skipping (client): \", event_type)\n"
	sdk_content += "\t\treturn\n"
	sdk_content += "\tif game_id.is_empty() or player_id.is_empty():\n"
	sdk_content += "\t\treturn\n"
	sdk_content += "\tvar final_payload = payload.duplicate()\n"
	sdk_content += "\tif final_payload.is_empty():\n"
	sdk_content += "\t\tfinal_payload[\"timestamp\"] = Time.get_unix_time_from_system()\n"
	sdk_content += "\tvar http = HTTPRequest.new()\n"
	sdk_content += "\tadd_child(http)\n"
	sdk_content += "\thttp.request_completed.connect(func(r,c,h,b): http.queue_free())\n"
	sdk_content += "\tvar headers = [\"Authorization: \" + API_KEY, \"Content-Type: application/json\"]\n"
	sdk_content += "\tvar event_body = {\n"
	sdk_content += "\t\t\"eventType\": event_type,\n"
	sdk_content += "\t\t\"payload\": final_payload,\n"
	sdk_content += "\t\t\"gameId\": game_id,\n"
	sdk_content += "\t\t\"playerId\": player_id,\n"
	sdk_content += "\t\t\"platform\": \"godot\",\n"
	sdk_content += "\t\t\"environment\": \"development\" if OS.is_debug_build() else \"production\"\n"
	sdk_content += "\t}\n"
	sdk_content += "\tprint(\"[Tokebi] Tracking: \", event_type, \" PlayerId: \", player_id)\n"
	sdk_content += "\thttp.request(ENDPOINT + \"/api/track\", headers, HTTPClient.METHOD_POST, JSON.stringify(event_body))\n\n"
	sdk_content += "func track_level_start(level: String):\n"
	sdk_content += "\ttrack(\"level_start\", {\"level\": level})\n\n"
	sdk_content += "func track_level_complete(level: String, time_taken: float):\n"
	sdk_content += "\ttrack(\"level_complete\", {\"level\": level, \"time\": time_taken})\n\n"
	sdk_content += "func track_client_event(event_type: String, payload: Dictionary = {}):\n"
	sdk_content += "\ttrack(event_type, payload, true)\n"
	var file = FileAccess.open("res://tokebi.gd", FileAccess.WRITE)
	if file:
		file.store_string(sdk_content)
		file.close()
		print("[Tokebi] SDK installed! Add to AutoLoad: Tokebi -> res://tokebi.gd")
	else:
		print("[Tokebi] Failed to write SDK file")
