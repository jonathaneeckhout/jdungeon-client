extends Node

signal login(status: bool)
signal connected_to_server
signal server_disconnected
signal chat_message_received(type: String, from: String, message: String)

var auth_request = preload("res://scripts/requests/authRequest.gd")
var cookie = ""
var logged_in = false
var secret = ""
var socket = WebSocketPeer.new()
var username = ""
var _connected = false

@onready var debug = Env.get_value("DEBUG")


func _ready():
	set_process(false)


func connect_to_server(ip, port):
	socket.handshake_headers = ["cookie: %s" % cookie]

	var client_tls_options: TLSOptions

	if debug == "true":
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
	var res = await new_req.authenticate(player_username, str(password).sha256_text())
	new_req.queue_free()
	if res["response"]:
		logged_in = true
		username = player_username
		cookie = res["cookie"]
		secret = res["secret"]

	login.emit(res["response"])
	return res["response"]


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
	print("Switching to level %s on address %s on port %d" % [level, address, port])
	#Close the current connection
	LevelsConnection.disconnect_to_server()
	#Connect to the new level
	LevelsConnection.connect_to_server(address, port)
