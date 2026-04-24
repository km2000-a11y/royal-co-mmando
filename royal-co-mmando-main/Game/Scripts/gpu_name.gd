extends Label

func _ready() -> void:
	Localization.language_changed.connect(_update_text)
	_update_text()

func _update_text():
	text = Localization.L("gpu") + ": " + get_gpu_name()

func get_gpu_name() -> String:
	var rd := RenderingServer.get_rendering_device()
	if rd != null:
		return rd.get_device_name()

	return RenderingServer.get_video_adapter_name()
