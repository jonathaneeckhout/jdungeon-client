extends Node

signal connected(succeeded: bool)
signal logged_in(succeeded: bool)
signal player_added(id: int, character_name: String, pos: Vector2)
signal player_removed(character_name: String)

signal other_player_added(id: int, character_name: String, pos: Vector2, hp: int, max_hp: int)
signal other_player_removed(character_name: String)

signal enemy_added(enemy_name: String, enemy_class: String, pos: Vector2, hp: int, max_hp: int)
signal enemy_removed(enemy_name: String)

signal npc_added(npc_name: String, npc_class: String, pos: Vector2, hp: int, max_hp: int)
signal npc_removed(npc_name: String)

signal item_added(item_name: String, item_class: String, pos: Vector2)
signal item_removed(item_name: String)
signal gold_updated(amount: int)

signal item_added_to_inventory(item_uuid: String, item_class: String)
signal item_removed_from_inventory(item_uuid: String)
signal inventory_updated(items: Dictionary)

signal shop_updated(vendor: String, shop: Dictionary)

signal item_equipped(equipment_slot: String, item_uuid: String, item_class: String)
signal item_unequipped(equipment_slot: String)
signal equipment_updated(items: Dictionary)

signal stats_updated(stats: Dictionary)

const CLOCK_SYNC_TIMER_TIME = 0.5
const LATENCY_BUFFER_SIZE = 9
const LATENCY_BUFFER_MID_POINT = int(LATENCY_BUFFER_SIZE / float(2))
const LATENCY_MINIMUM_THRESHOLD = 20

var client: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var clock: float = 0.0
var clock_sync_timer: Timer

var latency: float = 0.0
var latency_buffer = []
var delta_latency: float = 0.0


func _ready():
	clock_sync_timer = Timer.new()
	clock_sync_timer.wait_time = CLOCK_SYNC_TIMER_TIME
	clock_sync_timer.timeout.connect(_on_clock_sync_timer_timeout)
	add_child(clock_sync_timer)


func _physics_process(delta):
	clock += delta + delta_latency
	delta_latency = 0


func connect_to_server(ip, port):
	var error = client.create_client(ip, port)
	if error != OK:
		print("Error while creating")
		return false

	if client.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to connect to game")
		# OS.alert("Failed to start multiplayer client.")
		return false

	var client_tls_options: TLSOptions

	if Global.env_debug:
		client_tls_options = TLSOptions.client_unsafe()
	else:
		client_tls_options = TLSOptions.client()

	error = client.host.dtls_client_setup(ip, client_tls_options)
	if error != OK:
		print("Failed to connect via DTLS")
		return false

	multiplayer.multiplayer_peer = client

	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	return true


func disconnect_to_server():
	client.close()


func start_sync_clock():
	fetch_server_time.rpc_id(1, Time.get_unix_time_from_system())
	clock_sync_timer.start(CLOCK_SYNC_TIMER_TIME)


func stop_sync_clock():
	clock_sync_timer.stop()


func _on_connection_succeeded():
	print("Connection succeeded")
	connected.emit(true)

	start_sync_clock()


func _on_server_disconnected():
	print("Server disconnected us")
	stop_sync_clock()


func _on_connection_failed():
	print("Connection failed")

	connected.emit(false)


func _on_clock_sync_timer_timeout():
	get_latency.rpc_id(1, Time.get_unix_time_from_system())


@rpc("call_remote", "any_peer", "reliable")
func authenticate_with_secret(_username: String, _secret: String, _character: String):
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable") func client_login_response(succeeded: bool):
	print("Login to level server %s" % [succeeded])
	logged_in.emit(succeeded)


@rpc("call_remote", "authority", "reliable")
func add_player(id: int, character_name: String, pos: Vector2):
	player_added.emit(id, character_name, pos)


@rpc("call_remote", "authority", "reliable") func remove_player(character_name: String):
	player_removed.emit(character_name)


@rpc("call_remote", "authority", "reliable")
func add_other_player(id: int, character_name: String, pos: Vector2, hp: int, max_hp: int):
	other_player_added.emit(id, character_name, pos, hp, max_hp)


@rpc("call_remote", "authority", "reliable") func remove_other_player(character_name: String):
	other_player_removed.emit(character_name)


