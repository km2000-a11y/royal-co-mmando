extends CanvasLayer

# -------------------------
#  Render scale definitions
# -------------------------
const SCALES = {
	0: 0.25,
	1: 0.5,
	2: 0.75,
	3: 1.0
}

@onready var resolution_selector: OptionButton = $PanelRoot/Panel/VBoxContainer/ResolutionRow/ResolutionSelector

# -------------------------
#  Master Volume (SFX)
# -------------------------
var master_volume := 1.0
@onready var volume_label: Label = $PanelRoot/Panel/VBoxContainer/VolumeRow/VolValue

# IMPORTANT: point these to your actual AudioStreamPlayers
@onready var gunshot_player: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var reload_player: AudioStreamPlayer = $ReloadPlayer

# -------------------------
#  Lifecycle
# -------------------------
func _ready() -> void:
	_populate_resolution_selector()
	_load_settings()
	_apply_master_volume()
	_update_volume_label()
	hide()

# -------------------------
#  Populate UI
# -------------------------
func _populate_resolution_selector() -> void:
	resolution_selector.clear()
	resolution_selector.add_item("25% (Lowest)")
	resolution_selector.add_item("50% (Medium)")
	resolution_selector.add_item("75% (High)")
	resolution_selector.add_item("100% (Full)")

# -------------------------
#  Apply internal resolution scale
# -------------------------
func _apply_resolution_scale(index: int) -> void:
	if SCALES.has(index):
		var scale: float = SCALES[index]
		get_viewport().scaling_3d_scale = scale
		print("Applied render scale:", scale)

# -------------------------
#  Save / Load settings
# -------------------------
func _save_settings(index: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "scale_index", index)
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.save("user://settings.cfg")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return

	var index: int = cfg.get_value("video", "scale_index", 2)
	resolution_selector.select(index)
	_apply_resolution_scale(index)

	master_volume = cfg.get_value("audio", "master_volume", 1.0)

# -------------------------
func _apply_master_volume()->void:
	var db := linear_to_db(master_volume)
	
	var gunshot_bus = AudioServer.get_bus_index("Gunshot")
	if gunshot_bus != -1:
		AudioServer.set_bus_volume_db(gunshot_bus, db)
	
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, db)
	
	if is_instance_valid(gunshot_player):
		gunshot_player.volume_db = db
	if is_instance_valid(reload_player):
		reload_player.volume_db = db

func _update_volume_label() -> void:
	volume_label.text = str(round(master_volume * 100)) + "%"

# -------------------------
#  UI Signals
# -------------------------
func _on_resolution_selector_item_selected(index: int) -> void:
	_apply_resolution_scale(index)
	_save_settings(index)

func _on_vol_down_pressed() -> void:
	master_volume = clamp(master_volume - 0.05, 0.0, 1.0)
	_apply_master_volume()
	_update_volume_label()
	_save_settings(resolution_selector.get_selected_id())

func _on_vol_up_pressed() -> void:
	master_volume = clamp(master_volume + 0.05, 0.0, 1.0)
	_apply_master_volume()
	_update_volume_label()
	_save_settings(resolution_selector.get_selected_id())
