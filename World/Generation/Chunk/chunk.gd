class_name Chunk extends MeshInstance3D

static var size : int = 32

func _init():
	material_override = preload("res://Data/Shaders/biome_shader.tres")
