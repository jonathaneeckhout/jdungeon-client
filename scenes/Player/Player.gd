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


func _ready():
	super()

	if player == multiplayer.get_unique_id():
		# $Camera2D.make_current()
		$Camera2D/UILayer/GUI/ChatPanel.user_name = username
		$Camera2D/UILayer.show()
		gain_level(0, current_level, 0)
		gain_experience(0, current_experience, 0)
		LevelsConnection.item_added_to_inventory.connect(_on_item_added_to_inventory)
		LevelsConnection.item_removed_from_inventory.connect(_on_item_removed_from_inventory)

	else:
		$Camera2D.queue_free()


func focus_camera():
	$Camera2D.make_current()


func gain_experience(_timestamp: int, current_exp: int, _amount: int):
	var progress = float(current_exp) / experience_needed_for_next_level * 100
	if progress >= 100:
		progress = 0
	$Camera2D/UILayer/GUI/ExpBar.value = progress


func gain_level(_timestamp: int, new_level: int, _amount: int):
	current_level = new_level
	experience_needed_for_next_level = calculate_experience_needed_next_level(current_level)
	$Interface/Username.text = username + " (%d)" % current_level


func calculate_experience_needed_next_level(clvl: int):
	return BASE_EXPERIENCE + (BASE_EXPERIENCE * (pow(clvl, 2) - 1))


func _on_item_added_to_inventory(item_class: String, pos: Vector2):
	$Camera2D/UILayer/GUI/Inventory.add_item(item_class, pos)


func _on_item_removed_from_inventory(pos: Vector2):
	$Camera2D/UILayer/GUI/Inventory.remove_item(pos)
