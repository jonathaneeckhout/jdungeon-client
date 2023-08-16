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
	if not "stats" in stats:
		return

	for stat in stats["stats"]:
		var str_val = str(stats["stats"][stat])

		match stat:
			"level":
				$VBoxContainer/LevelValue.text = str_val
			"experience":
				$VBoxContainer/ExpValue.text = str_val
			"experience_needed":
				$VBoxContainer/ExpValue.text = $VBoxContainer/ExpValue.text + "/" + str_val
			"hp":
				$VBoxContainer/HPValue.text = str_val
			"max_hp":
				player.max_hp = int(str_val)
				$VBoxContainer/HPValue.text = $VBoxContainer/HPValue.text + "/" + str_val
				player.update_hp_bar()
			"attack_power":
				$VBoxContainer/AttackPowerValue.text = str_val
			"attack_speed":
				$VBoxContainer/AttackSpeedValue.text = str_val
			"defense":
				$VBoxContainer/DefenseValue.text = str_val


func update_hp():
	$VBoxContainer/HPValue.text = str(player.hp) + "/" + str(player.max_hp)
