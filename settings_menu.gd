extends CanvasLayer

# -------------------------
#  Resolution definitions
# -------------------------
const RESOLUTIONS := {
	0: Vector2i(1024, 600),
	1: Vector2i(1280, 720),
	2: Vector2i(1920, 1080),
	3: Vector2i(2560, 1440)
}

# Shortcut to the OptionButton
@onready var resolution_selector := $PanelRoot/Panel/VBoxContainer/ResolutionRow/ResolutionSelector


# -------------------------
#  Lifecycle
# -------------------------
func _ready() -> void:
	_populate_resolution_selector()
	_load_settings()


# -------------------------
#  Populate UI
# -------------------------
func _populate_resolution_selector() -> void:
	resolution_selector.clear()
	resolution_selector.add_item("600p (1024×600)")
	resolution_selector.add_item("720p (1280×720)")
	resolution_selector.add_item("1080p (1920×1080)")
	resolution_selector.add_item("1440p (2560×1440)")


# -------------------------
#  Apply resolution
# -------------------------
func _apply_resolution(index: int) -> void:
	if RESOLUTIONS.has(index):
		get_viewport().size = RESOLUTIONS[index]


# -------------------------
#  Save / Load
# -------------------------
func _save_settings(index: int) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "resolution_index", index)
	cfg.save("user://settings.cfg")


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return

	var index : int = cfg.get_value("video", "resolution_index", 2)
	resolution_selector.select(index)
	_apply_resolution(index)


# -------------------------
#  Signals
# -------------------------
func _on_ResolutionSelector_item_selected(index: int) -> void:
	_apply_resolution(index)
	_save_settings(index)
