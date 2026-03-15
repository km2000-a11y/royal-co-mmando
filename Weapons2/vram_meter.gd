extends Label

func _process(_delta: float) -> void:
	# Get VRAM usage in bytes from the Performance monitor
	var vram_bytes = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	
	# Convert to MB (bytes / 1024 / 1024)
	var vram_mb = vram_bytes / 1048576.0
	
	# Update the label
	text = "Video RAM: " + str(snapped(vram_mb, 0.01)) + " MB"
