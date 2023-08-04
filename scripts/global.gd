extends Node

var above_ui = false


func item_class_to_item(item_class: String):
	var item: Item
	match item_class:
		"HealthPotion":
			item = load("res://scripts/items/healthPotion.gd").new()
		"Gold":
			item = load("res://scripts/items/gold.gd").new()
		"ManaPotion":
			item = load("res://scripts/items/manaPotion.gd").new()
		"Apple":
			item = load("res://scripts/items/apple.gd").new()
		"Meat":
			item = load("res://scripts/items/meat.gd").new()

	return item
