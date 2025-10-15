class_name BiomeMap extends Resource

@export var temperature : FastNoiseLite
@export var humidity : FastNoiseLite
@export var continentalness : FastNoiseLite

@export var biomes : Array[Biome]

var map

func generate(biomeSeed : int):
	map = biomeSeed

func sample(x : float, z : float) -> float:
	return x + z

func find_nearby_biomes(distance : float = Biome.MAX_INTRUSION) -> Dictionary[Biome, float]:
	if distance == 0:
		return {}
	return {}
