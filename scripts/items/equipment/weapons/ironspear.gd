extends Item


func _init():
	item_class = "IronSpear"

	loot_texture_path = "res://assets/equipment/weapons/ironspear/ironspear.png"
	
	loot_scale = Vector2(0.025, 0.025)

	inventory_texture_path = loot_texture_path
