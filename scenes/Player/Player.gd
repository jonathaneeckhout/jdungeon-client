extends CharacterBody2D

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id


func _process(_delta):
	move_and_slide()
