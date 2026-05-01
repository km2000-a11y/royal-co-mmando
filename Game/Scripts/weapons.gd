extends Node3D

# ---------------------------------------------------------
#  WEAPON DATA
# ---------------------------------------------------------
@export_group("Ballistics")
@export var DAMAGE := 60
@export var RANGE := 200.0
@export var FIRE_RATE_RPM := 680.0

@export_group("Ammo")
@export var MAG_SIZE := 30
@export var RESERVE_MAX := 210
@export var RELOAD_TIME := 3.0

@export_group("Recoil & Feel")
@export var RECOIL_UP := 0.3
@export var RECOIL_SIDE := 0.08
@export var KICKBACK := 0.04
@export var KICK_RETURN := 18.0

@export_group("Other")
@export var NAME := "Weapon"
@export var COUNTRY_OF_ORIGIN := ""

# ---------------------------------------------------------
#  SIGNALS
# ---------------------------------------------------------
signal ammo_changed(current, reserve)
signal reload_status_changed(reloading)

# ---------------------------------------------------------
#  INTERNAL STATE
# ---------------------------------------------------------
var current_ammo: int
var reserve_ammo: int
var is_reloading := false
var time_since_last_shot := 0.0
var base_mesh_pos := Vector3.ZERO

# ---------------------------------------------------------
#  NODE REFERENCES
# ---------------------------------------------------------
var cam: Camera3D
var player_body: CharacterBody3D

@onready var mesh: Node3D = $MeshInstance3D
@onready var gunshot: AudioStreamPlayer3D = get_node_or_null("AudioStreamPlayer3D")
@onready var reload_sfx: AudioStreamPlayer3D = get_node_or_null("ReloadPlayer")
@onready var muzzle: Node3D = get_node_or_null("Node3D")

# ---------------------------------------------------------
#  READY
# ---------------------------------------------------------
func _ready():
	current_ammo = MAG_SIZE
	reserve_ammo = RESERVE_MAX

	await get_tree().process_frame
	cam = get_viewport().get_camera_3d()

	# Find the player this weapon belongs to
	var p = get_parent()
	while p:
		if p is CharacterBody3D:
			player_body = p
			break
		p = p.get_parent()

	if mesh:
		base_mesh_pos = mesh.position

	ammo_changed.emit(current_ammo, reserve_ammo)

# ---------------------------------------------------------
#  PROCESS LOOP
# ---------------------------------------------------------
func _process(delta):
	if not is_visible_in_tree():
		return

	# BLOCK ALL SHOOTING WHILE MENU IS OPEN
	if player_body and not player_body.can_shoot():
		return

	# Fire rate cooldown
	if time_since_last_shot > 0:
		time_since_last_shot -= delta

	# Input
	if Input.is_action_pressed("shoot"):
		try_fire()

	if Input.is_action_just_pressed("reload"):
		reload()

	# Recoil return
	if mesh:
		mesh.position = mesh.position.lerp(base_mesh_pos, KICK_RETURN * delta)

# ---------------------------------------------------------
#  FIRE LOGIC
# ---------------------------------------------------------
func try_fire():
	# BLOCK SHOOTING WHILE MENU IS OPEN
	if player_body and not player_body.can_shoot():
		return

	if is_reloading or time_since_last_shot > 0:
		return

	if current_ammo > 0:
		fire()
	elif reserve_ammo > 0:
		reload()

func fire():
	time_since_last_shot = 60.0 / FIRE_RATE_RPM
	current_ammo -= 1

	if gunshot:
		gunshot.pitch_scale = 1.0
		gunshot.play()

	ammo_changed.emit(current_ammo, reserve_ammo)

	_perform_raycast_logic(RANGE, DAMAGE)
	apply_recoil()

# ---------------------------------------------------------
#  RAYCAST
# ---------------------------------------------------------
func _perform_raycast_logic(ray_range: float, ray_damage: int):
	if not cam:
		return

	var space_state = get_world_3d().direct_space_state
	var start = cam.global_position
	var end = start + (-cam.global_transform.basis.z * ray_range)

	var query = PhysicsRayQueryParameters3D.create(start, end)
	if player_body:
		query.exclude = [player_body.get_rid()]

	var result = space_state.intersect_ray(query)

	if result:
		if result.collider.has_method("take_damage"):
			result.collider.take_damage(ray_damage)
		create_tracer(result.position)
	else:
		create_tracer(end)

# ---------------------------------------------------------
#  TRACER
# ---------------------------------------------------------
func create_tracer(target_pos: Vector3):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.9, 0.5)

	get_tree().root.add_child(mesh_instance)

	var start_pos = muzzle.global_position if muzzle else global_position

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(start_pos)
	immediate_mesh.surface_add_vertex(target_pos)
	immediate_mesh.surface_end()

	await get_tree().create_timer(0.05).timeout
	mesh_instance.queue_free()

# ---------------------------------------------------------
#  RECOIL
# ---------------------------------------------------------
func apply_recoil():
	if cam:
		cam.rotation_degrees.x += RECOIL_UP
		cam.rotation_degrees.y += randf_range(-RECOIL_SIDE, RECOIL_SIDE)

	if mesh:
		mesh.position.z += KICKBACK

# ---------------------------------------------------------
#  RELOAD
# ---------------------------------------------------------
func reload():
	if is_reloading or current_ammo == MAG_SIZE or reserve_ammo <= 0:
		return

	is_reloading = true

	if reload_sfx:
		reload_sfx.play()

	reload_status_changed.emit(true)

	await get_tree().create_timer(RELOAD_TIME).timeout

	var needed = MAG_SIZE - current_ammo
	var taken = min(needed, reserve_ammo)

	current_ammo += taken
	reserve_ammo -= taken

	is_reloading = false
	reload_status_changed.emit(false)
	ammo_changed.emit(current_ammo, reserve_ammo)
