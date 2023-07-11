extends CharacterBody2D


const MAX_HP = 100.0
const SPEED=250
var hp = MAX_HP

@onready var target_position =  position

func _physics_process(_delta):
	velocity = position.direction_to(target_position) * SPEED
	if position.distance_to(target_position) > 10:
		move_and_slide()


func hurt(current_hp: int, _damage: int):
	hp = current_hp

	update_hp_bar()


func update_hp_bar():
	$Interface/HPBar.value = (hp / MAX_HP) * 100
