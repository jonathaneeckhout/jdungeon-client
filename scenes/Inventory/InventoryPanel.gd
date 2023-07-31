extends Panel

@export var item: Item:
	set(new_item):
		item = new_item
		if item:
			$TextureRect.texture = load(item.inventory_texture_path)
		else:
			$TextureRect.texture = null

var grid_pos: Vector2


func _gui_input(event: InputEvent):
	if event.is_action_pressed("right_click"):
		LevelsConnection.use_inventory_item_at_pos.rpc_id(1, grid_pos)
