extends Label

func _ready():
	var rd := RenderingServer.get_rendering_device()

	if rd == null:
		text = "GPU: (Unavailable in Editor)"
		return

	var gpu := rd.get_device_name()
	text = "GPU: %s" % gpu
