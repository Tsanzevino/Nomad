extends Node2D

@export var biomeMap : BiomeMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var genSeed = 1
	var size = 510
	biomeMap.setup(genSeed)
	var image = biomeMap.generate_image(0,0,size)
	var map = biomeMap.generate_recursive_chunk(0,0,size)
	for x in size:
		for z in size:
			if map.get_biome(x,z) != null and map.get_biome(x,z) != biomeMap.get_biome(x,z):
				image.set_pixel(x,z,Color.RED)
	%TextureRect.texture = ImageTexture.create_from_image(image)
	image.save_png("res://Testing/TestImages/biome_error_%s.png" % genSeed)
	print(map)
