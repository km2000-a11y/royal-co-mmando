extends Label

func _ready():
	var threads := OS.get_processor_count()
	text = "CPU Threads: %d" % threads
