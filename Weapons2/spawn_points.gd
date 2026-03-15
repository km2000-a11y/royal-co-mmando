extends Node3D

@onready var guard_spawn = $SpawnPoints/GuardSpawn
@onready var gangster_spawn = $SpawnPoints/GangsterSpawn

func spawn_player(peer_id: int) -> void:
	var player_scene: PackedScene = preload("res://Weapons2/player.tscn")
	var player: Node3D = player_scene.instantiate()

	# Name for debugging
	player.name = "Player_%d" % peer_id

	# SERVER decides roles & spawn points
	if peer_id == 1:
		player.global_transform = guard_spawn.global_transform
		player.role = "Guard"
	else:
		player.global_transform = gangster_spawn.global_transform
		player.role = "Gangster"

	# Authority must match the peer
	player.set_multiplayer_authority(peer_id)

	# Add as networked child (server only, replicated to clients)
	add_child(player, true)

	print("SPAWNED:", player.name, "ROLE:", player.role, "AUTH:", player.get_multiplayer_authority())
