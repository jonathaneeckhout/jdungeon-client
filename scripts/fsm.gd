extends Node

enum STATES { INIT, LOGIN_SCREEN, AUTHENTICATE, CONNECT, DISCONNECTED, RUNNING }

var state: STATES = STATES.INIT

var fsm_timer: Timer

var login_pressed: bool = false
var user: String
var passwd: String

var current_player = null

@onready var level: Node2D = $"/root/Multiplayer/Level"
@onready var login_panel: Panel = $"/root/Multiplayer/UI/LoginPanel"
@onready var loading_panel: Panel = $"/root/Multiplayer/UI/LoadingPanel"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Add a short timer to deffer the fsm() calls
	fsm_timer = Timer.new()
	fsm_timer.wait_time = 0.1
	fsm_timer.autostart = false
	fsm_timer.one_shot = true
	fsm_timer.timeout.connect(_on_fsm_timer_timeout)
	add_child(fsm_timer)

	login_panel.login_pressed.connect(_on_login_pressed)

	level.player_added.connect(_on_player_added)

	fsm_timer.start()



func fsm():
	match state:
		STATES.INIT:
			_handle_init()
		STATES.LOGIN_SCREEN:
			_handle_login_screen()
		STATES.AUTHENTICATE:
			_handle_authenticate()
		STATES.CONNECT:
			_handle_connect()
		STATES.DISCONNECTED:
			pass
		STATES.RUNNING:
			pass


func _handle_init():
	if not Global.load_env_variables():
		print("FSM: Failed to load environment variables, quitting server")
		get_tree().quit()
		return

	if Global.env_debug:
		login_panel.load_debug_username_and_password()

	state = STATES.LOGIN_SCREEN
	fsm_timer.start()


func _handle_login_screen():
	login_panel.show()
	loading_panel.hide()

	if login_pressed:
		login_pressed = false
		state = STATES.AUTHENTICATE

		fsm_timer.start()


func _handle_authenticate():
	if !await CommonConnection.authenticate(user, passwd):
		login_panel.show_error("Login failed")
		print("FSM: Failed logging in to server")
		state = STATES.INIT
		fsm_timer.start()
		return

	print("FSM: Successfully logged into common server")
	state = STATES.CONNECT
	fsm_timer.start()


func _handle_connect():
	if !CommonConnection.connect_to_server(
		Global.env_common_server_host, Global.env_common_server_port
	):
		login_panel.show_error("Error conneting server")
		print("FSM: Failed to connect to server")
		state = STATES.INIT
		fsm_timer.start()
		return

	print("FSM: Successfully connected to websocket of common server")

	login_panel.hide()
	loading_panel.show()

	loading_panel.set_progress(10)

	var characters = await CommonConnection.get_characters()
	if characters == null:
		print("FSM: Failed to get characters")
		CommonConnection.disconnect_from_server()
		state = STATES.INIT
		fsm_timer.start()
		return

	loading_panel.set_progress(20)

	if characters.size() == 0:
		# TODO: create character creation menu, for now create a characer witht the name of the player
		if !await CommonConnection.create_character(user):
			print("FSM: Failed to create character")
			CommonConnection.disconnect_from_server()
			state = STATES.INIT
			fsm_timer.start()
			return
		else:
			characters = await CommonConnection.get_characters()
			if characters == null:
				print("FSM: Failed to get characters")
				CommonConnection.disconnect_from_server()
				state = STATES.INIT
				fsm_timer.start()
				return

	var level_name = characters[0]["level"]

	# TODO: fetch a selected character, for now take the first one
	var level_info = await CommonConnection.get_level(level_name)

	# Set the level to be sure to be on time for server messages
	level.set_level(level_name)

	loading_panel.set_progress(30)

	LevelsConnection.disconnect_to_server()

	if not LevelsConnection.connect_to_server(level_info["address"], level_info["port"]):
		print(
			"FSM: Failed to start connecting to level server, disconnecting from common server connection"
		)
		login_panel.show_error("Error conneting to level")
		CommonConnection.disconnect_from_server()
		state = STATES.INIT
		fsm_timer.start()
		return

	if not await LevelsConnection.connected:
		print("FSM: Failed to connect to level server, disconnecting from common server connection")
		CommonConnection.disconnect_from_server()
		login_panel.show_error("Error conneting to level")
		state = STATES.INIT
		fsm_timer.start()
		return

	LevelsConnection.authenticate_with_secret.rpc_id(
		1, CommonConnection.username, CommonConnection.secret, CommonConnection.username
	)

	if not await LevelsConnection.logged_in:
		print("FSM: Failed to login to level server, disconnecting from common server connection")
		login_panel.show_error("Error conneting to level")
		CommonConnection.disconnect_from_server()
		state = STATES.INIT
		fsm_timer.start()
		return

	# TODO: store and fetch local hash
	loading_panel.set_progress(60)

	var level_data = await CommonConnection.get_level_info(level_name, 0)
	level.load_level(level_data["info"])

	loading_panel.set_progress(80)

	loading_panel.hide()

	if current_player == null:
		current_player = await level.player_added

	loading_panel.set_progress(90)

	# Load the player's stats
	LevelsConnection.get_stats.rpc_id(1)

	loading_panel.set_progress(95)

	# Load the player's equipment
	LevelsConnection.get_equipment.rpc_id(1)

	current_player.focus_camera()


func _on_fsm_timer_timeout():
	fsm()


func _on_login_pressed(username: String, password: String):
	login_pressed = true
	user = username
	passwd = password

	fsm()


func _on_player_added(player: Entity):
	current_player = player
