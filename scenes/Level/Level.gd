extends Node2D

@onready var player_scene = load("res://scenes/Player/Player.tscn")

var level: String = ""
var players: Node2D
var npcs: Node2D
var enemies: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelsConnection.player_added.connect(_on_player_added)
	LevelsConnection.player_removed.connect(_on_player_removed)


func set_level(level_name: String):
	var scene

	match level_name:
		"Grassland":
			scene = load("res://scenes/Levels/Grassland/Grassland.tscn")
		"_":
			print("Level %s does not exist" % level_name)
			return false

	var level_instance = scene.instantiate()
	self.add_child(level_instance)

	level = level_name
	players = level_instance.get_node("Players")
	npcs = level_instance.get_node("NPCS")
	enemies = level_instance.get_node("Enemies")

	return true


func add_player(character_name: String, pos: Vector2):
	var player = player_scene.instantiate()
	player.player = multiplayer.get_unique_id()
	player.position = pos
	player.username = character_name
	player.name = character_name
	players.add_child(player)


func remove_player(character_name: String):
	if players.has_node(character_name):
		players.get_node(character_name).queue_free()


func _on_player_added(character_name: String, pos: Vector2):
	add_player(character_name, pos)


func _on_player_removed(character_name: String):
	remove_player(character_name)