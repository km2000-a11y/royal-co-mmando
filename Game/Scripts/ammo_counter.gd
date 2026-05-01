extends Label

var current_weapon: Node3D = null

func _ready():
	Localization.language_changed.connect(_update_text)
	await get_tree().create_timer(0.1).timeout
	update_weapon_connection()

func update_weapon_connection():
	current_weapon = null
	var all_weapons = get_tree().get_nodes_in_group("weapon")
	
	for node in all_weapons:
		if node is Node3D and "current_ammo" in node:
			current_weapon = node
			break
	
	if current_weapon:
		if not current_weapon.ammo_changed.is_connected(_on_ammo_updated):
			current_weapon.ammo_changed.connect(_on_ammo_updated)
		
		if current_weapon.has_signal("reload_status_changed"):
			if not current_weapon.reload_status_changed.is_connected(_on_reload_status_changed):
				current_weapon.reload_status_changed.connect(_on_reload_status_changed)
		
		_update_text()
	else:
		text = "MELEE"  # do NOT localize

func _update_text():
	if is_instance_valid(current_weapon):
		_on_ammo_updated(current_weapon.current_ammo, current_weapon.reserve_ammo)

func _on_ammo_updated(current: int, reserve: int):
	text = Localization.L("ammo") + ": " + str(current) + " / " + str(reserve)

func _on_reload_status_changed(is_reloading: bool):
	if is_reloading:
		text = Localization.L("reloading")
	else:
		_update_text()

func _process(_delta):
	if not is_instance_valid(current_weapon):
		update_weapon_connection()
