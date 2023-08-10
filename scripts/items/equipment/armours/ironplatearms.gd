extends Item


func _init():
	item_class = "IronPlateArms"

	loot_texture_path = "res://assets/equipment/armour/ironplateset/LowerArmLeft.png"

	loot_scale = Vector2(0.1, 0.1)

	inventory_texture_path = loot_texture_path

	equipment_texture_paths = [
		"res://assets/equipment/armour/ironplateset/UpperArmLeft.png",
		"res://assets/equipment/armour/ironplateset/LowerArmLeft.png",
		"res://assets/equipment/armour/ironplateset/UpperArmRight.png",
		"res://assets/equipment/armour/ironplateset/LowerArmRight.png"
	]
