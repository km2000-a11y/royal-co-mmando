extends Label

func _process(_delta: float) -> void:
	# Get the memory in bytes
	var mem_bytes = OS.get_static_memory_usage()
	
	# Convert to MB: bytes / 1024 / 1024
	var mem_mb = mem_bytes / 1048576.0
	
	# Print to the label, rounded to 2 decimal places
	text = "RAM: " + str(snapped(mem_mb, 0.01)) + " MB"
