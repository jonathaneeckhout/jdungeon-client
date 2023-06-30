extends Node2D


func _ready():
	# Only process for the local player.
	set_process($"../".player == multiplayer.get_unique_id())
	set_process_input($"../".player == multiplayer.get_unique_id())


func _input(event):
	if event.is_action_pressed("left_click"):
		$"../MouseArea2D".set_global_position($"..".get_global_mouse_position())
		await get_tree().physics_frame
		await get_tree().physics_frame
		print($"../MouseArea2D".get_overlapping_bodies())
	elif event.is_action_pressed("right_click"):
		_handle_right_click()


func _handle_right_click():
	$"../MouseArea2D".set_global_position($"..".get_global_mouse_position())

	#The following awaits ensure that the collision cycle has occurred before calling
	#the get_overlapping_bodies function
	await get_tree().physics_frame
	await get_tree().physics_frame

	#Get the bodies under the mouse area
	var bodies = $"../MouseArea2D".get_overlapping_bodies()

	#Move if nothing is under the mouse area
	if bodies.is_empty():
		LevelsConnection.move.rpc($"..".get_global_mouse_position())
	else:
		#TODO: not sure if this needs to be improved, just take the first
		var target = bodies[0]
		if target != $"../":
			LevelsConnection.interact.rpc(target.name)
