class_name BiomeMapGenerator extends Resource

@export var temperature : FastNoiseLite
@export var humidity : FastNoiseLite
@export var continentalness : FastNoiseLite

@export var lookupTable : BiomeLookupTable
var imageSize : int = 1920

func set_seed(biomeSeed : int):
	temperature.seed = biomeSeed
	humidity.seed = biomeSeed
	continentalness.seed = biomeSeed

func generate(noiseOffset : Vector3) -> BiomeMap:
	var biomeMap : BiomeMap = BiomeMap.new()
	temperature.offset = noiseOffset
	humidity.offset = noiseOffset
	continentalness.offset = noiseOffset
	var finalImage = Image.create_empty(imageSize,imageSize,false,Image.FORMAT_RGB8)
	var rawImage = Image.create_empty(imageSize,imageSize,false,Image.FORMAT_RGB8)
	for x in imageSize:
		for z in imageSize:
			var r = (temperature.get_noise_2d(x,z) + 1.0) / 2.0
			var g = (humidity.get_noise_2d(x,z) + 1.0) / 2.0
			var b = (continentalness.get_noise_2d(x,z) + 1.0) / 2.0
			rawImage.set_pixel(x,z, Color(r,b,g))
			finalImage.set_pixel(x,z, lookupTable.lookup(r,g,b).biomeColor)
	rawImage.save_png("res://TestImages/raw.png")
	finalImage.save_png("res://TestImages/biomes.png")
	print("Done!")
	return biomeMap

func blend(image : Image, radius : int = 1)-> Image:
	var newImage = Image.create_empty(imageSize,imageSize, false, Image.FORMAT_RGB8)
	var temp : Array[Array]
	temp.resize(imageSize)
	for x in imageSize:
		temp[x].resize(imageSize)
		for z in imageSize:
			temp[x][z] = Vector3.ZERO
	for x in imageSize:
		for z in imageSize:
			var c = image.get_pixel(x,z)
			var v = Vector3(c.r,c.g,c.b)
			for i in range(-radius, radius):
				for j in range(-radius, radius):
					if x + i < 0 or z + j < 0 or x + i >= imageSize or z + j >= imageSize: continue
					temp[x + i][z + j] = temp[x + i][z + j] + v
	for x in imageSize:
		for z in imageSize:
			var v : Vector3 = temp[x][z]
			v = v / (radius * radius)
			newImage.set_pixel(x,z,Color(v.x,v.y,v.z))
	return newImage
