extends Node3D

# --- Knife Stats ---
@export_group("Melee")
@export var DAMAGE := 50
@export var RANGE := 2.0
@export var COOLDOWN := 0.4
@export var AMMO := "MELEE"

@export_group("Other")
@export var NAME := "Knife"

# --- Internal State ---
var can_attack := true
var cam: Camera3D
var player_body: CharacterBody3D
var base_mesh_pos := Vector3.ZERO

# --- Node References ---
@onready var mesh: Node3D = $MeshInstance3D
@onready var swing_sfx: AudioStreamPlayer3D = get_node_or_null("SwingPlayer")

func _ready():
	await get_tree().process_frame
	cam = get_viewport().get_camera_3d()

	var p = get_parent()
	while p:
		if p is CharacterBody3D:
			player_body = p
			break
		p = p.get_parent()

	if mesh:
		base_mesh_pos = mesh.position

func _process(delta):
	if not is_visible_in_tree():
		return

	if Input.is_action_just_pressed("melee_attack") and can_attack:
		perform_attack()

	if mesh:
		mesh.position = mesh.position.lerp(base_mesh_pos, 12.0 * delta)

func perform_attack():
	can_attack = false

	if swing_sfx:
		swing_sfx.play()

	if mesh:
		mesh.position.z -= 0.35

	_do_raycast()

	await get_tree().create_timer(COOLDOWN).timeout
	can_attack = true

func _do_raycast():
	if not cam:
		return

	var start = cam.global_position
	var end = start + (-cam.global_transform.basis.z * RANGE)

	var query = PhysicsRayQueryParameters3D.create(start, end)
	if player_body:
		query.exclude = [player_body.get_rid()]

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result and result.collider.has_method("take_damage"):
		result.collider.take_damage(DAMAGE)
