extends Panel

const SIZE = Vector2(6, 6)

@export var gold := 0:
	set(amount):
		gold = amount
		$VBoxContainer/GoldValue.text = str(amount)

var panels = []
var mouse_above_this_panel: Panel


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	for x in range(SIZE.x):
		panels.append([])
		for y in range(SIZE.y):
			panels[x].append(null)

	var i = 0
	for y in range(SIZE.y):
		for x in range(SIZE.x):
			var panel = $GridContainer.get_child(i)
			panel.grid_pos = Vector2(x, y)
			panel.drag_panel_offset = (panel.grid_pos * $DragPanel.size) - $DragPanel.size / 2
			panels[x][y] = panel
			i += 1

	LevelsConnection.item_added_to_inventory.connect(_on_item_added_to_inventory)
	LevelsConnection.item_removed_from_inventory.connect(_on_item_removed_from_inventory)
	LevelsConnection.gold_updated.connect(_on_gold_updated)
	LevelsConnection.inventory_updated.connect(_on_inventory_updated)


func _input(event):
	if event.is_action_pressed("toggle_bag"):
		if visible:
			hide()
		else:
			LevelsConnection.get_inventory.rpc_id(1)
			show()


func get_panel_at_pos(pos: Vector2):
	var panel_path = "Panel_%d_%d" % [int(pos.x), int(pos.y)]
	return $GridContainer.get_node(panel_path)


func add_item(item_class: String, pos: Vector2):
	var item: Item = Global.item_class_to_item(item_class)
	if item:
		var panel = get_panel_at_pos(pos)
		panel.item = item


func remove_item(pos: Vector2):
	var panel = panels[pos.x][pos.y]
	panel.item = null


func _on_mouse_entered():
	Global.above_ui = true


func _on_mouse_exited():
	Global.above_ui = false


func _on_item_added_to_inventory(item_class: String, pos: Vector2):
	add_item(item_class, pos)


func _on_item_removed_from_inventory(pos: Vector2):
	remove_item(pos)


func _on_gold_updated(amount: int):
	gold = amount


func _on_inventory_updated(items: Dictionary):
	for x in range(SIZE.x):
		for y in range(SIZE.y):
			remove_item(Vector2(x, y))

	for item_data in items["items"]:
		add_item(item_data["class"], Vector2(item_data["pos"]["x"], item_data["pos"]["y"]))
