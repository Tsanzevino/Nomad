extends Node2D

@export var biomeMap : BiomeMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	biomeMap.setup(0)
	%TextureRect.texture = ImageTexture.create_from_image(biomeMap.generate_image(Vector3(0,0,0),128))
