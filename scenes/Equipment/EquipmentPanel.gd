extends VBoxContainer

@export var item: Item:
	set(new_item):
		item = new_item
		if item:
			$Panel/TextureRect.texture = load(item.inventory_texture_path)
		else:
			$Panel/TextureRect.texture = null

@export var slot: String:
	set(slot_name):
		slot = slot_name
		$Label.text = slot_name

var item_uuid: String

var grid_pos: Vector2


func _gui_input(event: InputEvent):
	if event.is_action_pressed("right_click"):
		if item_uuid and item_uuid != "":
			LevelsConnection.remove_equipment_item.rpc_id(1, item_uuid)
