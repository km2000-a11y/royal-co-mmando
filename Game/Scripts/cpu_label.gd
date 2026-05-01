extends Label

func _ready() -> void:
	Localization.language_changed.connect(_update_text)
	_update_text()

func _update_text():
	text = Localization.L("cpu") + ": " + get_cpu_name()

func get_cpu_name() -> String:
	var os := OS.get_name()

	if os == "Windows":
		return _win()
	elif os == "Linux":
		return _linux()
	elif os == "macOS":
		return _mac()
	else:
		return "Unknown CPU"

func _win() -> String:
	var out := []
	OS.execute("wmic", ["cpu", "get", "name"], out, true)
	if out.size() > 0:
		return out[0].replace("Name", "").strip_edges()
	return "Unknown CPU"

func _linux() -> String:
	var out := []
	OS.execute("cat", ["/proc/cpuinfo"], out, true)
	if out.size() > 0:
		for line in out[0].split("\n"):
			if line.begins_with("model name"):
				return line.split(":")[1].strip_edges()
	return "Unknown CPU"

func _mac() -> String:
	var out := []
	OS.execute("sysctl", ["-n", "machdep.cpu.brand_string"], out, true)
	if out.size() > 0:
		return out[0].strip_edges()
	return "Unknown CPU"
