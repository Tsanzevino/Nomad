class_name Player extends CharacterBody3D

func _ready() -> void:
	pass

#region Component Utilities
func get_forward() -> Vector3:
	var camForward : Vector3 = -%ThirdPersonCamera.global_basis.z
	if (%ThirdPersonCamera.spring_length == 0.0):
		return camForward
	else:
		# Correct this to account for pivot
		return camForward

func get_camera():
	return %ThirdPersonCamera

func get_pivot():
	return %Pivot
#endregion

func collect_item(item : Item, amount : int) -> int:
	return %InventoryManager.collect_item(item,amount)

func _on_health_healed() -> void:
	pass # Replace with function body.

func _on_health_full_healed() -> void:
	pass # Replace with function body.

func _on_health_damaged() -> void:
	print(%Health.health)

func _on_health_died() -> void:
	pass # Replace with function body.
