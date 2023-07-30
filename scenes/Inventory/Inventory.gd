extends Panel


func _input(event):
	if event.is_action_pressed("toggle_bag"):
		if visible:
			hide()
		else:
			show()
