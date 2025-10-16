class_name Hitbox extends Area3D

## Does the "Hitting".
## Collides with hurtboxes to do damage.
## Can do negative damage to heal instead.

@export var damage : int = 0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 64
	monitoring = false
