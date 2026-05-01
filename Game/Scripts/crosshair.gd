extends Control

@export var dot_size := 2.0
@export var line_length := 8.0
@export var line_thickness := 2.0
@export var gap := 4.0
@export var crosshair_color := Color.CYAN

func _draw():
	# FAIL-SAFE: Get the actual center of the game window
	var center = get_viewport_rect().size / 2
	
	# Draw the center dot
	draw_circle(center, dot_size, crosshair_color)
	
	# Top
	draw_line(center + Vector2(0, -gap), center + Vector2(0, -gap - line_length), crosshair_color, line_thickness)
	# Bottom
	draw_line(center + Vector2(0, gap), center + Vector2(0, gap + line_length), crosshair_color, line_thickness)
	# Left
	draw_line(center + Vector2(-gap, 0), center + Vector2(-gap - line_length, 0), crosshair_color, line_thickness)
	# Right
	draw_line(center + Vector2(gap, 0), center + Vector2(gap + line_length, 0), crosshair_color, line_thickness)

func _process(_delta):
	queue_redraw()
