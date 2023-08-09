class_name Item extends Node

var item_class = ""

var loot_texture_path = ""
var loot_scale = Vector2(1.0, 1.0)

var inventory_texture_path = ""
var price = 0

var equipment_texture_paths = []


func use():
	print("Using item %s" % item_class)
