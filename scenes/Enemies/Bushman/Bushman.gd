extends "res://scripts/entity.gd"


func _init():
	max_hp = 10


func _ready():
	super()
	$"Sprites/FrontLeg".hide()
	$"Sprites/BackLeg".hide()
	$Sprites/AnimationPlayer.animation_started.connect(_on_animation_started)


func _on_animation_started(animation_name: String):
	if animation_name == "idle":
		$"Sprites/FrontLeg".hide()
		$"Sprites/BackLeg".hide()
	else:
		$"Sprites/FrontLeg".show()
		$"Sprites/BackLeg".show()
