extends CharacterBody2D

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username

@export var vel: Vector2


func _process(_delta):
	velocity = vel
	move_and_slide()
