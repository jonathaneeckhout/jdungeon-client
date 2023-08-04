extends Item


func _init():
	item_class = "Apple"

	loot_texture_path = "res://assets/items/Apple/Apple.png"
	loot_scale = Vector2(0.05, 0.05)

	inventory_texture_path = loot_texture_path
