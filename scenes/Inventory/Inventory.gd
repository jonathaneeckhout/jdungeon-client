extends Panel

const SIZE = Vector2(6, 6)

var panels = []

@export var gold := 0:
	set(amount):
		gold = amount
		$VBoxContainer/GoldValue.text = str(amount)


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	for x in range(SIZE.x):
		var column = []
		for y in range(SIZE.y):
			column.append(null)
		panels.append(column)

	var i = 0
	for y in range(SIZE.y):
		for x in range(SIZE.x):
			var panel = $GridContainer.get_child(i)
			panel.grid_pos = Vector2(x, y)
			panels[x][y] = panel
			i += 1

	LevelsConnection.item_added_to_inventory.connect(_on_item_added_to_inventory)
	LevelsConnection.item_removed_from_inventory.connect(_on_item_removed_from_inventory)
	LevelsConnection.gold_updated.connect(_on_gold_updated)


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
		"Gold":
			item = load("res://scripts/items/gold.gd").new()
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
