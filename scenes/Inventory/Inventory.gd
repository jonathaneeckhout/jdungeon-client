extends Panel


func _input(event):
	if event.is_action_pressed("toggle_bag"):
		if visible:
			hide()
		else:
			show()


func get_panel_at_pos(pos: Vector2):
	var panel_path = "Panel_%d_%d" % [int(pos.x), int(pos.y)]
	return $GridContainer.get_node(panel_path)


func add_item(item_class: String, pos: Vector2):
	var item: Item
	match item_class:
		"HealthPotion":
			item = load("res://scripts/items/healthPotion.gd").new()

	if item:
		var panel = get_panel_at_pos(pos)
		panel.item = item
