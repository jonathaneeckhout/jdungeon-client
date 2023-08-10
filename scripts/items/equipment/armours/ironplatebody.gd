extends Item


func _init():
	item_class = "IronPlateBody"

	loot_texture_path = "res://assets/equipment/armour/ironplateset/Torso.png"

	loot_scale = Vector2(0.1, 0.1)

	inventory_texture_path = loot_texture_path

	equipment_texture_paths = ["res://assets/equipment/armour/ironplateset/Torso.png"]
