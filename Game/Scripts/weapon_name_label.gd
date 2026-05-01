extends Label

var weapon_name: String = ""

func _ready():
	Localization.language_changed.connect(_update_text)
	_update_text()

func set_weapon_name(name: String) -> void:
	weapon_name = name
	_update_text()

func _update_text():
	if weapon_name != "":
		text = Localization.L("weapon") + ": " + weapon_name
