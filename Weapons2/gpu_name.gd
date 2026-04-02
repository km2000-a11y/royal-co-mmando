extends Label

func _ready() -> void:
	text = "GPU: " + get_gpu_name()


func get_gpu_name() -> String:
	# Try Vulkan RenderingDevice first
	var rd := RenderingServer.get_rendering_device()
	if rd != null:
		return rd.get_device_name()

	# Fallback for OpenGL / Compatibility mode
	return RenderingServer.get_video_adapter_name()
