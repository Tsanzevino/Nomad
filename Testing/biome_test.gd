extends Node3D

var timeStart : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var genSeed = 1
	WorldGenerator.biomeMap.setup(genSeed)
	WorldGenerator.heightMap.setup(genSeed)
	var size = 1024
	Stopwatch.start("Total Gen")
	var image = WorldGenerator.biomeMap.generate_image(-((size - 1) / 2),-((size - 1) / 2),size)
	image.save_png("res://Testing/TestImages/biome_compare_%s.png" % genSeed)
	Stopwatch.stop("Total Gen")
	
	Stopwatch.start("Region")
	var region = Region.new(Vector2i(0,0))
	var biomeImage = region.biomeMapChunk.generate_image()
	print("first access complete")
	var heightImage = region.heightMapChunk.generate_image()
	biomeImage.save_png("res://Testing/TestImages/region_biome_%s.png" % genSeed)
	heightImage.save_png("res://Testing/TestImages/region_height_%s.png" % genSeed)
	%MeshInstance3D.material_override.albedo_texture = ImageTexture.create_from_image(biomeImage)
	%MeshInstance3D.material_override.heightmap_texture = ImageTexture.create_from_image(heightImage)
	Stopwatch.stop("Region")
