# This is my Main script!
extends Node

@onready var lan_ui = $LANUI
@onready var map = $Map
@onready var hud = $HUD
@onready var timer = $Timer

var game_started := false
var ready_clients: Array[int] = []


func _ready():
	# Initial UI state
	map.visible = false
	hud.visible = false

	# Ensure timer is not running until match starts
	timer.stop()

	# Multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _process(delta):
	if game_started:
		var minutes := int(timer.time_left / 60)
		var seconds := int(timer.time_left) % 60
		$HUD/Control/TimerLabel.text = Localization.L("time_remaining") \
			+ str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)


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

	# Show gameplay UI on all clients
	rpc("_start_game_visuals")

	# Spawn players on server
	_spawn_players()

	# Start match timer (uses inspector wait_time)
	timer.start()


@rpc("call_local")
func _start_game_visuals():
	print("MAIN: _start_game_visuals fired")

	lan_ui.visible = false
	map.visible = true
	hud.visible = true

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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


func _on_timer_timeout() -> void:
	print("MATCH OVER — returning to LANUI")

	# SERVER handles logic
	if multiplayer.is_server():
		game_started = false
		ready_clients.clear()
		timer.stop()

	# EVERYONE resets visuals
	rpc("_end_match_visuals")


@rpc("call_local")
func _end_match_visuals():
	print("END MATCH VISUALS CALLED ON:", multiplayer.get_unique_id())

	# Hide gameplay
	map.visible = false
	hud.visible = false
	lan_ui.visible = true

	# Release mouse ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Reset local state
	game_started = false

	# Notify LAN UI
	if lan_ui.has_method("_on_returned_to_menu"):
		lan_ui._on_returned_to_menu()
