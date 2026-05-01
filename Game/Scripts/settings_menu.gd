#Hi
extends CanvasLayer

# -------------------------
#  Render scale definitions
# -------------------------
const SCALES = {
	0: 0.5,
	1: 0.75,
	2: 1.0
}

var player: Node = null
var current_language := "en"

# -------------------------
#  UI Nodes
# -------------------------
@onready var resolution_selector: OptionButton = $PanelRoot/Panel/VBoxContainer/ResolutionRow/ResolutionSelector
@onready var volume_label: Label = $PanelRoot/Panel/VBoxContainer/VolumeRow/VolValue
@onready var sens_slider: HSlider = $PanelRoot/Panel/VBoxContainer/Sensitivity/SensSlider
@onready var sens_value: Label = $PanelRoot/Panel/VBoxContainer/Sensitivity/SensValue

# Language buttons
@onready var BtnEnglish = $PanelRoot/Panel/VBoxContainer/LanguageRow/BtnEnglish
@onready var BtnRussian = $PanelRoot/Panel/VBoxContainer/LanguageRow/BtnRussian
@onready var BtnUkrainian = $PanelRoot/Panel/VBoxContainer/LanguageRow/BtnUkrainian
@onready var BtnSerbian = $PanelRoot/Panel/VBoxContainer/LanguageRow/BtnSerbian
@onready var BtnTurkish = $PanelRoot/Panel/VBoxContainer/LanguageRow/BtnTurkish

# Audio
var master_volume := 1.0
@onready var gunshot_player: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var reload_player: AudioStreamPlayer = $ReloadPlayer

# -------------------------
#  Lifecycle
# -------------------------
func _ready() -> void:
	Localization.load_language()
	current_language = Localization.current_language

	_load_settings()
	_populate_resolution_selector()
	_apply_master_volume()

	Localization.language_changed.connect(_update_ui_texts)

	_update_ui_texts()
	_update_volume_label()

	hide()

	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if player:
		player.sensitivity = sens_slider.value

# -------------------------
#  Sensitivity Slider Signal
# -------------------------
func _on_sens_slider_value_changed(value: float) -> void:
	if player:
		player.sensitivity = value

	sens_value.text = String.num(value, 2)
	_save_settings(resolution_selector.get_selected_id())

# -------------------------
#  Populate UI
# -------------------------
func _populate_resolution_selector()->void:
	resolution_selector.clear()
	resolution_selector.add_item("50%")
	resolution_selector.add_item("75%")
	resolution_selector.add_item("100%")
	
	resolution_selector.select(2)
	_apply_resolution_scale(2)

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
	cfg.set_value("language", "current_language", Localization.current_language)

	if player:
		cfg.set_value("controls", "sensitivity", player.sensitivity)

	cfg.save("user://settings.cfg")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") != OK:
		return

	var index: int = cfg.get_value("video", "scale_index", 2)
	resolution_selector.select(index)
	_apply_resolution_scale(index)

	master_volume = cfg.get_value("audio", "master_volume", 1.0)

	var saved_sens := cfg.get_value("controls", "sensitivity", 0.5) as float
	sens_slider.value = saved_sens
	sens_value.text = String.num(saved_sens, 2)

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
	volume_label.text = str(round(master_volume * 100)) + "%"

# -------------------------
#  UI TEXT UPDATE
# -------------------------
func _update_ui_texts() -> void:
	BtnEnglish.text = "English"
	BtnRussian.text = "Русский"
	BtnUkrainian.text = "Українська"
	BtnSerbian.text = "Српски"
	BtnTurkish.text = "Türkçe"

	$PanelRoot/Panel/VBoxContainer/Label.text = Localization.L("settings")
	$PanelRoot/Panel/VBoxContainer/ResolutionRow/Label.text = Localization.L("res_scale")
	$PanelRoot/Panel/VBoxContainer/Sensitivity/Label.text = Localization.L("sensitivity")

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
	Localization.set_language(lang)
	current_language = Localization.current_language
	_save_settings(resolution_selector.get_selected_id())

func _on_btn_english_pressed() -> void: _set_language("en")
func _on_btn_russian_pressed() -> void: _set_language("ru")
func _on_btn_ukrainian_pressed() -> void: _set_language("uk")
func _on_btn_serbian_pressed() -> void: _set_language("sr")
func _on_btn_turkish_pressed() -> void: _set_language("tr")
