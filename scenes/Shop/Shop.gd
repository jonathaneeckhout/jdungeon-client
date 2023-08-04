extends Panel

const SIZE = Vector2(4, 4)

var panels = []
var vendor: String = ""

@export var gold := 0:
	set(amount):
		gold = amount
		$VBoxContainer/GoldValue.text = str(amount)


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
			panels[x][y] = panel
			i += 1
	$CloseButton.pressed.connect(_on_close_button_pressed)

	LevelsConnection.shop_updated.connect(_on_shop_updated)


func _input(event):
	if event.is_action_pressed("right_click") and not Global.above_ui:
		hide()


func get_panel_at_pos(pos: Vector2):
	var panel_path = "Panel_%d_%d" % [int(pos.x), int(pos.y)]
	return $GridContainer.get_node(panel_path)


func add_item(item_class: String, pos: Vector2, price: int):
	var item: Item
	match item_class:
		"HealthPotion":
			item = load("res://scripts/items/healthPotion.gd").new()
		"Gold":
			item = load("res://scripts/items/gold.gd").new()
	if item:
		var panel = get_panel_at_pos(pos)
		item.price = price
		panel.item = item


func remove_item(pos: Vector2):
	var panel = panels[pos.x][pos.y]
	panel.item = null


func display_info(pos: Vector2, label: String, price: int):
	$InfoPanel.position = pos
	$InfoPanel/Label.text = label
	$InfoPanel/Price.text = str(price)
	$InfoPanel.show()


func hide_info():
	$InfoPanel.hide()


func _on_mouse_entered():
	Global.above_ui = true


func _on_mouse_exited():
	Global.above_ui = false


func _on_shop_updated(vendor_name: String, items: Dictionary):
	vendor = vendor_name
	$Label.text = "%s's shop" % vendor

	for x in range(SIZE.x):
		for y in range(SIZE.y):
			remove_item(Vector2(x, y))

	for item_data in items["items"]:
		add_item(
			item_data["class"],
			Vector2(item_data["pos"]["x"], item_data["pos"]["y"]),
			item_data["price"]
		)

	show()


func _on_close_button_pressed():
	hide()
