extends Node

const MIN_THREADS := 4
const MIN_RAM_GB := 8

# The ONLY allowed 2-core / 2-thread CPU
const ALLOWED_2C2T_CPU := "Intel(R) Celeron(R) G6900"

const BLOCKED_GPUS := [
	"Intel(R) HD Graphics 2000",
	"Intel(R) HD Graphics 2500",
	"Intel(R) HD Graphics 3000",
	"Intel(R) HD Graphics 4000",
	"Intel(R) HD Graphics 4400",
	"Intel(R) HD Graphics 4600",

	"GeForce 210",
	"GeForce 310",
	"GeForce GT 610",
	"GeForce GT 620",
	"GeForce GT 630",
	"GeForce GT 710",

	"Radeon HD 5450",
	"Radeon HD 6450",
	"Radeon HD 7350",
	"Radeon HD 8350"
]

@onready var warner: Label = $HardwareWarner/Label


func _ready():
	if not _hardware_ok():
		_show_block_message()
		return

	get_tree().change_scene_to_file("res://main.tscn")


func _hardware_ok() -> bool:
	var threads: int = OS.get_processor_count()

	# --- CPU THREAD CHECK WITH G6900 EXCEPTION ---
	if threads < MIN_THREADS:
		var cpu_name := OS.get_processor_name()

		# Allow ONLY the G6900 if it's 2/2
		if cpu_name.findn(ALLOWED_2C2T_CPU) != -1:
			# G6900 is allowed even though it's 2/2
			pass
		else:
			return false

	# --- RAM CHECK ---
	var mem_info := OS.get_memory_info()
	var ram_gb: float = float(mem_info.physical) / (1024.0 * 1024.0 * 1024.0)
	if ram_gb < MIN_RAM_GB:
		return false

	# --- GPU CHECK ---
	var gpu_name: String = RenderingServer.get_video_adapter_name()
	for bad in BLOCKED_GPUS:
		if gpu_name.findn(bad) != -1:
			return false

	return true


func _show_block_message():
	var scene: PackedScene = load("res://Game/Scenes/hardware_warner.tscn")
	var inst: CanvasLayer = scene.instantiate()

	get_tree().root.add_child(inst)

	warner = inst.warner
	warner.text = Localization.L("UNSUPPORTED_HARDWARE_MESSAGE")

	get_tree().paused = true
	
