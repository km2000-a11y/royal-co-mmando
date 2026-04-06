extends CanvasLayer

@onready var host_button	= $LANMenu/HostButton
@onready var join_button	= $LANMenu/JoinButton
@onready var ip_entry = $LANMenu/IPEntry

# Absolute paths so they ALWAYS resolve correctly
@onready var hud	 = $"/root/Main/HUD"
@onready var crosshair = $"/root/Main/Crosshair"

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

	print("HUD node =", hud)
	print("Crosshair node =", crosshair)

	# Hide HUD + crosshair while LAN menu is open
	_hide_game_ui()

	visible = true
	_hide_game_ui()


@rpc("call_local")
func _on_game_started():
	# Game is starting → show HUD and hide LAN menu
	print("LANMENU RECEIVED _on_game_started()")
	_show_game_ui()
	visible = false


func _hide_game_ui():
	if hud:
		hud.visible = false
	if crosshair:
		crosshair.visible = false


func _show_game_ui():
	if hud:
		hud.visible = true
	if crosshair:
		crosshair.visible = true


# -----------------------------
# HOST
# -----------------------------
func _on_host_pressed():
	var ws := WebSocketMultiplayerPeer.new()
	var port := 8080

	var err = ws.create_server(port)
	if err != OK:
		push_error("Failed to host WebSocket server")
		return

	multiplayer.multiplayer_peer = ws
	ip_entry.text = "Hosting on port " + str(port)
	print("HOST PRESSED, ws =", ws)


# -----------------------------
# JOIN
# -----------------------------
func _on_join_pressed():
	var ip = ip_entry.text.strip_edges()
	if ip == "":
		return

	var ws := WebSocketMultiplayerPeer.new()
	var err = ws.create_client("ws://" + ip + ":8080")
	if err != OK:
		push_error("Failed to connect to host")
		return

	multiplayer.multiplayer_peer = ws
	ip_entry.text = "Connecting to " + ip
	print("JOIN PRESSED, ws =", ws)
	
