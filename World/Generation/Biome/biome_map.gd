class_name BiomeMap extends Resource

@export var temperature : NoiseComponent
@export var humidity : NoiseComponent
@export var continentalness : NoiseComponent

@export var blt : BiomeLookupTable

func setup(biomeSeed : int):
	blt.load_from_csv()
	set_seed(biomeSeed)

func set_seed(biomeSeed : int):
	temperature.set_seed(biomeSeed)
	humidity.set_seed(biomeSeed)
	continentalness.set_seed(biomeSeed)
	blt.set_seed(biomeSeed)

func get_biome(x : float, z : float) -> Biome:
	var t : float = temperature.get_component(x,z)
	var h : float = humidity.get_component(x,z)
	var c : float = continentalness.get_component(x,z)
	return blt.lookup(t,h,c)

func get_biome_height(x : float, z : float) -> float:
	var t : float = temperature.get_component(x,z)
	var h : float = humidity.get_component(x,z)
	var c : float = continentalness.get_component(x,z)
	return blt.lookup(t,h,c).get_component(x,z)

func generate_map_chunk(centerX : int, centerZ : int, size : int) -> BiomeMapChunk:
	return BiomeMapChunk.new(centerX,centerZ, size)

func generate_image(px : int, pz : int, size : int) -> Image:
	var finalImage = Image.create_empty(size,size,false,Image.FORMAT_RGB8)
	for x in size:
		for z in size:
			finalImage.set_pixel(x,z, get_biome(px + x, pz + z).biomeColor)
	finalImage.save_png("res://Testing/TestImages/biomes.png")
	return finalImage
