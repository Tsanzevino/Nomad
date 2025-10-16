class_name Hurtbox extends Area3D

## Does the "hurting".
## Detects collisions with hitboxes and applies damage or heals.

## Signal emitted when hurt
signal hurt(amount : int)
## Signal emitted when healed
signal heal(amount : int)

func _ready() -> void:
	collision_layer = 64
	collision_mask = 4
	monitorable = false
	area_entered.connect(_on_area_entered)

## Hits the Hurtbox for [param damage], healing if [param damage] is negative.
func hit(damage : int) -> void:
	if damage > 0: hurt.emit(damage)
	else: heal.emit(-damage)

func _on_area_entered(area : Area3D):
	#if area.owner == owner: return
	if area is Hitbox:
		hit(area.damage)
