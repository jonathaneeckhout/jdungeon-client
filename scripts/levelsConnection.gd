extends Node

@onready var debug = Env.get_value("DEBUG")

signal login(status: bool)
signal player_added(id: int, character_name: String, pos: Vector2)
signal player_removed(character_name: String)
signal enemy_added(enemy_name: String, pos: Vector2)
signal enemy_removed(enemy_name: String)


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

	var client_tls_options: TLSOptions

	if debug =="true":
		client_tls_options = TLSOptions.client_unsafe()
	else:
		client_tls_options = TLSOptions.client()

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
	#TODO: figure out why this delay is needed
	await get_tree().create_timer(1).timeout

	authenticate_with_secret.rpc_id(1, CommonConnection.username, CommonConnection.secret, CommonConnection.username)


func _on_server_disconnected():
	print("Server disconnected us")


func _on_connection_failed():
	print("Connection failed")


@rpc("call_remote", "any_peer", "reliable")
func authenticate_with_secret(_username: String, _secret: String, _character: String):
	#Placeholder code
	pass


@rpc("call_remote", "authority", "reliable")
func client_login_response(succeeded: bool):
	print("Login %s" % [succeeded])
	logged_in = succeeded
	login.emit(succeeded)


@rpc("call_remote", "authority", "reliable")
func add_player(id: int, character_name: String, pos: Vector2):
	player_added.emit(id, character_name, pos)


@rpc("call_remote", "authority", "reliable")
func remove_player(character_name: String):
	player_removed.emit(character_name)


@rpc("call_remote", "any_peer", "reliable")
func move(_pos):
	#Placeholder code
	pass


@rpc("call_remote", "any_peer", "reliable")
func interact(_target: String):
	#Placeholder code
	pass


@rpc("call_remote", "authority", "reliable")
func add_enemy(enemy_name: String, pos: Vector2):
	enemy_added.emit(enemy_name, pos)


@rpc("call_remote", "authority", "reliable")
func remove_enemy(enemy_name: String):
	enemy_removed.emit(enemy_name)
