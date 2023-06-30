extends CharacterBody2D

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id


func _ready():
	if player == multiplayer.get_unique_id():
		$Camera2D.make_current()
		$Interface/ChatPanel.user_name = username
		$Interface/ChatPanel.show()
	else:
		$Interface/ChatPanel.queue_free()
		$Camera2D.queue_free()


func _process(_delta):
	move_and_slide()
