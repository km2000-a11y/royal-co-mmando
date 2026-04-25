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
		"enter_ip": "Enter host IP to join",
		"UNSUPPORTED_HARDWARE_MESSAGE": "Your system does not meet the minimum requirements to run Royal Commando.\n\nRequired:\n- CPU with at least 2 cores / 4 threads\n- At least 8 GB RAM\n- GPU with at least 1 GB VRAM or an iGPU capable of allocating 1 GB shared memory\n\nThe game cannot start on this hardware."
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
		"enter_ip": "Введите IP хоста чтобы присоединиться",
		"UNSUPPORTED_HARDWARE_MESSAGE": "Ваша система не соответствует минимальным требованиям для запуска Royal Commando.\n\nТребуется:\n- Процессор с минимум 2 ядрами / 4 потоками\n- Не менее 8 ГБ ОЗУ\n- Видеокарта с 1 ГБ VRAM или iGPU, способная выделить 1 ГБ общей памяти\n\nИгра не может быть запущена на этом оборудовании."
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
		"enter_ip": "Введіть IP хоста щоб приєднатися",
		"UNSUPPORTED_HARDWARE_MESSAGE": "Ваша система не відповідає мінімальним вимогам для запуску Royal Commando.\n\nПотрібно:\n- Процесор з мінімум 2 ядрами / 4 потоками\n- Щонайменше 8 ГБ оперативної пам’яті\n- Відеокарта з 1 ГБ VRAM або iGPU, здатна виділити 1 ГБ спільної пам’яті\n\nГру неможливо запустити на цьому обладнанні."
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
		"enter_ip": "Унеси IP хоста да се придружиш",
		"UNSUPPORTED_HARDWARE_MESSAGE": "Ваш систем не испуњава минималне захтеве за покретање Royal Commando.\n\nПотребно:\n- Процесор са најмање 2 језгра / 4 нити\n- Најмање 8 GB RAM-а\n- Графичка картица са 1 GB VRAM-а или iGPU који може да издвоји 1 GB дељене меморије\n\nИгра не може да се покрене на овом хардверу."
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
		"enter_ip": "Katılmak için sunucu IP’sini gir",
		"UNSUPPORTED_HARDWARE_MESSAGE": "Sisteminiz Royal Commando’yu çalıştırmak için gereken minimum özellikleri karşılamıyor.\n\nGereksinimler:\n- En az 2 çekirdek / 4 iş parçacıklı işlemci\n- En az 8 GB RAM\n- En az 1 GB VRAM’e sahip ekran kartı veya 1 GB paylaşımlı belleği ayırabilen bir iGPU\n\nOyun bu donanımda başlatılamaz."
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
