extends Node2D

var item_class: String = ""
var item: Item

@onready var sprite = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	item = Global.item_class_to_item(item_class)

	if item:
		sprite.texture = load(item.loot_texture_path)
		sprite.scale = item.loot_scale
