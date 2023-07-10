extends CharacterBody2D

const MAX_HP = 100.0

var hp = MAX_HP


func _physics_process(_delta):
	move_and_slide()


func hurt(current_hp: int, _damage: int):
	hp = current_hp

	update_hp_bar()


func update_hp_bar():
	$Interface/HPBar.value = (hp / MAX_HP) * 100