@rpc("call_remote", "any_peer", "reliable") func move(_input_sequence: int, _pos: Vector2):
	# Placeholder code
	pass


@rpc("call_remote", "any_peer", "reliable") func interact(_input_sequence: int, _target: String):
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable")
func add_enemy(enemy_name: String, enemy_class: String, pos: Vector2, hp: int, max_hp: int):
	enemy_added.emit(enemy_name, enemy_class, pos, hp, max_hp)


@rpc("call_remote", "authority", "reliable") func remove_enemy(enemy_name: String):
	enemy_removed.emit(enemy_name)


@rpc("call_remote", "authority", "reliable")
func add_item(item_name: String, item_class: String, pos: Vector2):
	item_added.emit(item_name, item_class, pos)


@rpc("call_remote", "authority", "reliable") func remove_item(item_name: String):
	item_removed.emit(item_name)


@rpc("call_remote", "authority", "reliable")
func add_npc(npc_name: String, npc_class: String, pos: Vector2, hp: int, max_hp: int):
	npc_added.emit(npc_name, npc_class, pos, hp, max_hp)


@rpc("call_remote", "authority", "reliable") func remove_npc(npc_name: String):
	npc_removed.emit(npc_name)


@rpc("call_remote", "authority", "reliable") func sync_gold(amount: int):
	gold_updated.emit(amount)


@rpc("call_remote", "authority", "reliable")
func add_item_to_inventory(item_uuid: String, item_class: String):
	item_added_to_inventory.emit(item_uuid, item_class)


@rpc("call_remote", "authority", "reliable") func remove_item_from_inventory(item_uuid: String):
	item_removed_from_inventory.emit(item_uuid)


@rpc("call_remote", "any_peer", "reliable") func use_inventory_item(_item_uuid: String):
	# Placeholder code
	pass


@rpc("call_remote", "any_peer", "reliable") func drop_inventory_item(_item_uuid: String):
	# Placeholder code
	pass


@rpc("call_remote", "any_peer", "reliable") func get_inventory():
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable") func sync_inventory(inventory: Dictionary):
	inventory_updated.emit(inventory)


@rpc("call_remote", "any_peer", "reliable") func buy_shop_item(_vendor: String, _item_uuid: String):
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable") func sync_shop(vendor: String, shop: Dictionary):
	shop_updated.emit(vendor, shop)


@rpc("call_remote", "authority", "reliable")
func equip_item(equipment_slot: String, item_uuid: String, item_class: String):
	item_equipped.emit(equipment_slot, item_uuid, item_class)


@rpc("call_remote", "authority", "reliable") func unequip_item(equipment_slot: String):
	item_unequipped.emit(equipment_slot)


@rpc("call_remote", "any_peer", "reliable") func remove_equipment_item(_item_uuid: String):
	# Placeholder code
	pass


@rpc("call_remote", "any_peer", "reliable") func get_equipment():
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable") func sync_equipment(equiment: Dictionary):
	equipment_updated.emit(equiment)


@rpc("call_remote", "any_peer", "reliable") func get_stats():
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable") func sync_stats(stats: Dictionary):
	stats_updated.emit(stats)


@rpc("call_remote", "any_peer", "reliable") func fetch_server_time(_client_time: float):
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable")
func return_server_time(server_time: float, client_time: float):
	latency = (Time.get_unix_time_from_system() - client_time) / 2
	clock = server_time + latency


@rpc("call_remote", "any_peer", "reliable") func get_latency(_client_time: float):
	# Placeholder code
	pass


@rpc("call_remote", "authority", "reliable") func return_latency(client_time: float):
	latency_buffer.append((Time.get_unix_time_from_system() - client_time) / 2)
	if latency_buffer.size() == LATENCY_BUFFER_SIZE:
		var total_latency = 0
		var total_counted = 0

		latency_buffer.sort()

		var mid_point_threshold = latency_buffer[LATENCY_BUFFER_MID_POINT] * 2

		for i in range(LATENCY_BUFFER_SIZE - 1):
			if (
				latency_buffer[i] < mid_point_threshold
				or latency_buffer[i] < LATENCY_MINIMUM_THRESHOLD
			):
				total_latency += latency_buffer[i]
				total_counted += 1

		var average_latency = total_latency / total_counted
		delta_latency = average_latency - latency
		latency = average_latency

		latency_buffer.clear()
