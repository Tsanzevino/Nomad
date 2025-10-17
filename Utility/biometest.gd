extends Node3D

@export var biomeMapGenerator : BiomeMapGenerator

func _ready():
	print("starting")
	var start = Time.get_ticks_msec()
	biomeMapGenerator.generate(Vector3(0,0,0))
	print(Time.get_ticks_msec() - start)
