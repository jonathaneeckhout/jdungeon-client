extends Node

signal login(status: bool)


var cert = load("res://data/certs/X509_certificate.crt")

var logged_in = false
var cookie = ""


func connect_to_server(ip, port):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		print("Error while creating")
		return false

	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to connect to game")
		# OS.alert("Failed to start multiplayer client.")
		return false

	#TODO: Use this function instead of debug function
	# var client_tls_options = TLSOptions.client(cert)
	#TODO: Remove next line
	var client_tls_options = TLSOptions.client_unsafe(cert)
	error = peer.host.dtls_client_setup(ip, client_tls_options)
	if error != OK:
		print("Failed to connect via DTLS")
		return false

	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_connected_succeeded)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)

	return true


func _connected_succeeded():
	print("Connection succeeded")


func _server_disconnected():
	print("Server disconnected us")


func _connected_fail():
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