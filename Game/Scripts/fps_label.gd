extends Label

@export var update_interval: float = 0.25  # seconds between FPS updates

var _time_accum: float = 0.0

func _ready() -> void:
	# Disable VSync so FPS isn't capped
	ProjectSettings.set_setting("display/window/vsync/vsync_mode", 0)
	ProjectSettings.save()

	text = "Frames per second: ..."
	set_process(true)

func _process(delta: float) -> void:
	_time_accum += delta

	if _time_accum >= update_interval:
		var fps := Engine.get_frames_per_second()
		text = "Frames per second: %d" % fps
		_update_color(fps)
		_time_accum = 0.0


func _update_color(fps: int) -> void:
	if fps >= 120:
		self.modulate = Color(0.4, 1.0, 0.4)   # very good – soft green
	elif fps >= 60:
		self.modulate = Color(0.8, 1.0, 0.4)   # good – yellow‑green
	elif fps >= 30:
		self.modulate = Color(1.0, 0.8, 0.3)   # playable – amber
	else:
		self.modulate = Color(1.0, 0.3, 0.3)   # bad – red
