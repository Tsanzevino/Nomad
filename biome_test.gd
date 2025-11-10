extends Node3D

@export var biomeMapGen : BiomeMapGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	biomeMapGen.lookupTable.load_from_csv()
	biomeMapGen.generate(Vector3(0,0,0))
