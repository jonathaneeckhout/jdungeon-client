extends Panel

@export var item: Item:
	set(new_item):
		item = new_item
		$TextureRect.texture = load(item.inventory_texture_path)
