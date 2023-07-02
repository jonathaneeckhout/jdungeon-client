extends Node2D

@onready var enemy = $"../"

@rpc("call_remote", "authority", "unreliable")
func sync(pos, vel):
	enemy.position = pos
	enemy.velocity = vel

@rpc("call_remote", "authority", "reliable")
func hurt(current_hp: int, amount: int):
	enemy.hurt(current_hp, amount)