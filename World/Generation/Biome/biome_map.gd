class_name BiomeMap extends Resource

#region Fields

@export var temperature : NoiseComponent
@export var humidity : NoiseComponent
@export var continentalness : NoiseComponent

@export var blt : BiomeLookupTable

var genSeed : int

#endregion

#region Setup Functions

func setup(biomeSeed : int):
	blt.load_from_csv()
	set_seed(biomeSeed)

func set_seed(biomeSeed : int):
	genSeed = biomeSeed
	temperature.set_seed(biomeSeed)
	humidity.set_seed(biomeSeed)
	continentalness.set_seed(biomeSeed)
	blt.set_seed(biomeSeed)

#endregion

#region Lookup Functions

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

#endregion

#region Generation Functions

func generate_image(px : int, pz : int, size : int, scale : int = 1) -> Image:
	var finalImage := Image.create_empty(size,size,false,Image.FORMAT_RGB8)
	for x in range(size):
		for z in range(size):
			finalImage.set_pixel(x,z, get_biome(px + x * scale, pz + z * scale).biomeColor)
	return finalImage

#endregion
