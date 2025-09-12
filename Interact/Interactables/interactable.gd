class_name Interactable extends Area3D

func _enter_tree():
	add_to_group("Interactables")
	collision_layer = 128
	collision_mask = 8

func interact():
	print("I was interacted with!")

func set_active():
	pass

func set_targetted():
	pass

func set_inactive():
	pass
