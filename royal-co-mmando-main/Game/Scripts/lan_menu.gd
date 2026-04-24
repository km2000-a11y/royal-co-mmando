extends CanvasLayer

@onready var host_button = $LANMenu/HostButton
@onready var join_button = $LANMenu/JoinButton
@onready var ip_entry = $LANMenu/IPEntry

# Absolute paths so they ALWAYS resolve correctly
@onready var hud = $"/root/Main/HUD"
@onready var crosshair = $"/root/Main/Crosshair"

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

	# Apply localization to UI
	_update_ui_texts()

	# Update when language changes
	Localization.language_changed.connect(_update_ui_texts)

	_hide_game_ui()
	visible = true


func _update_ui_texts():
	# Buttons
	host_button.text = Localization.L("host_lan")
	join_button.text = Localization.L("join_lan")

	# IP entry placeholder
	ip_entry.placeholder_text = Localization.L("enter_ip")


@rpc("call_local")
func _on_game_started():
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

	# Localized hosting message
	ip_entry.text = Localization.L("host_lan") + " (8080)"

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

	# Localized connecting message
	ip_entry.text = Localization.L("join_lan") + ": " + ip

	print("JOIN PRESSED, ws =", ws)
