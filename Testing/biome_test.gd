extends Node2D

@export var biomeMap : BiomeMap

var timeStart : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var genSeed = 5
	var radius = 16
	var size = 16 * 2 * radius
	Stopwatch.start("Total Gen")
	biomeMap.setup(genSeed)
	var image = biomeMap.generate_image(0,0,size)
	Stopwatch.start("Map Gen")
	var map = biomeMap.generate_recursive_chunk(0,0,size)
	Stopwatch.stop("Map Gen")
	Stopwatch.start("Error Checking")
	for x in size:
		for z in size:
			if map.get_biome(x,z) != null and map.get_biome(x,z) != biomeMap.get_biome(x,z):
				image.set_pixel(x,z,Color.RED)
	Stopwatch.stop("Error Checking")
	%TextureRect.texture = ImageTexture.create_from_image(image)
	image.save_png("res://Testing/TestImages/biome_error_%s.png" % genSeed)
	Stopwatch.stop("Total Gen")
