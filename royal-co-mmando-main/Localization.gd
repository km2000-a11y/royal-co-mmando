#Hi
extends Node

signal language_changed

var current_language: String = "en"

func _init():
	load_language()

const LOCALIZATION := {
	"en": {
		"host_lan": "Host LAN Game",
		"join_lan": "Join LAN Game",
		"settings": "Settings",
		"res_scale": "Resolution Scale",
		"volume": "Volume",
		"sensitivity": "Sensitivity",
		"ammo": "Ammo",
		"reloading": "Reloading...",
		"fps": "FPS",
		"weapon": "Weapon",
		"cpu": "CPU",
		"gpu": "Graphics Card",
		"time_remaining": "Time Remaining",
		"enter_ip": "Enter host IP to join"
	},

	"ru": {
		"host_lan": "Создать LAN-игру",
		"join_lan": "Присоединиться к LAN-игре",
		"settings": "Настройки",
		"res_scale": "Масштаб разрешения",
		"volume": "Громкость",
		"sensitivity": "Чувствительность",
		"ammo": "Патроны",
		"reloading": "Перезарядка...",
		"fps": "Кадры в секунду",
		"weapon": "Оружие",
		"cpu": "Центральный процессор",
		"gpu": "Видеокарта",
		"time_remaining": "Оставшееся время",
		"enter_ip": "Введите IP хоста чтобы присоединиться"
	},

	"uk": {
		"host_lan": "Створити LAN-гру",
		"join_lan": "Приєднатися до LAN-гри",
		"settings": "Налаштування",
		"res_scale": "Масштаб роздільної здатності",
		"volume": "Гучність",
		"sensitivity": "Чутливість",
		"ammo": "Патрони",
		"reloading": "Перезарядження...",
		"fps": "Кадри на секунду",
		"weapon": "Зброя",
		"cpu": "Центральний процесор",
		"gpu": "Відеокарта",
		"time_remaining": "Залишок часу",
		"enter_ip": "Введіть IP хоста щоб приєднатися"
	},

	"sr": {
		"host_lan": "Покрени LAN игру",
		"join_lan": "Придружи се LAN игри",
		"settings": "Подешавања",
		"res_scale": "Скала резолуције",
		"volume": "Јачина звука",
		"sensitivity": "Осетљивост",
		"ammo": "Муниција",
		"reloading": "Пунјење...",
		"fps": "Кадрови у секунди",
		"weapon": "Оружје",
		"cpu": "Централни процесор",
		"gpu": "Графичка картица",
		"time_remaining": "Преостало време",
		"enter_ip": "Унеси IP хоста да се придружиш"
	},

	"tr": {
		"host_lan": "LAN Oyunu Kur",
		"join_lan": "LAN Oyununa Katıl",
		"settings": "Ayarlar",
		"res_scale": "Çözünürlük Ölçeği",
		"volume": "Ses",
		"sensitivity": "Hassasiyet",
		"ammo": "Mermi",
		"reloading": "Yeniden Dolduruluyor...",
		"fps": "FPS",
		"weapon": "Silah",
		"cpu": "İşlemci",
		"gpu": "Ekran Kartı",
		"time_remaining": "Kalan Süre",
		"enter_ip": "Katılmak için sunucu IP’sini gir"
	}
}


func L(key: String) -> String:
	if LOCALIZATION.has(current_language):
		if LOCALIZATION[current_language].has(key):
			return LOCALIZATION[current_language][key]
	return key

func set_language(lang: String) -> void:
	if LOCALIZATION.has(lang):
		current_language = lang
		_save_language()
		emit_signal("language_changed")

func _save_language() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("language", "current_language", current_language)
	cfg.save("user://settings.cfg")

func load_language() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		current_language = cfg.get_value("language", "current_language", "en")
