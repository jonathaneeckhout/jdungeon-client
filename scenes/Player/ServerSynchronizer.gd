extends Node2D

@onready var player = $"../"

@rpc("call_remote", "authority", "unreliable") func sync(pos, vel):
	player.position = pos
	player.velocity = vel


@rpc("call_remote", "authority", "reliable") func hurt(current_hp: int, amount: int):
	player.hurt(current_hp, amount)
