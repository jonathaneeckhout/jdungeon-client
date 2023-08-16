extends Control

const GROUPS = {
	"Global": {"color": "WHITE"}, "Team": {"color": "LIGHT_BLUE"}, "Wisper": {"color": "VIOLET"}
}

var current_group = "Global"
var user_name = "player"

@onready var chat_log = $VBoxContainer/Logs/ChatLog
@onready var log_log = $VBoxContainer/Logs/LogLog

@onready var input_label = $VBoxContainer/HBoxContainer/Label
@onready var input_field = $VBoxContainer/HBoxContainer/LineEdit


func _ready():
	input_field.text_submitted.connect(_on_text_submitted)
	change_group("Global")
	CommonConnection.chat_message_received.connect(_on_message)

	$VBoxContainer/SelectButtons/ChatButton.pressed.connect(_on_chat_button_pressed)
	$VBoxContainer/SelectButtons/LogsButton.pressed.connect(_on_logs_button_pressed)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		input_field.grab_focus()
		Global.typing_chat = true
	if event.is_action_pressed("ui_cancel"):
		input_field.release_focus()
		Global.typing_chat = false


func change_group(value: String):
	current_group = value

	input_label.text = "[" + current_group + "]"
	input_label.set("theme_override_colors/font_color", Color(GROUPS[current_group]["color"]))


func escape_bbcode(bbcode_text):
	# We only need to replace opening brackets to prevent tags from being parsed.
	return bbcode_text.replace("[", "[lb]")


@rpc("call_local", "any_peer", "reliable", 1) func send_global_message(username, message):
	append_chat_line_escaped(username, message, GROUPS[current_group]["color"])


func append_chat_line_escaped(username, message, color = "WHITE"):
	chat_log.append_text(
		"[color=%s]%s: %s[/color]\n" % [color, escape_bbcode(username), escape_bbcode(message)]
	)


func _on_text_submitted(text):
	if text == "/h" or text == "/help":
		append_chat_line_escaped(
			"Helper",
			"Press /g for global chat, /t for team chat and /w <name> to wisper",
			"SKY_BLUE"
		)
		input_field.text = ""
		input_field.release_focus()
		Global.typing_chat = false
		return

	if text == "/g":
		change_group("Global")
		input_field.text = ""
		input_field.release_focus()
		Global.typing_chat = false
		return

	if text == "/t":
		change_group("Team")
		input_field.text = ""
		input_field.release_focus()
		Global.typing_chat = false
		return

	if text == "/w":
		change_group("Wisper")
		input_field.text = ""
		input_field.release_focus()
		Global.typing_chat = false
		return

	if text != "":
		match current_group:
			"Global":
				CommonConnection.send_message("Global", "", text)
			_:
				#TODO: implement other cases
				append_chat_line_escaped(user_name, text, GROUPS[current_group]["color"])

		# Here you have to send the message to the server
		input_field.text = ""
		input_field.release_focus()
		Global.typing_chat = false


func _on_message(type: String, from: String, message: String):
	match type:
		"Global":
			append_chat_line_escaped(from, message, GROUPS["Global"]["color"])
		"Team":
			append_chat_line_escaped(from, message, GROUPS["Team"]["color"])
		"Wisper":
			append_chat_line_escaped(from, message, GROUPS["Wisper"]["color"])


func append_log_line(message, color = "YELLOW"):
	log_log.append_text("[color=%s]%s[/color]\n" % [color, escape_bbcode(message)])


func _on_chat_button_pressed():
	chat_log.show()
	log_log.hide()


func _on_logs_button_pressed():
	chat_log.hide()
	log_log.show()
