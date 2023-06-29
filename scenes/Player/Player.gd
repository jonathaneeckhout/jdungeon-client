extends CharacterBody2D

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username

# Set by the authority, synchronized on spawn.
@export var player := 1:
	set(id):
		player = id

@export var vel: Vector2


func _process(_delta):
	velocity = vel
	move_and_slide()
