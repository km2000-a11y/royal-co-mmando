extends Label

# --- Settings ---
@export var update_rate := 0.1 # Update every 100ms for readability
@export var show_units := true

var timer := 0.0

# REMOVED: -> float and return delta (This was causing the error)
func _process(delta: float):
	timer += delta
	
	if timer >= update_rate:
		display_frametime(delta)
		timer = 0.0

func display_frametime(delta: float):
	# Convert seconds to milliseconds
	var ms = delta * 1000.0
	
	# Update text: %.2f formats the float to 2 decimal places
	if show_units:
		text = "Frame Time: %.2f ms" % ms
	else:
		text = "%.2f" % ms
