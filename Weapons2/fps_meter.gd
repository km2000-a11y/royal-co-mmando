extends Label

func _process(_delta: float) -> void:
	# Engine.get_frames_per_second() returns the average FPS over the last few frames
	var fps = Engine.get_frames_per_second()
	
	# Update the text of the label
	text = "Frames per second: " + str(fps)
