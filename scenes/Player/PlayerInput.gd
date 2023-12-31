extends Node2D

var input_sequence = 0

@onready var player = $"../"
@onready var mouse_area = $"../MouseArea2D"


func _ready():
	# Only process for the local player.
	set_process(player.player == multiplayer.get_unique_id())
	set_process_input(player.player == multiplayer.get_unique_id())


func _input(event):
	# Don't do anything when above ui
	if Global.above_ui:
		return

	if event.is_action_pressed("left_click"):
		mouse_area.set_global_position(player.get_global_mouse_position())
		await get_tree().physics_frame
		await get_tree().physics_frame
		print(mouse_area.get_overlapping_bodies())
	elif event.is_action_pressed("right_click"):
		_handle_right_click()


func _handle_right_click():
	mouse_area.set_global_position(player.get_global_mouse_position())

	#The following awaits ensure that the collision cycle has occurred before calling
	#the get_overlapping_bodies function
	await get_tree().physics_frame
	await get_tree().physics_frame

	#Get the bodies under the mouse area
	var bodies = mouse_area.get_overlapping_bodies()

	#Move if nothing is under the mouse area
	if bodies.is_empty():
		var target_position = player.get_global_mouse_position()
		input_sequence += 1
		LevelsConnection.move.rpc(input_sequence, target_position)
	else:
		#TODO: not sure if this needs to be improved, just take the first
		var target = bodies[0]
		if target != player:
			input_sequence += 1
			LevelsConnection.interact.rpc(input_sequence, target.name)
