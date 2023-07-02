extends Node2D

@onready var player = $"../"

@rpc("call_remote", "authority", "unreliable")
func sync(pos, vel):
	player.position = pos
	player.velocity = vel