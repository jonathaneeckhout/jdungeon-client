extends Panel

const SIZE = Vector2(6, 6)

@export var gold := 0:
	set(amount):
		gold = amount
		$VBoxContainer/GoldValue.text = str(amount)

var panels = []
var mouse_above_this_panel: Panel
var location_cache = {}


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


func add_item(item_uuid: String, item_class: String):
	var item: Item = Global.item_class_to_item(item_class)
	if not item:
		return

	for y in range(SIZE.y):
		for x in range(SIZE.x):
			var pos = Vector2(x, y)
			var panel = get_panel_at_pos(pos)
			if panel.item == null:
				panel.item = item
				panel.item_uuid = item_uuid
				return


func remove_item(item_uuid: String):
	for x in range(SIZE.x):
		for y in range(SIZE.y):
			var panel = panels[x][y]
			if panel.item_uuid == item_uuid:
				panel.item = null
				panel.item_uuid = ""


func remove_item_at_pos(pos: Vector2):
	var panel = panels[pos.x][pos.y]
	panel.item = null
	panel.item_uuid = ""


func swap_items(from: Panel, to: Panel):
	var temp_item = to.item
	var temp_item_uuid = to.item_uuid

	to.item = from.item
	to.item_uuid = from.item_uuid

	from.item = temp_item
	from.item_uuid = temp_item_uuid

	if from.item:
		location_cache[from.item_uuid] = from.grid_pos
	if to.item:
		location_cache[to.item_uuid] = to.grid_pos


func update_cache():
	location_cache = {}
	for x in range(SIZE.x):
		for y in range(SIZE.y):
			var panel = panels[x][y]
			if panel.item:
				location_cache[panel.item_uuid] = panel.grid_pos


func _on_mouse_entered():
	Global.above_ui = true


func _on_mouse_exited():
	Global.above_ui = false


func _on_item_added_to_inventory(item_uuid: String, item_class: String):
	add_item(item_uuid, item_class)

	update_cache()


func _on_item_removed_from_inventory(item_uuid):
	remove_item(item_uuid)

	update_cache()


func _on_gold_updated(amount: int):
	gold = amount


func _on_inventory_updated(items: Dictionary):
	if not "items" in items:
		return

	# Clear the inventory
	for x in range(SIZE.x):
		for y in range(SIZE.y):
			remove_item_at_pos(Vector2(x, y))

	var to_be_added_items = []

	# If the items are in the location cache, set them to their previous position
	for item_data in items["items"]:
		if location_cache.has(item_data["uuid"]):
			var item: Item = Global.item_class_to_item(item_data["class"])
			if item:
				var panel = get_panel_at_pos(location_cache[item_data["uuid"]])
				panel.item = item
				panel.item_uuid = item_data["uuid"]
		else:
			to_be_added_items.append(item_data)

	# If the items are new, add them to the inventory
	for item_data in to_be_added_items:
		add_item(item_data["uuid"], item_data["class"])

	# Update the cache again
	update_cache()
