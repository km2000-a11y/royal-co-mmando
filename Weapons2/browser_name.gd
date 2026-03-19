extends Label

func _ready():
	# Prevent calling JS in the editor or native builds
	if not OS.has_feature("web"):
		text = "Browser: (Not running in Web)"
		return

	var js = """
	(() => {
		const ua = navigator.userAgent || "";

		// --- iOS browsers ---
		if (ua.includes("CriOS")) return "Chrome (iOS)";
		if (ua.includes("FxiOS")) return "Firefox (iOS)";
		if (ua.includes("EdgiOS")) return "Edge (iOS)";
		if (ua.includes("OPiOS")) return "Opera (iOS)";

		// --- Samsung Internet ---
		if (ua.includes("SamsungBrowser")) return "Samsung Internet";

		// --- Opera ---
		if (ua.includes("OPR") || ua.includes("Opera")) return "Opera";

		// --- Edge ---
		if (ua.includes("Edg")) return "Microsoft Edge";

		// --- Brave ---
		if (typeof navigator.brave !== "undefined") return "Brave";

		// --- Vivaldi ---
		if (ua.includes("Vivaldi")) return "Vivaldi";

		// --- DuckDuckGo ---
		if (ua.includes("DuckDuckGo")) return "DuckDuckGo Browser";

		// --- UC Browser ---
		if (ua.includes("UCBrowser")) return "UC Browser";

		// --- Firefox ---
		if (ua.includes("Firefox")) return "Firefox";

		// --- Chrome ---
		if (ua.includes("Chrome")) return "Chrome";

		// --- Safari ---
		if (ua.includes("Safari")) return "Safari";

		return "Unknown Browser";
	})()
	"""

	var browser: String = JavaScriptBridge.eval(js)
	text = "Browser: %s" % browser
