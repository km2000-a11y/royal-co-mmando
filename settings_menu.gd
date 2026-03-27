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
#  Gunshot Volume
# -------------------------
var gunshot_volume := 1.0
@onready var gunshot_label: Label = $PanelRoot/Panel/VBoxContainer/VolumeRow/VolValue

# IMPORTANT: point this to your actual gunshot AudioStreamPlayer
@onready var gunshot_player: AudioStreamPlayer = $AudioStreamPlayer3D

# -------------------------
#  Lifecycle
# -------------------------
func _ready() -> void:
	_populate_resolution_selector()
	_load_settings()
	_load_gunshot_volume()
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
#  Save / Load resolution
# -------------------------
func _save_settings(index: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "scale_index", index)
	cfg.set_value("audio", "gunshot_volume", gunshot_volume)
	cfg.save("user://settings.cfg")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return

	var index: int = cfg.get_value("video", "scale_index", 2)
	resolution_selector.select(index)
	_apply_resolution_scale(index)

	gunshot_volume = cfg.get_value("audio", "gunshot_volume", 1.0)

# -------------------------
#  Gunshot Volume (Player-based)
# -------------------------
func _load_gunshot_volume() -> void:
	var bus := AudioServer.get_bus_index("Gunshot")
	var db := AudioServer.get_bus_volume_db(bus)
	gunshot_volume = db_to_linear(db)
	_update_gunshot_label()

func _apply_gunshot_volume() -> void:
	var bus := AudioServer.get_bus_index("Gunshot")
	var db := linear_to_db(gunshot_volume)
	AudioServer.set_bus_volume_db(bus, db)

func _update_gunshot_label() -> void:
	gunshot_label.text = str(round(gunshot_volume * 100)) + "%"

# -------------------------
#  UI Signals
# -------------------------
func _on_resolution_selector_item_selected(index: int) -> void:
	_apply_resolution_scale(index)
	_save_settings(index)

func _on_vol_down_pressed() -> void:
	gunshot_volume = clamp(gunshot_volume - 0.05, 0.0, 1.0)
	_apply_gunshot_volume()
	_update_gunshot_label()

func _on_vol_up_pressed() -> void:
	gunshot_volume = clamp(gunshot_volume + 0.05, 0.0, 1.0)
	_apply_gunshot_volume()
	_update_gunshot_label()
