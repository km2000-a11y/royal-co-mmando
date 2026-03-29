extends Node

func _ready():
	# 1. If NOT running in Web → skip detection safely
	if not OS.has_feature("web"):
		print("BrowserGatekeeper: Not running in Web. Skipping browser checks.")
		return

	# 2. If running in Web → detect Safari/iOS
	if _is_safari_or_ios():
		_show_block_screen(
			"🚫 SAFARI NOT SUPPORTED\n\n"
			+ "Royal Commando cannot run on Safari or any browser on iPhone/iPad.\n\n"
			+ "On iOS, every browser (Chrome, Firefox, Edge, Brave, Opera, Vivaldi) "
			+ "is forced to use Safari's engine.\n\n"
			+ "Please use Chrome, Firefox, Edge, Opera, Vivaldi, Brave, or Samsung Internet."
		)
		return

	print("BrowserGatekeeper: Browser OK.")


# ---------------------------------------------------------
# SAFARI + iOS DETECTION
# ---------------------------------------------------------
func _is_safari_or_ios() -> bool:
	var ua := JavaScriptBridge.eval("navigator.userAgent") as String
	var vendor := JavaScriptBridge.eval("navigator.vendor") as String
	var platform := JavaScriptBridge.eval("navigator.platform") as String
	var max_touch := JavaScriptBridge.eval("navigator.maxTouchPoints") as int

	# True Safari on macOS
	var is_safari_desktop := (
		ua.find("Safari") != -1
		and ua.find("Chrome") == -1
		and ua.find("Chromium") == -1
		and vendor == "Apple Computer, Inc."
	)

	# iOS devices (ALL browsers use Safari engine)
	var is_ios := (
		ua.find("iPhone") != -1
		or ua.find("iPad") != -1
		or ua.find("iPod") != -1
		or (platform == "MacIntel" and max_touch > 1) # iPad pretending to be Mac
	)

	return is_safari_desktop or is_ios


# ---------------------------------------------------------
# FULLSCREEN BLOCK SCREEN
# ---------------------------------------------------------
func _show_block_screen(message: String):
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0)
	overlay.anchor_left = 0
	overlay.anchor_top = 0
	overlay.anchor_right = 1
	overlay.anchor_bottom = 1
	add_child(overlay)

	var label := Label.new()
	label.text = message
	label.autowrap = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_left = 0.1
	label.anchor_right = 0.9
	label.anchor_top = 0.1
	label.anchor_bottom = 0.9
	label.add_theme_font_size_override("font_size", 24)
	overlay.add_child(label)
