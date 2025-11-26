class_name Player extends CharacterBody3D


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
