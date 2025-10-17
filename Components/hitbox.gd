## Collides with hurtboxes to do damage.
## Can do negative damage to heal instead.
class_name Hitbox extends Area3D

enum FalloffOperations{
		## [code]damage -= falloffRate[/code]
		LINEAR, 
		## [code]damage *= (1 - falloffRate)[/code]
		SQUARED
	}

## The amount of damage done by the hitbox.
@export var damage : int = 0

@export var falloffRate : float = 0.0

@export var falloffOperation : FalloffOperations = FalloffOperations.LINEAR

## The amount of times a hitbox can collide before being destroyed.
## [member pierce] <= 0 will be practically infinite.
@export var pierce : int = 1

func _ready() -> void:
	collision_layer = 4
	collision_mask = 64
	monitoring = false

func use_pierce():
	pierce -= 1
	if pierce != 0: return
	queue_free()
