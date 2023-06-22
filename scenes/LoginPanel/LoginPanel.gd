extends Panel


func _ready():
	PlayersConnection.multiplayer_api.connected_to_server.connect(_connected_succeeded)
	PlayersConnection.multiplayer_api.connection_failed.connect(_connected_fail)
	PlayersConnection.multiplayer_api.server_disconnected.connect(_server_disconnected)


func _on_login_button_pressed():
	var ip = $VBoxContainer/ServerAddressText.text
	var port = int($VBoxContainer/ServerPortText.text)
	var username = $VBoxContainer/UsernameText.text
	var password = $VBoxContainer/PasswordText.text

	if username == "" or password == "":
		$VBoxContainer/ErrorLabel.text = "Invalid username or password"
		return false

	if !PlayersConnection.connect_to_server(ip, port):
		$VBoxContainer/ErrorLabel.text = "Error conneting server"
		print("Failed to connect to server")
		return false

	await PlayersConnection.multiplayer_api.connected_to_server

	PlayersConnection.authenticate.rpc_id(1, username, password)

	var logged_in = await PlayersConnection.login
	if !logged_in:
		$VBoxContainer/ErrorLabel.text = "Login failed"
		print("Failed logging in to server")
		return false

	$"../".hide()

	return true


func _connected_succeeded():
	pass


func _server_disconnected():
	$VBoxContainer/ErrorLabel.text = "Disconnected from server"
	$".".show()


func _connected_fail():
	$VBoxContainer/ErrorLabel.text = "Error conneting server"
	$".".show()
