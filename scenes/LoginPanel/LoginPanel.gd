extends Panel

@onready var server_address = Env.get_value("COMMON_SERVER_HOST")
@onready var server_port = int(Env.get_value("COMMON_SERVER_PORT"))
@onready var debug_username = Env.get_value("DEBUG_USERNAME")
@onready var debug_password = Env.get_value("DEBUG_PASSWORD")


func _ready():
	if debug_username:
		$VBoxContainer/UsernameText.text = debug_username

	if debug_password:
		$VBoxContainer/PasswordText.text = debug_password

	CommonConnection.connected_to_server.connect(_connected_succeeded)
	CommonConnection.server_disconnected.connect(_server_disconnected)


func _on_login_button_pressed():
	var username = $VBoxContainer/UsernameText.text
	var password = $VBoxContainer/PasswordText.text

	if username == "" or password == "":
		$VBoxContainer/ErrorLabel.text = "Invalid username or password"
		return false

	var logged_in = await CommonConnection.authenticate(username, password)
	if !logged_in:
		$VBoxContainer/ErrorLabel.text = "Login failed"
		print("Failed logging in to server")
		return false

	print("Successfully logged into server")

	if !CommonConnection.connect_to_server(server_address, server_port):
		$VBoxContainer/ErrorLabel.text = "Error conneting server"
		print("Failed to connect to server")
		return false

	$"../".hide()

	await CommonConnection.connected_to_server

	CommonConnection.load_character()

	return true


func _connected_succeeded():
	pass


func _server_disconnected():
	$VBoxContainer/ErrorLabel.text = "Disconnected from server"
	$".".show()
