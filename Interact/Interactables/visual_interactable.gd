class_name VisualInteractable extends Interactable

@export var inactiveMat : StandardMaterial3D
@export var activeMat : StandardMaterial3D
@export var targettedMat : StandardMaterial3D

func set_active():
	for child in get_children():
		if child is GeometryInstance3D:
			child.material_override = activeMat

func set_targetted():
	for child in get_children():
		if child is GeometryInstance3D:
			child.material_override = targettedMat

func set_inactive():
	for child in get_children():
		if child is GeometryInstance3D:
			child.material_override = inactiveMat
