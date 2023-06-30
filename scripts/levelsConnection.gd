extends Node


signal login(status: bool)
signal player_added(character_name: String, pos: Vector2)


var cert = load("res://data/certs/X509_certificate.crt")

var logged_in = false

var client = ENetMultiplayerPeer.new()


func connect_to_server(ip, port):
	var error = client.create_client(ip, port)
	if error != OK:
		print("Error while creating")
		return false

	if client.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to connect to game")
		# OS.alert("Failed to start multiplayer client.")
		return false

	#TODO: Use this function instead of debug function
	# var client_tls_options = TLSOptions.client(cert)
	#TODO: Remove next line
	var client_tls_options = TLSOptions.client_unsafe(cert)
	error = client.host.dtls_client_setup(ip, client_tls_options)
	if error != OK:
		print("Failed to connect via DTLS")
		return false

	multiplayer.multiplayer_peer = client

	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	return true


func disconnect_to_server():
	client.close()
	logged_in = false

func _on_connection_succeeded():
	print("Connection succeeded")
	#TODO: currently the character's name is the player's name
	authenticate_with_cookie.rpc_id(1, AuthenticationConnection.username, AuthenticationConnection.cookie, AuthenticationConnection.username)


func _on_server_disconnected():
	print("Server disconnected us")


func _on_connection_failed():
	print("Connection failed")


@rpc("call_remote", "any_peer", "reliable")
func authenticate_with_cookie(_username: String, _cookie: String, _character: String):
	#Placeholder code
	pass


@rpc("call_remote", "authority", "reliable")
func client_login_response(succeeded: bool):
	print("Login %s" % [succeeded])
	logged_in = succeeded
	login.emit(succeeded)


@rpc("call_remote", "authority", "reliable")
func add_player(character_name: String, pos: Vector2):
	player_added.emit(character_name, pos)


@rpc("call_remote", "any_peer", "reliable")
func move(_pos):
	#Placeholder code
	pass


@rpc("call_remote", "any_peer", "reliable")
func interact(_target: String):
	#Placeholder code
	pass
