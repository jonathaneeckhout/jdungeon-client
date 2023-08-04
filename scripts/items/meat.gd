extends Item


func _init():
	item_class = "Meat"

	loot_texture_path = "res://assets/items/Meat/Meat.png"
	loot_scale = Vector2(0.025, 0.025)

	inventory_texture_path = loot_texture_path
