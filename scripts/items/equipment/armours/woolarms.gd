extends Item


func _init():
	item_class = "WoolArms"

	loot_texture_path = "res://assets/equipment/armour/woolset/LowerArmLeft.png"

	loot_scale = Vector2(0.1, 0.1)

	inventory_texture_path = loot_texture_path

	equipment_texture_paths = [
		"res://assets/equipment/armour/woolset/UpperArmLeft.png",
		"res://assets/equipment/armour/woolset/LowerArmLeft.png",
		"res://assets/equipment/armour/woolset/UpperArmRight.png",
		"res://assets/equipment/armour/woolset/LowerArmRight.png"
	]
