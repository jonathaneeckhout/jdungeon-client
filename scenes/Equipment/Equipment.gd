extends Panel

const SIZE = Vector2(2, 5)

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
			panels[x][y] = panel
			i += 1

	LevelsConnection.item_equipped.connect(_on_item_equipped)
	LevelsConnection.item_unequipped.connect(_on_item_unequipped)
	LevelsConnection.equipment_updated.connect(_on_equipment_updated)


func _input(event):
	if event.is_action_pressed("toggle_equipment"):
		if visible:
			hide()
		else:
			show()
			LevelsConnection.get_equipment.rpc_id(1)


func get_panel_at_slot(equipment_slot: String):
	var panel_path = "Panel_%s" % equipment_slot
	return $GridContainer.get_node(panel_path)


func equip_item(equipment_slot: String, item_uuid: String, item_class: String):
	var panel = get_panel_at_slot(equipment_slot)
	if panel:
		var item: Item = Global.item_class_to_item(item_class)
		panel.item = item
		panel.item_uuid = item_uuid


func unequip_item(equipment_slot: String):
	var panel = get_panel_at_slot(equipment_slot)
	if panel:
		panel.item = null
		panel.item_uuid = ""


func _on_mouse_entered():
	Global.above_ui = true


func _on_mouse_exited():
	Global.above_ui = false


func _on_item_equipped(equipment_slot: String, item_uuid: String, item_class: String):
	equip_item(equipment_slot, item_uuid, item_class)


func _on_item_unequipped(equipment_slot: String):
	unequip_item(equipment_slot)


func _on_equipment_updated(items: Dictionary):
	if not "equipment" in items:
		return

	for equipment_slot in items["equipment"]:
		var item = items["equipment"][equipment_slot]
		equip_item(equipment_slot, item["uuid"], item["class"])
