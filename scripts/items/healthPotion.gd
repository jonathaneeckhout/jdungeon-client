extends Item


func _init():
	item_class = "HealthPotion"

	loot_texture_path = "res://assets/items/HealthPotion/HealthPotion.png"
	loot_scale = Vector2(0.05, 0.05)

	inventory_texture_path = loot_texture_path
