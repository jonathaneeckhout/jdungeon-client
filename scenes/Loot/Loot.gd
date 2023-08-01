extends Node2D

var item_class: String = ""
var item: Item

@onready var sprite = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	match item_class:
		"HealthPotion":
			item = load("res://scripts/items/healthPotion.gd").new()
		"Gold":
			item = load("res://scripts/items/gold.gd").new()

	if item:
		sprite.texture = load(item.loot_texture_path)
		sprite.scale = item.loot_scale
