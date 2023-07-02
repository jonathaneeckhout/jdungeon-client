extends Node2D

@onready var enemy = $"../"

@rpc("call_remote", "authority", "unreliable")
func sync(pos, vel):
	enemy.position = pos
	enemy.velocity = vel