extends CanvasLayer

# -------------------------
#  Render scale definitions
# -------------------------
# Ordered from lowest → highest
const SCALES = {
	0: 0.25,  # Lowest
	1: 0.5,   # Medium
	2: 0.75,  # High
	3: 1.0    # Full resolution
}

@onready var resolution_selector: OptionButton = $PanelRoot/Panel/VBoxContainer/ResolutionRow/ResolutionSelector


# -------------------------
#  Lifecycle
# -------------------------
func _ready() -> void:
	_populate_resolution_selector()
	_load_settings()
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
#  Save / Load
# -------------------------
func _save_settings(index: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "scale_index", index)
	cfg.save("user://settings.cfg")


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return

	var index: int = cfg.get_value("video", "scale_index", 2)
	resolution_selector.select(index)
	_apply_resolution_scale(index)


# -------------------------
#  UI Signal
# -------------------------
func _on_resolution_selector_item_selected(index: int) -> void:
	_apply_resolution_scale(index)
	_save_settings(index)
