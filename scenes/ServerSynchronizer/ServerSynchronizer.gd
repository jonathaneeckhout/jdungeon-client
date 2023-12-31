extends Node2D

const INTERPOLATION_OFFSET = 0.1
const INTERPOLATION_INDEX = 2

var last_sync_timestamp = 0.0
var server_syncs_buffer = []

@onready var root = $"../"


func _physics_process(_delta):
	var render_time = LevelsConnection.clock - INTERPOLATION_OFFSET

	while (
		server_syncs_buffer.size() > 2
		and render_time > server_syncs_buffer[INTERPOLATION_INDEX]["timestamp"]
	):
		server_syncs_buffer.remove_at(0)

	if server_syncs_buffer.size() > INTERPOLATION_INDEX:
		root.position = interpolate(render_time)
	elif (
		server_syncs_buffer.size() > INTERPOLATION_INDEX - 1
		and render_time > server_syncs_buffer[INTERPOLATION_INDEX - 1]["timestamp"]
	):
		root.position = extrapolate(render_time)


func interpolate(render_time):
	var interpolation_factor = (
		float(render_time - server_syncs_buffer[INTERPOLATION_INDEX - 1]["timestamp"])
		/ float(
			(
				server_syncs_buffer[INTERPOLATION_INDEX]["timestamp"]
				- server_syncs_buffer[INTERPOLATION_INDEX - 1]["timestamp"]
			)
		)
	)

	return server_syncs_buffer[INTERPOLATION_INDEX - 1]["position"].lerp(
		server_syncs_buffer[INTERPOLATION_INDEX]["position"], interpolation_factor
	)


func extrapolate(render_time):
	var extrapolation_factor = (
		float(render_time - server_syncs_buffer[INTERPOLATION_INDEX - 2]["timestamp"])
		/ float(
			(
				server_syncs_buffer[INTERPOLATION_INDEX - 1]["timestamp"]
				- server_syncs_buffer[INTERPOLATION_INDEX - 2]["timestamp"]
			)
		)
	)

	return server_syncs_buffer[INTERPOLATION_INDEX - 2]["position"].lerp(
		server_syncs_buffer[INTERPOLATION_INDEX - 1]["position"], extrapolation_factor
	)


@rpc("call_remote", "authority", "unreliable") func sync(timestamp: float, pos: Vector2):
	# Ignore older syncs
	if timestamp < last_sync_timestamp:
		return

	last_sync_timestamp = timestamp
	server_syncs_buffer.append({"timestamp": timestamp, "position": pos})


@rpc("call_remote", "authority", "reliable")
func hurt(timestamp: float, current_hp: int, amount: int):
	root.hurt(timestamp, current_hp, amount)


@rpc("call_remote", "authority", "reliable")
func heal(timestamp: float, current_hp: int, amount: int):
	root.heal(timestamp, current_hp, amount)


@rpc("call_remote", "authority", "reliable") func attack(timestamp: float, direction: Vector2):
	root.attack(timestamp, direction)


@rpc("call_remote", "authority", "reliable")
func gain_experience(timestamp: int, current_exp: int, amount: int):
	root.gain_experience(timestamp, current_exp, amount)


@rpc("call_remote", "authority", "reliable")
func gain_level(timestamp: int, current_level: int, amount: int, exp_needed_for_next_level: int):
	root.gain_level(timestamp, current_level, amount, exp_needed_for_next_level)
