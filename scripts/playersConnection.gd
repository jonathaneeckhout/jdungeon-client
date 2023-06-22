extends Node

signal login(status: bool)


var cert = load("res://data/certs/X509_certificate.crt")

var logged_in = false
var cookie = ""

var client = ENetMultiplayerPeer.new()
var multiplayer_api : MultiplayerAPI = MultiplayerAPI.create_default_interface()

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

	get_tree().set_multiplayer(multiplayer_api, self.get_path()) 
	multiplayer_api.multiplayer_peer = client

	multiplayer_api.connected_to_server.connect(_on_connection_succeeded)
	multiplayer_api.connection_failed.connect(_on_connection_failed)
	multiplayer_api.server_disconnected.connect(_on_server_disconnected)

	return true


func _on_connection_succeeded():
	print("Connection succeeded")


func _on_server_disconnected():
	print("Server disconnected us")


func _on_connection_failed():
	print("Connection failed")


@rpc("call_remote", "any_peer", "reliable")
func authenticate(_username: String, _password: String):
	#Placeholder code for client
	pass


@rpc("call_remote", "authority", "reliable") 
func client_login_response(succeeded: bool, login_cookie: String):
	print("Login %s, cookie=%s" % [succeeded, login_cookie])
	logged_in = succeeded
	cookie = login_cookie
	login.emit(succeeded)