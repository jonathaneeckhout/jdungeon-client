extends CharacterBody2D

@export var username := "":
	set(user):
		username = user
		$Interface/Username.text = username


func _process(_delta):
	move_and_slide()
