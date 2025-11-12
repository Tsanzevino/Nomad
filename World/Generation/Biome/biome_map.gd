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

func get_biome(pos : Vector3) -> Biome:
	var t : float = temperature.get_component(pos.x,pos.z)
	var h : float = humidity.get_component(pos.x,pos.z)
	var c : float = continentalness.get_component(pos.x,pos.z)
	return blt.lookup(t,h,c)
	
func get_biome_height(pos : Vector3) -> float:
	var t : float = temperature.get_component(pos.x,pos.z)
	var h : float = humidity.get_component(pos.x,pos.z)
	var c : float = continentalness.get_component(pos.x,pos.z)
	return blt.lookup(t,h,c).get_component(pos.x,pos.z)

func generate_map(pos : Vector3, size : int) -> BiomeMapChunk:
	var map : Array[PackedByteArray] = []
	var table : Array[Biome]
	var b : Biome
	var i : int
	map.resize(size)
	for x in size:
		map[x].resize(size)
		for z in size:
			b = get_biome(pos + Vector3(x,0,z))
			i = table.find(b)
			if i == -1:
				map[x][z] = table.size()
				table.push_back(b)
			else:
				map[x][z] = i
	return BiomeMapChunk.new(map,pos,size,table)

func generate_image(pos : Vector3, size : int) -> Image:
	var finalImage = Image.create_empty(size,size,false,Image.FORMAT_RGB8)
	for x in size:
		for z in size:
			finalImage.set_pixel(x,z, get_biome(pos + Vector3(x,0,z)).biomeColor)
	finalImage.save_png("res://TestImages/biomes.png")
	return finalImage
