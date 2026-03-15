extends CharacterBody3D

# Settings
@export var max_health: float = 600.0
var current_health: float

func _ready() -> void:
	current_health = max_health
	print("Dummy initialized with ", current_health, " HP.")

# This is the function your projectile or raycast will call
func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
		
	current_health -= amount
	print("Dummy hit! Damage: ", amount, " | Remaining HP: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Dummy HP hit 0. Disappearing...")
	# You could add a particles/sound effect here before freeing
	queue_free()
