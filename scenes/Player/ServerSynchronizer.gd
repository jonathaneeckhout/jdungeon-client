extends Node2D

const INTERPOLATION_OFFSET = 100

var last_sync_timestamp = 0.0
var server_syncs_buffer = []

@onready var player = $"../"


func _process(_delta):
	var render_time = Time.get_unix_time_from_system()

	if server_syncs_buffer.size() > 1:
		while server_syncs_buffer.size() > 2 and render_time > server_syncs_buffer[1]["timestamp"]:
			server_syncs_buffer.remove_at(0)

		var interpolation_factor = (
			float(render_time - server_syncs_buffer[0]["timestamp"])
			/ float(server_syncs_buffer[1]["timestamp"] - server_syncs_buffer[0]["timestamp"])
		)

		var new_position = server_syncs_buffer[0]["position"].lerp(
			server_syncs_buffer[0]["position"], interpolation_factor
		)

		player.target_position = new_position


@rpc("call_remote", "authority", "unreliable") func sync(timestamp: float, pos: Vector2):
	# Ignore older syncs
	if timestamp < last_sync_timestamp:
		return

	last_sync_timestamp = timestamp
	server_syncs_buffer.append({"timestamp": timestamp, "position": pos})


@rpc("call_remote", "authority", "reliable") func hurt(current_hp: int, amount: int):
	player.hurt(current_hp, amount)
