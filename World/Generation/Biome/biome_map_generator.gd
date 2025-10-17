class_name BiomeMapGenerator extends Resource

@export var temperature : FastNoiseLite
@export var humidity : FastNoiseLite
@export var continentalness : FastNoiseLite

@export var biomes : Array[Biome]

func set_seed(biomeSeed : int):
	temperature.seed = biomeSeed
	humidity.seed = biomeSeed
	continentalness.seed = biomeSeed

func generate(noiseOffset : Vector3) -> BiomeMap:
	var biomeMap : BiomeMap = BiomeMap.new()
	temperature.offset = noiseOffset
	humidity.offset = noiseOffset
	continentalness.offset = noiseOffset
	var finalImage = Image.create_empty(1080,1080,false,Image.FORMAT_RGB8)
	for x in 1080:
		for z in 1080:
			var r = temperature.get_noise_2d(x,z)
			var b = humidity.get_noise_2d(x,z)
			var g = continentalness.get_noise_2d(x,z)
			finalImage.set_pixel(x,z, Color(r,g,b))
	#finalImage.save_png("res://TestImages/full.png")
	return biomeMap
