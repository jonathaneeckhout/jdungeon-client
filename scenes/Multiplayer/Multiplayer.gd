extends Node2D


@onready var level = $Level

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: let server set the current level
	level.set_level("Grassland")
