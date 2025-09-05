class_name VisualInteractable extends Interactable

@export var inactiveMat : StandardMaterial3D
@export var activeMat : StandardMaterial3D
@export var targettedMat : StandardMaterial3D

func set_active():
	(get_parent() as GeometryInstance3D).material_override = activeMat

func set_targetted():
	(get_parent() as GeometryInstance3D).material_override = targettedMat

func set_inactive():
	(get_parent() as GeometryInstance3D).material_override = inactiveMat
