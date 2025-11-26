extends Node

var worldSeed : int = 1
var amplitude : float = 1.0
var heightMap : HeightMap = preload("res://Data/World/Generation/HeightMaps/default_height_map.tres")
var biomeMap : BiomeMap = preload("res://Data/World/Generation/BiomeMaps/default_biome_map.tres")

func _init():
	heightMap.setup(worldSeed)
	biomeMap.setup(worldSeed)
