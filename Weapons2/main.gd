#This is my Main script!
extends Node

@onready var lan_ui = $LANUI
@onready var map = $Map

var game_started := false
var ready_clients: Array[int] = []


func _ready():
	map.visible = false

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _on_connected_to_server():
	print("Client connected to host")
	rpc_id(1, "_client_ready", multiplayer.get_unique_id())


func _on_peer_connected(id: int):
	print("Peer connected:", id)


func _on_connection_failed():
	print("Connection failed")


@rpc("any_peer")
func _client_ready(id: int):
	if not multiplayer.is_server():
		return

	print("Client ready:", id)
	if id not in ready_clients:
		ready_clients.append(id)

	var host_id := multiplayer.get_unique_id()
	if host_id not in ready_clients:
		ready_clients.append(host_id)

	var total_players := multiplayer.get_peers().size() + 1
	if ready_clients.size() >= total_players:
		_start_game_once()


func _start_game_once():
	if game_started:
		return

	game_started = true
	print("START GAME CALLED BY:", multiplayer.get_unique_id(), " SERVER:", multiplayer.is_server())

	rpc("_start_game_visuals")
	_spawn_players()


@rpc("call_local")
func _start_game_visuals():
	print("MAIN: _start_game_visuals fired")
	lan_ui.visible = false
	map.visible = true

	# DIRECT call — no RPC needed
	if lan_ui.has_method("_on_game_started"):
		lan_ui._on_game_started()


func _spawn_players():
	if not multiplayer.is_server():
		return

	var host_id := multiplayer.get_unique_id()
	var all_ids: Array[int] = [host_id]

	map.spawn_player(host_id)

	for id in multiplayer.get_peers():
		all_ids.append(id)
		map.spawn_player(id)

	rpc("_spawn_players_remote", all_ids)


@rpc("call_local")
func _spawn_players_remote(ids: Array[int]):
	for id in ids:
		map.spawn_player(id)
