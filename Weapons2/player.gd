extends CharacterBody3D

# ---------------------------------------------------------
# MOVEMENT SETTINGS
# ---------------------------------------------------------
const WALK_SPEED := 5.0
const SPRINT_SPEED := 8.0
const JUMP_VELOCITY := 4.5

var mouse_sens := 0.01
var controller_sens := 2.5

# ---------------------------------------------------------
# PLAYER STATE
# ---------------------------------------------------------
@export var hp := 180
@export var yaw := 0.0
@export var pitch := 0.0
@export var role := ""

@export var sync_position: Vector3
@export var sync_rotation: Vector3
@export var weapon_index := 0

var is_local := false
var is_paused := false

# ---------------------------------------------------------
# NODE REFERENCES
# ---------------------------------------------------------
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var weapon_anchor = $CameraPivot/Camera3D/WeaponHolder/WeaponAnchor

@onready var settings_menu := get_tree().root.get_node("Main/SettingsMenu")

# ---------------------------------------------------------
# WEAPON POOL
# ---------------------------------------------------------
var weapon_pool: Array[PackedScene] = [
	preload("res://Weapons2/g18.tscn"),
	preload("res://Weapons2/desert eagle.tscn"),
	preload("res://Weapons2/usp45.tscn"),
	preload("res://Weapons2/p250.tscn"),
	preload("res://Weapons2/five seven.tscn"),
	preload("res://Weapons2/makarov.tscn"),

	preload("res://Weapons2/m3a1 grease gun.tscn"),
	preload("res://Weapons2/mac10.tscn"),
	preload("res://Weapons2/p90.tscn"),
	preload("res://Weapons2/mp5.tscn"),

	preload("res://Weapons2/akm.tscn"),
	preload("res://Weapons2/m4a1.tscn"),
	preload("res://Weapons2/g36.tscn"),
	preload("res://Weapons2/aug a1.tscn"),
	preload("res://Weapons2/scar l.tscn"),
	preload("res://Weapons2/vhs d.tscn"),
	preload("res://Weapons2/ak4.tscn"),
	preload("res://Weapons2/scout 556.tscn"),
	preload("res://Weapons2/awm.tscn"),

	preload("res://Weapons2/negev lmg.tscn"),
	preload("res://Weapons2/rpk.tscn"),

	preload("res://Weapons2/spas12.tscn"),
	preload("res://Weapons2/sawed off.tscn")
]

# ---------------------------------------------------------
# LIFECYCLE
# ---------------------------------------------------------
func _enter_tree():
	print("PLAYER ENTERED TREE:", name, " AUTH:", get_multiplayer_authority())

func _ready():
	is_local = is_multiplayer_authority()
	print("PLAYER READY:", name, " LOCAL:", is_local, " AUTH:", get_multiplayer_authority())

	camera.current = is_local

	if is_local:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		weapon_index = randi() % weapon_pool.size()

	await get_tree().process_frame
	_spawn_weapon_from_index()

# ---------------------------------------------------------
# PAUSE MENU
# ---------------------------------------------------------
func _toggle_pause() -> void:
	is_paused = not is_paused

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		settings_menu.show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		settings_menu.hide()

# ---------------------------------------------------------
# INPUT
# ---------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not is_local:
		return

	if event.is_action_pressed("pause_menu"):
		_toggle_pause()
		return

	if is_paused:
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sens
		pitch -= event.relative.y * mouse_sens
		pitch = clamp(pitch, deg_to_rad(-40), deg_to_rad(60))

		camera_pivot.rotation.y = yaw
		camera.rotation.x = pitch

# ---------------------------------------------------------
# PHYSICS
# ---------------------------------------------------------
func _physics_process(delta: float) -> void:
	if is_paused:
		return

	if is_local:
		_handle_look_controller(delta)
		_handle_movement(delta)
		_check_death()

		move_and_slide()

		sync_position = global_transform.origin
		sync_rotation = rotation
	else:
		global_transform.origin = sync_position
		rotation = sync_rotation

# ---------------------------------------------------------
# CONTROLLER LOOK
# ---------------------------------------------------------
func _handle_look_controller(delta: float):
	if not is_local or is_paused:
		return

	var joy := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joy.length() > 0.1:
		yaw -= joy.x * controller_sens * delta
		pitch -= joy.y * controller_sens * delta
		pitch = clamp(pitch, deg_to_rad(-40), deg_to_rad(60))

		camera_pivot.rotation.y = yaw
		camera.rotation.x = pitch

# ---------------------------------------------------------
# MOVEMENT
# ---------------------------------------------------------
func _handle_movement(delta: float):
	if not is_local or is_paused:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction: Vector3 = (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var speed := WALK_SPEED
	if Input.is_action_pressed("sprint") and input_dir.y < -0.1:
		speed = SPRINT_SPEED

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)

# ---------------------------------------------------------
# DEATH
# ---------------------------------------------------------
func _check_death():
	if hp <= 0:
		_respawn()

func _respawn():
	get_tree().quit()

# ---------------------------------------------------------
# WEAPON HANDLING
# ---------------------------------------------------------
func _spawn_weapon_from_index():
	if weapon_index < 0 or weapon_index >= weapon_pool.size():
		return

	var weapon_scene := weapon_pool[weapon_index]
	receive_weapon(weapon_scene)

func receive_weapon(weapon_scene: PackedScene):
	if weapon_anchor == null:
		return

	# Remove old weapon
	for c in weapon_anchor.get_children():
		c.queue_free()

	# Spawn new weapon
	var weapon = weapon_scene.instantiate()
	weapon_anchor.add_child(weapon)
	weapon.global_transform = weapon_anchor.global_transform

	# -----------------------------------------------------
	# HUD UPDATE: Weapon Name
	# -----------------------------------------------------
	var ui = get_tree().get_nodes_in_group("weapon_name_ui")
	if ui.size() > 0:
		ui[0].set_weapon_name(weapon.NAME)
