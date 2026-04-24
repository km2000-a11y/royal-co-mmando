extends Label

@export var update_interval: float = 0.25
var _time_accum: float = 0.0

func _ready() -> void:
	Localization.language_changed.connect(_update_text)
	_update_text()
	set_process(true)

func _update_text():
	text = Localization.L("fps") + ": ..."

func _process(delta: float) -> void:
	_time_accum += delta

	if _time_accum >= update_interval:
		var fps := Engine.get_frames_per_second()
		text = Localization.L("fps") + ": " + str(fps)
		_update_color(fps)
		_time_accum = 0.0

func _update_color(fps: int) -> void:
	if fps >= 120:
		self.modulate = Color(0.4, 1.0, 0.4)
	elif fps >= 60:
		self.modulate = Color(0.8, 1.0, 0.4)
	elif fps >= 30:
		self.modulate = Color(1.0, 0.8, 0.3)
	else:
		self.modulate = Color(1.0, 0.3, 0.3)
