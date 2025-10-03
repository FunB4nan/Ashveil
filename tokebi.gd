# Tokebi Analytics SDK
extends Node

const API_KEY = "83ff640d-1940-4e1a-86c4-a1dce71549d9"
const ENDPOINT = "https://tokebi-api.vercel.app"

var game_name: String = ""
var game_id: String = ""
var player_id: String = ""

func _ready():
	print("[Tokebi] Initializing SDK...")
	game_name = ProjectSettings.get_setting("application/config/name", "Unnamed Godot Game")
	print("[Tokebi] Game Name: ", game_name)
	player_id = _get_or_create_player_id()
	print("[Tokebi] Player ID: ", player_id)
	_detect_multiplayer_mode()
	_register_game()

func _detect_multiplayer_mode():
	var multiplayer_api = get_tree().get_multiplayer()
	if not multiplayer_api.has_multiplayer_peer():
		print("[Tokebi] Mode: Single Player")
		return
	if multiplayer_api.is_server() or multiplayer_api.get_unique_id() == 1:
		print("[Tokebi] Mode: Host/Server - Will track")
		return
	else:
		print("[Tokebi] Mode: Client - Will NOT track")
		game_id = "client_no_track"

func _get_or_create_player_id() -> String:
	var file_path = "user://tokebi_player_id"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var id = file.get_line()
			file.close()
			return id
	var new_id = "player_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line(new_id)
		file.close()
	return new_id

func _register_game():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_register_response)
	var headers = ["Authorization: " + API_KEY, "Content-Type: application/json"]
	var body = {"gameName": game_name, "platform": "godot"}
	http.request(ENDPOINT + "/api/games", headers, HTTPClient.METHOD_POST, JSON.stringify(body))

func _on_register_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200 or response_code == 201:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK and json.data.has("game_id"):
			game_id = str(json.data.game_id)
			print("[Tokebi] Game registered! ID: ", game_id)
		else:
			print("[Tokebi] No game_id in response")
	else:
		print("[Tokebi] Registration failed with code: ", response_code)

func track(event_type: String, payload: Dictionary = {}, force_track: bool = false):
	if game_id == "client_no_track" and not force_track:
		print("[Tokebi] Skipping (client): ", event_type)
		return
	if game_id.is_empty() or player_id.is_empty():
		return
	var final_payload = payload.duplicate()
	if final_payload.is_empty():
		final_payload["timestamp"] = Time.get_unix_time_from_system()
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(r,c,h,b): http.queue_free())
	var headers = ["Authorization: " + API_KEY, "Content-Type: application/json"]
	var event_body = {
		"eventType": event_type,
		"payload": final_payload,
		"gameId": game_id,
		"playerId": player_id,
		"platform": "godot",
		"environment": "development" if OS.is_debug_build() else "production"
	}
	print("[Tokebi] Tracking: ", event_type, " PlayerId: ", player_id)
	http.request(ENDPOINT + "/api/track", headers, HTTPClient.METHOD_POST, JSON.stringify(event_body))

func track_level_start(level: String):
	track("level_start", {"level": level})

func track_level_complete(level: String, time_taken: float):
	track("level_complete", {"level": level, "time": time_taken})

func track_client_event(event_type: String, payload: Dictionary = {}):
	track(event_type, payload, true)
