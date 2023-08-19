extends Panel

@onready var player = $"../../../.."


func _ready():
	LevelsConnection.stats_updated.connect(_on_stats_updated)


func _input(event):
	if not Global.typing_chat and event.is_action_pressed("toggle_stats"):
		if visible:
			hide()
		else:
			show()
			LevelsConnection.get_stats.rpc_id(1)


func _on_stats_updated(stats: Dictionary):
	var experience = 0
	var experience_needed = 0

	var hp = 0
	var max_hp = 0

	for stat in stats:
		var val = stats[stat]

		match stat:
			"level":
				$VBoxContainer/LevelValue.text = str(val)
				player.set_level(val, 0)
			"experience":
				experience = val
			"experience_needed":
				experience_needed = val
			"hp":
				hp = val
				player.hp = val
			"max_hp":
				max_hp = val
				player.max_hp = val
			"attack_power":
				$VBoxContainer/AttackPowerValue.text = str(val)
			"attack_speed":
				$VBoxContainer/AttackSpeedValue.text = str(val)
			"defense":
				$VBoxContainer/DefenseValue.text = str(val)

	$VBoxContainer/ExpValue.text = str(experience) + "/" + str(experience_needed)
	player.experience_needed_for_next_level = experience_needed
	player.set_experience(experience, 0)

	$VBoxContainer/HPValue.text = str(hp) + "/" + str(max_hp)
	player.update_hp_bar()


func update_hp():
	$VBoxContainer/HPValue.text = str(player.hp) + "/" + str(player.max_hp)
