extends Label

var current_weapon: Node3D = null

func _ready():
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
		# Connect Ammo Signal
		if not current_weapon.ammo_changed.is_connected(_on_ammo_updated):
			current_weapon.ammo_changed.connect(_on_ammo_updated)
		
		# Connect Reload Signal (NEW)
		if current_weapon.has_signal("reload_status_changed"):
			if not current_weapon.reload_status_changed.is_connected(_on_reload_status_changed):
				current_weapon.reload_status_changed.connect(_on_reload_status_changed)
		
		_on_ammo_updated(current_weapon.current_ammo, current_weapon.reserve_ammo)
	else:
		text = "MELEE"

func _on_ammo_updated(current: int, reserve: int):
	# Only update ammo text if we aren't currently reloading
	text = "AMMO: " + str(current) + " / " + str(reserve)

# NEW: This handles the "RELOADING..." text
func _on_reload_status_changed(is_reloading: bool):
	if is_reloading:
		text = "RELOADING..."
	else:
		# When done reloading, show the new ammo counts
		if is_instance_valid(current_weapon):
			_on_ammo_updated(current_weapon.current_ammo, current_weapon.reserve_ammo)

func _process(_delta):
	if not is_instance_valid(current_weapon):
		update_weapon_connection()
