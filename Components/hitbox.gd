## Collides with hurtboxes to do damage.
## Can do negative damage to heal instead.
class_name Hitbox extends Area3D

enum DamageOperations{
		## [code]damage = damage[/code][br]
		## Destroys Hitbox when [member pierce] reaches zero
		CONSTANT,
		## [code]damage -= falloffRate[/code]
		## Where falloffRate = 1 / pierce.[br]
		## Destroys Hitbox when [member pierce] reaches zero.
		LINEAR_PIERCE,
		## [code]damage *= (1 - falloffRate)[/code]
		## Where falloffRate = 1 / pierce.[br]
		## Destroys Hitbox when [member pierce] reaches zero.
		EXPONENTIAL_PIERCE,
		## [code]damage -= falloffRate[/code][br]
		## Destroys Hitbox when [member pierce] or [member damage] reaches zero.
		LINEAR,
		## [code]damage *= (1 - falloffRate)[/code][br]
		## Destroys Hitbox when [member pierce] or [member damage] reaches zero.
		EXPONENTIAL,
		## [code]damage = (initial_damage + 1) - (initial_damage - damage) * (falloffRate)[/code][br]
		## Destroys Hitbox when [member pierce] or [member damage] reaches zero.
		INVERSE_EXPONENTIAL
	}

## The amount of damage done by the hitbox.
@export var damage : int = 0

@export var falloffRate : float = 0.0

@export var operation : DamageOperations = DamageOperations.LINEAR

var decreaseDamage : Callable = func(): damage = floor(damage - falloffRate)

## The amount of times a hitbox can collide before being destroyed.
## [member pierce] <= 0 will be practically infinite.
@export var pierce : int = 1

func _ready() -> void:
	collision_layer = 4
	collision_mask = 64
	monitoring = false
	match operation:
		DamageOperations.LINEAR_PIERCE:
			falloffRate = damage * 1.0 / pierce
			decreaseDamage = func(d : int) -> int: return floor(d - falloffRate)
		DamageOperations.EXPONENTIAL_PIERCE:
			falloffRate = (1.0 - 1.0 / pierce)
			decreaseDamage = func(d : int) -> int: return floor(d * falloffRate)
		DamageOperations.LINEAR:
			decreaseDamage = func(d : int) -> int: return floor(d - falloffRate)
		DamageOperations.EXPONENTIAL:
			falloffRate = (1.0 - falloffRate)
			decreaseDamage = func(d : int) -> int: return floor(d * falloffRate)

func deal_damage() -> int:
	pierce -= 1
	var oldDamage = damage
	damage = decreaseDamage.call(damage)
	if pierce != 0 or oldDamage != 0: return oldDamage
	queue_free()
	return 0
