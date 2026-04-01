extends Label

func _ready():
	# Prevent calling JS in the editor or native builds
	if not OS.has_feature("web"):
		text = "Browser: (Not running in Web)"
		return

	var js = """
	(() => {
		const ua = navigator.userAgent || "";
		const isIOS = /iPhone|iPad|iPod/.test(ua);
		const isWebKit = /WebKit/.test(ua) && !/Chrome/.test(ua);

		// --- Safari (macOS) ---
		if (!isIOS && ua.includes("Safari") && !ua.includes("Chrome"))
			return "Safari";

		// --- iOS Browsers (all WebKit-based) ---

		// Chrome on iOS
		if (isIOS && ua.includes("CriOS"))
			return "Chrome (iOS)";

		// Firefox on iOS
		if (isIOS && ua.includes("FxiOS"))
			return "Firefox (iOS)";

		// Edge on iOS
		if (isIOS && ua.includes("EdgiOS"))
			return "Microsoft Edge (iOS)";

		// Brave on iOS
		if (isIOS && ua.includes("Brave"))
			return "Brave (iOS)";

		// DuckDuckGo on iOS
		if (isIOS && ua.includes("DuckDuckGo"))
			return "DuckDuckGo Browser (iOS)";

		// Generic iOS WebKit fallback
		if (isIOS && isWebKit)
			return "Safari (iOS)";

		// --- Samsung Internet ---
		if (ua.includes("SamsungBrowser")) return "Samsung Internet";

		// --- Opera ---
		if (ua.includes("OPR") || ua.includes("Opera")) return "Opera";

		// --- Edge (desktop) ---
		if (ua.includes("Edg")) return "Microsoft Edge";

		// --- Brave (desktop) ---
		if (typeof navigator.brave !== "undefined") return "Brave";

		// --- Vivaldi ---
		if (ua.includes("Vivaldi")) return "Vivaldi";

		// --- DuckDuckGo (desktop) ---
		if (ua.includes("DuckDuckGo")) return "DuckDuckGo Browser";

		// --- UC Browser ---
		if (ua.includes("UCBrowser")) return "UC Browser";

		// --- Firefox ---
		if (ua.includes("Firefox")) return "Firefox";

		// --- Chrome ---
		if (ua.includes("Chrome")) return "Chrome";

		return "Unknown Browser";
	})()
	"""

	var browser: String = JavaScriptBridge.eval(js)
	text = "Browser: %s" % browser
