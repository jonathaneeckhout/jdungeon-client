extends Entity

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username + " (%d)" % current_level

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id

var current_level: int = 1


func _ready():
	super()

	if player == multiplayer.get_unique_id():
		# $Camera2D.make_current()
		$Camera2D/UILayer/GUI/ChatPanel.user_name = username
		$Camera2D/UILayer.show()
	else:
		$Camera2D.queue_free()


func focus_camera():
	$Camera2D.make_current()


func gain_experience(_timestamp: int, current_exp: int, _amount: int, needed: int):
	var progress = float(current_exp) / needed * 100
	if progress >= 100:
		progress = 0
	$Camera2D/UILayer/GUI/ExpBar.value = progress


func gain_level(_timestamp: int, new_level: int, _amount: int):
	current_level = new_level
	$Interface/Username.text = username + " (%d)" % current_level
