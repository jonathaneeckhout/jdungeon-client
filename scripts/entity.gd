class_name Entity extends CharacterBody2D

var max_hp: float = 100.0
var hp: float = max_hp

var server_synchronizer: Node2D


func _ready():
	var server_synchronizer_scene = load("res://scenes/ServerSynchronizer/ServerSynchronizer.tscn")
	server_synchronizer = server_synchronizer_scene.instantiate()
	add_child(server_synchronizer)


func hurt(current_hp: int, _damage: int):
	hp = current_hp

	update_hp_bar()


func update_hp_bar():
	$Interface/HPBar.value = (hp / max_hp) * 100
