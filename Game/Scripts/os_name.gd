extends Label

func _ready():
	# Prevent JS from running outside the browser
	if not OS.has_feature("web"):
		text = "Platform: (Not Web)"
		return

	var js = """
	(() => {
		const ua = navigator.userAgent || "";

		// --- iOS ---
		if (ua.includes("iPhone")) return "iOS (iPhone)";
		if (ua.includes("iPad")) return "iOS (iPad)";
		if (ua.includes("iPod")) return "iOS (iPod)";

		// --- Android ---
		if (ua.includes("Android")) return "Android";

		// --- ChromeOS ---
		if (ua.includes("CrOS")) return "ChromeOS";

		// --- Windows ---
		if (ua.includes("Windows NT")) return "Windows";

		// --- macOS ---
		if (ua.includes("Macintosh")) return "macOS";

		// --- Linux (after Android) ---
		if (ua.includes("Linux")) return "Linux";

		return "Unknown Platform";
	})()
	"""

	var result = JavaScriptBridge.eval(js)

	# Guarantee the value is ALWAYS a string
	var platform: String = result if typeof(result) == TYPE_STRING else "Unknown Platform"

	text = "Platform: %s" % platform
