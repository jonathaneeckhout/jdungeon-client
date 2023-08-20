extends Panel

signal login_pressed(username: String, password: String)

var current_level = ""
var current_player = null

@onready var level = $"../../Level"
@onready var loading_panel = $"../LoadingPanel"


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

	login_pressed.emit(username, password)

	return true


func show_error(message: String):
	$VBoxContainer/ErrorLabel.text = message


func load_debug_username_and_password():
	if Global.env_debug_username:
		$VBoxContainer/UsernameText.text = Global.env_debug_username

	if Global.env_debug_password:
		$VBoxContainer/PasswordText.text = Global.env_debug_password
