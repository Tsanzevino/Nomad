class_name BiomeMapGenerator extends Resource

@export var temperature : NoiseComponent
@export var humidity : NoiseComponent
@export var continentalness : NoiseComponent

@export var lookupTable : BiomeLookupTable
var imageSize : int = 2080

func set_seed(biomeSeed : int):
	temperature.set_seed(biomeSeed)
	humidity.set_seed(biomeSeed)
	continentalness.set_seed(biomeSeed)

func generate(noiseOffset : Vector3) -> Image:
	var biomeMap : BiomeMap = BiomeMap.new()
	temperature.noise.offset = noiseOffset
	humidity.noise.offset = noiseOffset
	continentalness.noise.offset = noiseOffset
	var finalImage = Image.create_empty(imageSize,imageSize,false,Image.FORMAT_RGB8)
	var rawImage = Image.create_empty(imageSize,imageSize,false,Image.FORMAT_RGB8)
	for x in imageSize:
		for z in imageSize:
			var r = temperature.get_component(x,z)
			var g = humidity.get_component(x,z)
			var b = continentalness.get_component(x,z)
			rawImage.set_pixel(x,z, Color(r,b,g))
			finalImage.set_pixel(x,z, lookupTable.lookup(r,g,b).biomeColor)
	#finalImage.save_png("res://TestImages/biomes.png")
	print("Done!")
	return finalImage

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
