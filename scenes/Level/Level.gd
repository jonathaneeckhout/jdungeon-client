extends Node2D

@onready var player_scene = load("res://scenes/Player/Player.tscn")
@onready var wolf_scene = load("res://scenes/Enemies/Wolf/Wolf.tscn")

var level: String = ""
var players: Node2D
var npcs: Node2D
var enemies: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelsConnection.player_added.connect(_on_player_added)
	LevelsConnection.player_removed.connect(_on_player_removed)
	LevelsConnection.enemy_added.connect(_on_enemy_added)
	LevelsConnection.enemy_removed.connect(_on_enemy_removed)


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


func add_player(id: int, character_name: String, pos: Vector2):
	var player = player_scene.instantiate()
	player.player = id
	player.position = pos
	player.username = character_name
	player.name = character_name
	players.add_child(player)


func remove_player(character_name: String):
	if players.has_node(character_name):
		players.get_node(character_name).queue_free()


func add_enemy(enemy_name: String, pos: Vector2):
	var enemy = wolf_scene.instantiate()
	enemy.position = pos
	enemy.name = enemy_name
	enemies.add_child(enemy)


func remove_enemy(enemy_name: String):
	if enemies.has_node(enemy_name):
		enemies.get_node(enemy_name).queue_free()


func _on_player_added(id: int, character_name: String, pos: Vector2):
	add_player(id, character_name, pos)


func _on_player_removed(character_name: String):
	remove_player(character_name)

func _on_enemy_added(enemy_name: String, pos: Vector2):
	add_enemy(enemy_name, pos)


func _on_enemy_removed(enemy_name: String):
	remove_enemy(enemy_name)
