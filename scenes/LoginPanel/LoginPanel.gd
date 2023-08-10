extends Panel

var current_level = ""
var current_player = null

@onready var level = $"../../Level"
@onready var loading_panel = $"../LoadingPanel"

@onready var server_address = Env.get_value("COMMON_SERVER_HOST")
@onready var server_port = int(Env.get_value("COMMON_SERVER_PORT"))
@onready var debug_username = Env.get_value("DEBUG_USERNAME")
@onready var debug_password = Env.get_value("DEBUG_PASSWORD")


func _ready():
	if debug_username:
		$VBoxContainer/UsernameText.text = debug_username

	if debug_password:
		$VBoxContainer/PasswordText.text = debug_password

	CommonConnection.connected_to_server.connect(_on_common_connected_succeeded)
	CommonConnection.server_disconnected.connect(_on_common_server_disconnected)
	CommonConnection.character_loaded.connect(_on_character_loaded)

	LevelsConnection.logged_in.connect(_on_level_server_logged_in)

	level.player_added.connect(_on_player_added)


func _input(event):
	if not visible:
		return

	if event.is_action_pressed("ui_accept"):
		_on_login_button_pressed()


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

	return true


func _on_common_connected_succeeded():
	hide()
	loading_panel.show()

	loading_panel.set_progress(10)

	# TODO: Show loading screen

	CommonConnection.load_character()


func _on_common_server_disconnected():
	$VBoxContainer/ErrorLabel.text = "Disconnected from server"
	show()
	loading_panel.hide()


func _on_character_loaded(level_name: String, address: String, port: int):
	print("Switching to level %s on address %s on port %d" % [level_name, address, port])

	loading_panel.set_progress(30)

	current_level = level_name

	# Set the level to be sure to be on time for server messages
	level.set_level(current_level)

	# Close the current connection
	LevelsConnection.disconnect_to_server()

	# Connect to the new level
	LevelsConnection.connect_to_server(address, port)


func _on_level_server_logged_in():
	# TODO: store and fetch local hash
	loading_panel.set_progress(60)
	var level_data = await CommonConnection.get_level_info(current_level, 0)
	level.load_level(level_data["info"])

	loading_panel.set_progress(80)

	# Load the player's equipment when logged in
	await LevelsConnection.get_equipment.rpc_id(1)

	loading_panel.set_progress(90)

	loading_panel.hide()

	if current_player == null:
		current_player = await level.player_added

	current_player.focus_camera()


func _on_player_added(player: Entity):
	current_player = player
