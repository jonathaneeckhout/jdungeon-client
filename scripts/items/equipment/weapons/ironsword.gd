extends Item


func _init():
	item_class = "IronSword"

	loot_texture_path = "res://assets/equipment/weapons/ironsword/ironsword.png"

	loot_scale = Vector2(0.075, 0.075)

	inventory_texture_path = loot_texture_path

	equipment_texture_paths = ["res://assets/equipment/weapons/ironsword/ironsword.png"]
