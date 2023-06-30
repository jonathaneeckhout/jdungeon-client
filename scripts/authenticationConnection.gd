extends Node

signal login(status: bool)
signal connected_to_server
signal server_disconnected
signal chat_message_received(type: String, from: String, message:String)

const URL = "wss://localhost:4433"

var cert = load("res://data/certs/X509_certificate.crt")
var cookie = ""
var logged_in = false
var socket = WebSocketPeer.new()
var username = ""
var _connected = false


func _ready():
	set_process(false)


func connect_to_server(ip, port):
	var err = socket.connect_to_url("wss://%s:%d" % [ip, port], TLSOptions.client_unsafe(cert))
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
		"auth-response":
			_on_authenticate_response(data["auth"], data["cookie"])
		"load-character-response":
			_on_load_character_response(data["level"], data["address"], data["port"])
		"chat-message":
			_on_chat_message(data["type"], data["from"], data["message"])


func authenticate(player_username: String, password: String):
	username = player_username
	socket.send_text(
		JSON.stringify(
			{"type": "auth", "args": {"username": player_username, "password": str(password).sha256_text()}}
		)
	)


func _on_authenticate_response(succeeded: bool, login_cookie: String):
	print("Login %s, cookie=%s" % [succeeded, login_cookie])
	logged_in = succeeded
	cookie = login_cookie
	login.emit(succeeded)

	#TODO: open up character selection window, for now load the character with the player's name
	socket.send_text(
		JSON.stringify({"type": "load-character", "args": {"username": username, "character": username}})
	)


func send_message(type: String, target: String, message: String):
	socket.send_text(
		JSON.stringify(
			{"type": "send-chat-message", "args": {"type": type, "target": target, "message": message}}
		)
	)


func _on_chat_message(type: String, from: String, message:String):
	chat_message_received.emit(type, from, message)


func _on_load_character_response(level: String, address: String, port: int):
	print("Switching to level %s on address %s on port %d" % [level, address, port])
	#Close the current connection
	LevelsConnection.disconnect_to_server()
	#Connect to the new level
	LevelsConnection.connect_to_server(address, port)
