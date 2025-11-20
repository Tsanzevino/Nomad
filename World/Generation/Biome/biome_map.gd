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

func generate_map_chunk(px : float, pz : float, size : int) -> BiomeMapChunk:
	var map : Array[PackedByteArray] = []
	var table : Array[Biome]
	var b : Biome
	var i : int
	map.resize(size)
	for x in size:
		map[x].resize(size)
		for z in size:
			b = get_biome(px + x, pz + z)
			i = table.find(b)
			if i == -1:
				map[x][z] = table.size()
				table.push_back(b)
			else:
				map[x][z] = i
	return BiomeMapChunk.new(map,Vector3(px,0.0,pz),size,table)

func generate_recursive_chunk(px : int, pz : int, size : int) -> RecursiveBiomeMapChunk:
	var map : Array[PackedByteArray] = []
	var table : Array[Biome]
	var b : Biome
	var i : int
	map.resize(size)
	for x in size:
		map[x].resize(size)
		for z in size:
			b = get_biome(px + x, pz + z)
			i = table.find(b)
			if i == -1:
				map[x][z] = table.size()
				table.push_back(b)
			else:
				map[x][z] = i
	return RecursiveBiomeMapChunk.new(px, pz, size, map, table)

func generate_image(px : float, pz : float, size : int) -> Image:
	var finalImage = Image.create_empty(size,size,false,Image.FORMAT_RGB8)
	for x in size:
		for z in size:
			finalImage.set_pixel(x,z, get_biome(px + x, pz + z).biomeColor)
	finalImage.save_png("res://Testing/TestImages/biomes.png")
	return finalImage
