extends CharacterBody2D

const MAX_HP = 100.0
const SPEED = 300.0

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id

var hp = MAX_HP

@onready var target_position = position


func _ready():
	if player == multiplayer.get_unique_id():
		$Camera2D.make_current()
		$Camera2D/UILayer/GUI/ChatPanel.user_name = username
		$Camera2D/UILayer.show()
	else:
		$Camera2D.queue_free()


func hurt(current_hp: int, _damage: int):
	hp = current_hp

	update_hp_bar()


func update_hp_bar():
	$Interface/HPBar.value = (hp / MAX_HP) * 100
