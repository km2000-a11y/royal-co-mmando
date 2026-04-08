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

# -------------------------
#  Translation files
# -------------------------
const LANG_FILES = {
	"en": "res://Game/Translations/en.translation",
	"ru": "res://Game/Translations/ru.translation",
	"pl": "res://Game/Translations/pl.translation",
	"uk": "res://Game/Translations/uk.translation",
	"sr": "res://Game/Translations/sr.translation"
}

var current_language := "en"

# -------------------------
#  UI Nodes
# -------------------------
@onready var resolution_selector: OptionButton = $PanelRoot/Panel/VBoxContainer/ResolutionRow/ResolutionSelector
@onready var volume_label: Label = $PanelRoot/Panel/VBoxContainer/VolumeRow/VolValue

# Language buttons
@onready var BtnEnglish = $PanelRoot/Panel/VBoxContainer/LangRow/BtnEnglish
@onready var BtnRussian = $PanelRoot/Panel/VBoxContainer/LangRow/BtnRussian
@onready var BtnPolish = $PanelRoot/Panel/VBoxContainer/LangRow/BtnPolish
@onready var BtnUkrainian = $PanelRoot/Panel/VBoxContainer/LangRow/BtnUkrainian
@onready var BtnSerbian = $PanelRoot/Panel/VBoxContainer/LangRow/BtnSerbian

# Audio
var master_volume := 1.0
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
	_apply_translation()
	_update_ui_texts()
	hide()

# -------------------------
#  Populate UI
# -------------------------
func _populate_resolution_selector() -> void:
	resolution_selector.clear()
	resolution_selector.add_item("25%")
	resolution_selector.add_item("50%")
	resolution_selector.add_item("75%")
	resolution_selector.add_item("100%")

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
	cfg.set_value("language", "current_language", current_language)
	cfg.save("user://settings.cfg")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return

	var index: int = cfg.get_value("video", "scale_index", 2)
	resolution_selector.select(index)
	_apply_resolution_scale(index)

	master_volume = cfg.get_value("audio", "master_volume", 1.0)
	current_language = cfg.get_value("language", "current_language", "en")

# -------------------------
#  Apply Master Volume
# -------------------------
func _apply_master_volume() -> void:
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
	volume_label.text = tr(str(round(master_volume * 100))) + "%"

# -------------------------
#  Translation Logic
# -------------------------
func _apply_translation() -> void:
	if LANG_FILES.has(current_language):
		TranslationServer.clear()
		var tr_file = load(LANG_FILES[current_language])
		if tr_file:
			TranslationServer.add_translation(tr_file)
		print("Language applied:", current_language)

# -------------------------
#  UI TEXT UPDATE (IMPORTANT)
# -------------------------
func _update_ui_texts() -> void:
	# Update all UI text using translation keys
	BtnEnglish.text = "English"
	BtnRussian.text = "Русский"
	BtnPolish.text = "Polska"
	BtnUkrainian.text = "Українська"
	BtnSerbian.text = "Српски"

	# Example: if you have labels like "Volume", "Resolution", etc.
	$PanelRoot/Panel/VBoxContainer/VolumeRow/VolValue.text = tr("Volume:")
	$PanelRoot/Panel/VBoxContainer/ResolutionRow/Label.text = tr("Resolution Scale")
	$PanelRoot/Panel/VBoxContainer/Label.text=tr("Settings")
	

	_update_volume_label()

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

# -------------------------
#  Language Button Signals
# -------------------------
func _set_language(lang: String) -> void:
	current_language = lang
	_apply_translation()
	_update_ui_texts()
	_save_settings(resolution_selector.get_selected_id())

func _on_btn_english_pressed() -> void: _set_language("en")
func _on_btn_russian_pressed() -> void: _set_language("ru")
func _on_btn_ukrainian_pressed() -> void: _set_language("uk")
func _on_btn_polish_pressed() -> void: _set_language("pl")
func _on_btn_serbian_pressed() -> void: _set_language("sr")
