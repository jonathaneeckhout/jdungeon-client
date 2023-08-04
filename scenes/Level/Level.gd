extends Node2D

signal player_added(player: Entity)

var level: String = ""
var players: Node2D
var npcs: Node2D
var enemies: Node2D
var items: Node2D
var terrain: Node2D
var tilemap: TileMap

@onready var player_scene = load("res://scenes/Player/Player.tscn")
@onready var wolf_scene = load("res://scenes/Enemies/Wolf/Wolf.tscn")
@onready var sheep_scene = load("res://scenes/Enemies/Sheep/Sheep.tscn")
@onready var ram_scene = load("res://scenes/Enemies/Ram/Ram.tscn")
@onready var bushman_scene = load("res://scenes/Enemies/Bushman/Bushman.tscn")

@onready var milklady_scene = load("res://scenes/NPCs/MilkLady/MilkLady.tscn")

@onready var loot_scene = load("res://scenes/Loot/Loot.tscn")

@onready var tree_scene = load("res://scenes/Terrain/Tree/Tree.tscn")
@onready var tree_2_scene = load("res://scenes/Terrain/Tree_2/Tree_2.tscn")
@onready var tree_3_scene = load("res://scenes/Terrain/Tree_3/Tree_3.tscn")
@onready var caravan_scene = load("res://scenes/Terrain/Caravan/Caravan.tscn")
@onready var sign_scene = load("res://scenes/Terrain/Sign/CaravanSign.tscn")
@onready var grass_scene = load("res://scenes/Terrain/Grass/Grass.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	LevelsConnection.player_added.connect(_on_player_added)
	LevelsConnection.player_removed.connect(_on_player_removed)

	LevelsConnection.other_player_added.connect(_on_other_player_added)
	LevelsConnection.other_player_removed.connect(_on_other_player_removed)

	LevelsConnection.enemy_added.connect(_on_enemy_added)
	LevelsConnection.enemy_removed.connect(_on_enemy_removed)

	LevelsConnection.npc_added.connect(_on_npc_added)
	LevelsConnection.npc_removed.connect(_on_npc_removed)

	LevelsConnection.item_added.connect(_on_item_added)
	LevelsConnection.item_removed.connect(_on_item_removed)


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
	players = level_instance.get_node("Entities/Players")
	npcs = level_instance.get_node("Entities/NPCS")
	enemies = level_instance.get_node("Entities/Enemies")
	items = level_instance.get_node("Entities/Items")
	terrain = level_instance.get_node("Entities/Terrain")
	tilemap = level_instance.get_node("TileMap")

	return true


func load_level(level_info: Dictionary):
	for element in level_info["terrain"]:
		var el: Node2D

		match element["class"]:
			"Tree":
				el = tree_scene.instantiate()
			"Tree_2":
				el = tree_2_scene.instantiate()
			"Tree_3":
				el = tree_3_scene.instantiate()
			"Caravan":
				el = caravan_scene.instantiate()
			"CaravanSign":
				el = sign_scene.instantiate()
			"Grass":
				el = grass_scene.instantiate()

		if not el:
			return

		el.position = Vector2(element["position"]["x"], element["position"]["y"])
		terrain.add_child(el)

	for layer in level_info["tilemap"]:
		for cell in layer["data"]:
			tilemap.set_cell(
				layer["layer"],
				Vector2(cell["co"]["x"], cell["co"]["y"]),
				cell["sid"],
				Vector2(cell["aco"]["x"], cell["aco"]["y"])
			)


func add_player(
	id: int, character_name: String, pos: Vector2, current_level: int, experience: int, gold: int
):
	var player = player_scene.instantiate()
	player.player = id
	player.position = pos
	player.current_level = current_level
	player.current_experience = experience
	player.username = character_name
	player.name = character_name
	players.add_child(player)

	player.inventory.gold = gold

	if id == multiplayer.get_unique_id():
		player_added.emit(player)


func add_other_player(id: int, character_name: String, pos: Vector2, hp: float):
	var player = player_scene.instantiate()
	player.player = id
	player.position = pos
	player.hp = hp
	player.username = character_name
	player.name = character_name
	players.add_child(player)


func remove_player(character_name: String):
	if players.has_node(character_name):
		players.get_node(character_name).queue_free()


func get_player_by_id(id: int):
	for player in players.get_children():
		if player.player == id:
			return player
	return null


func add_enemy(enemy_name: String, enemy_class: String, pos: Vector2, hp: float):
	var enemy: Entity

	match enemy_class:
		"Wolf":
			enemy = wolf_scene.instantiate()
		"Sheep":
			enemy = sheep_scene.instantiate()
		"Ram":
			enemy = ram_scene.instantiate()
		"Bushman":
			enemy = bushman_scene.instantiate()

	enemy.position = pos
	enemy.name = enemy_name
	enemy.hp = hp
	enemies.add_child(enemy)


func remove_enemy(enemy_name: String):
	if enemies.has_node(enemy_name):
		enemies.get_node(enemy_name).queue_free()


func add_npc(npc_name: String, npc_class: String, pos: Vector2, hp: float):
	var npc: Entity

	match npc_class:
		"MilkLady":
			npc = milklady_scene.instantiate()

	npc.position = pos
	npc.name = npc_name
	npc.hp = hp
	npcs.add_child(npc)


func remove_npc(npc_name: String):
	if npcs.has_node(npc_name):
		npcs.get_node(npc_name).queue_free()


func add_item(item_name: String, item_class: String, pos: Vector2):
	var loot = loot_scene.instantiate()
	loot.name = item_name
	loot.position = pos
	loot.item_class = item_class
	items.add_child(loot)


func remove_item(item_name: String):
	if items.has_node(item_name):
		items.get_node(item_name).queue_free()


func _on_player_added(
	id: int, character_name: String, pos: Vector2, current_level: int, experience: int, gold: int
):
	add_player(id, character_name, pos, current_level, experience, gold)


func _on_player_removed(character_name: String):
	remove_player(character_name)


func _on_other_player_added(id: int, character_name: String, pos: Vector2, hp: float):
	add_other_player(id, character_name, pos, hp)


func _on_other_player_removed(character_name: String):
	remove_player(character_name)


func _on_enemy_added(enemy_name: String, enemy_class: String, pos: Vector2, hp: float):
	add_enemy(enemy_name, enemy_class, pos, hp)


func _on_enemy_removed(enemy_name: String):
	remove_enemy(enemy_name)


func _on_npc_added(npc_name: String, npc_class: String, pos: Vector2, hp: float):
	add_npc(npc_name, npc_class, pos, hp)


func _on_npc_removed(npc_name: String):
	remove_npc(npc_name)


func _on_item_added(item_name: String, item_class: String, pos: Vector2):
	add_item(item_name, item_class, pos)


func _on_item_removed(item_name: String):
	remove_item(item_name)
