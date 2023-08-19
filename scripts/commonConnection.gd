extends Node

signal login(status: bool)
signal connected_to_server
signal server_disconnected
signal character_loaded(level: String, address: String, port: int)
signal chat_message_received(type: String, from: String, message: String)

var auth_request = preload("res://scripts/requests/authRequest.gd")
var get_characters_request = preload("res://scripts/requests/getCharactersRequest.gd")
var create_character_request = preload("res://scripts/requests/createCharacterRequest.gd")
var get_level_request = preload("res://scripts/requests/getLevelRequest.gd")
var get_level_info_request = preload("res://scripts/requests/getLevelInfoRequest.gd")

var cookie = ""
var logged_in = false
var secret = ""
var socket = WebSocketPeer.new()
var username = ""
var _connected = false


func _ready():
	set_process(false)


func connect_to_server(ip, port):
	socket.handshake_headers = ["cookie: %s" % cookie]

	var client_tls_options: TLSOptions

	if Global.env_debug:
		client_tls_options = TLSOptions.client_unsafe()
	else:
		client_tls_options = TLSOptions.client()

	var err = socket.connect_to_url("wss://%s:%d" % [ip, port], client_tls_options)
	if err != OK:
		print("Unable to connect")
		set_process(false)
		return false

	set_process(true)

	return true


func disconnect_from_server():
	socket.close()


func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !_connected:
			_connected = true
			_on_connected()
		while socket.get_available_packet_count():
			_on_message_received(socket.get_packet().get_string_from_utf8())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		if _connected:
			_connected = false
			_on_disconnect()
		set_process(false)  # Stop processing.


func _on_connected():
	print("Websocket connected")
	connected_to_server.emit()


func _on_disconnect():
	print("Websocket disconnected")
	server_disconnected.emit()


func _on_message_received(message: String):
	# print("Received message: %s" % message)
	var res = JSON.parse_string(message)

	if res["error"]:
		print("Error in message, reason=[%s]" % res["reason"])
		return

	var data = res["data"]

	match res["type"]:
		"load-character-response":
			_on_load_character_response(data["level"], data["address"], data["port"])
		"chat-message":
			_on_chat_message(data["type"], data["from"], data["message"])


func authenticate(player_username: String, password: String):
	var new_req = auth_request.new()
	add_child(new_req)
	var res = await new_req.authenticate(player_username, password)
	new_req.queue_free()
	if res["response"]:
		logged_in = true
		username = player_username
		cookie = res["cookie"]
		secret = res["secret"]

	login.emit(res["response"])
	return res["response"]


func get_characters():
	var new_req = get_characters_request.new()
	add_child(new_req)
	var res = await new_req.get_characters(cookie)
	new_req.queue_free()

	return res


func create_character(character_name: String):
	var new_req = create_character_request.new()
	add_child(new_req)
	var res = await new_req.create_character(character_name, cookie)
	new_req.queue_free()

	return res


func get_level(level_name: String):
	var new_req = get_level_request.new()
	add_child(new_req)
	var res = await new_req.get_level(level_name, cookie)
	new_req.queue_free()

	return res


func get_level_info(level_name: String, level_hash: int):
	var new_req = get_level_info_request.new()
	add_child(new_req)
	var res = await new_req.get_level_info(level_name, level_hash, cookie)
	new_req.queue_free()

	return res


func load_character():
	#TODO: open up character selection window, for now load the character with the player's name
	socket.send_text(
		JSON.stringify(
			{"type": "load-character", "args": {"username": username, "character": username}}
		)
	)


func send_message(type: String, target: String, message: String):
	socket.send_text(
		JSON.stringify(
			{
				"type": "send-chat-message",
				"args": {"type": type, "target": target, "message": message}
			}
		)
	)


func _on_chat_message(type: String, from: String, message: String):
	chat_message_received.emit(type, from, message)


func _on_load_character_response(level: String, address: String, port: int):
	character_loaded.emit(level, address, port)
	# print("Switching to level %s on address %s on port %d" % [level, address, port])
	# #Close the current connection
	# LevelsConnection.disconnect_to_server()
	# #Connect to the new level
	# LevelsConnection.connect_to_server(address, port)
