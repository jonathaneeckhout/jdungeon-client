extends Entity

const BASE_EXPERIENCE = 100

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username + " (%d)" % current_level

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id

var current_level: int = 1
var current_experience: int = 0
var experience_needed_for_next_level = BASE_EXPERIENCE

@onready var inventory = $Camera2D/UILayer/GUI/Inventory
@onready var chat_panel = $Camera2D/UILayer/GUI/ChatPanel


func _ready():
	super()

	if player == multiplayer.get_unique_id():
		# $Camera2D.make_current()
		$Camera2D/UILayer/GUI/ChatPanel.user_name = username
		$Camera2D/UILayer.show()
		set_level(current_level, 0)
		set_experience(current_experience, 0)

	else:
		$Camera2D.queue_free()


func focus_camera():
	$Camera2D.make_current()


func check_if_hurt():
	if player == multiplayer.get_unique_id():
		for i in range(hurt_buffer.size() - 1, -1, -1):
			if hurt_buffer[i]["timestamp"] <= LevelsConnection.clock:
				chat_panel.append_log_line("You received %d damage" % hurt_buffer[i]["damage"])

	super()


func check_if_heal():
	if player == multiplayer.get_unique_id():
		for i in range(heal_buffer.size() - 1, -1, -1):
			if heal_buffer[i]["timestamp"] <= LevelsConnection.clock:
				chat_panel.append_log_line("You received %d healing" % heal_buffer[i]["healing"])

	super()


func update_hp_bar():
	super()

	if player == multiplayer.get_unique_id():
		$Camera2D/UILayer/GUI/Stats.update_hp()


func set_experience(current_exp: int, _amount: int):
	var progress = float(current_exp) / experience_needed_for_next_level * 100
	if progress >= 100:
		progress = 0
	$Camera2D/UILayer/GUI/ExpBar.value = progress


func gain_experience(_timestamp: int, current_exp: int, amount: int):
	set_experience(current_exp, amount)

	chat_panel.append_log_line("You gained %d experience" % amount)


func set_level(new_level: int, _amount: int):
	current_level = new_level
	$Interface/Username.text = username + " (%d)" % current_level


func gain_level(_timestamp: int, new_level: int, amount: int, exp_needed_for_next_level: int):
	experience_needed_for_next_level = exp_needed_for_next_level

	set_level(new_level, amount)

	chat_panel.append_log_line("You gained %d level(s)" % amount)


func calculate_experience_needed_next_level(clvl: int):
	return BASE_EXPERIENCE + (BASE_EXPERIENCE * (pow(clvl, 2) - 1))
