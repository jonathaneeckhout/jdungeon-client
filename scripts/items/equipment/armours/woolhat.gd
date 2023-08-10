extends Item


func _init():
	item_class = "WoolHat"

	loot_texture_path = "res://assets/equipment/armour/woolset/Head.png"

	loot_scale = Vector2(0.075, 0.075)

	inventory_texture_path = loot_texture_path

	equipment_texture_paths = ["res://assets/equipment/armour/woolset/Head.png"]
