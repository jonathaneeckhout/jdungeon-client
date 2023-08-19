extends Node

var above_ui = false
var typing_chat = false

var env_debug: bool
var env_debug_username: String
var env_debug_password: String

var env_common_server_host: String
var env_common_server_port: int

var env_common_server_address: String


func load_env_variables():
	env_debug = Env.get_value("DEBUG") == "true"

	env_debug_username = Env.get_value("DEBUG_USERNAME")

	env_debug_password = Env.get_value("DEBUG_PASSWORD")

	env_common_server_host = Env.get_value("COMMON_SERVER_HOST")
	if env_common_server_host == "":
		return false

	var env_common_server_port_str = Env.get_value("COMMON_SERVER_PORT")
	if env_common_server_port_str == "":
		return false

	env_common_server_port = int(env_common_server_port_str)

	env_common_server_address = Env.get_value("COMMON_SERVER_ADDRESS")
	if env_common_server_address == "":
		return false

	return true


func item_class_to_item(item_class: String):
	var item: Item
	match item_class:
		"Gold":
			item = load("res://scripts/items/varia/gold.gd").new()

		"HealthPotion":
			item = load("res://scripts/items/consumables/healthPotion.gd").new()
		"ManaPotion":
			item = load("res://scripts/items/consumables/manaPotion.gd").new()
		"Apple":
			item = load("res://scripts/items/consumables/apple.gd").new()
		"Meat":
			item = load("res://scripts/items/consumables/meat.gd").new()

		"IronSpear":
			item = load("res://scripts/items/equipment/weapons/ironspear.gd").new()
		"IronSword":
			item = load("res://scripts/items/equipment/weapons/ironsword.gd").new()

		"IronPlateArms":
			item = load("res://scripts/items/equipment/armours/ironplatearms.gd").new()
		"IronPlateBody":
			item = load("res://scripts/items/equipment/armours/ironplatebody.gd").new()
		"IronPlateBoots":
			item = load("res://scripts/items/equipment/armours/ironplateboots.gd").new()
		"IronPlateHelm":
			item = load("res://scripts/items/equipment/armours/ironplatehelm.gd").new()
		"IronPlateLegs":
			item = load("res://scripts/items/equipment/armours/ironplatelegs.gd").new()

		"WoolArms":
			item = load("res://scripts/items/equipment/armours/woolarms.gd").new()
		"WoolBody":
			item = load("res://scripts/items/equipment/armours/woolbody.gd").new()
		"WoolBoots":
			item = load("res://scripts/items/equipment/armours/woolboots.gd").new()
		"WoolHat":
			item = load("res://scripts/items/equipment/armours/woolhat.gd").new()
		"WoolLegs":
			item = load("res://scripts/items/equipment/armours/woollegs.gd").new()

	return item
