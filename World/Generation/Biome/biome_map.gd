class_name BiomeMap extends Object

func sample(x : float, z : float) -> float:
	return x + z

func find_nearby_biomes(distance : float = Biome.MAX_INTRUSION) -> Dictionary[Biome, float]:
	if distance == 0:
		return {}
	return {}
