@icon("res://World/Generation/Height/height_map_icon.png")
class_name HeightMap extends Resource

#region Fields

@export var components : Array[NoiseComponent]

@export var maxHeight : float = 25
@export var minHeight : float = 0
var biomeMap : BiomeMap
var heightScalar : float = 0.0

#endregion

#region Functions

## Sets the seed of all components and accumulates the total weight
func setup(heightSeed : int):
	var totalWeight : float = 0.0
	for component in components:
		component.set_seed(heightSeed)
		totalWeight += component.get_weight()
	heightScalar = (maxHeight - minHeight) / totalWeight
	biomeMap = preload("res://Data/World/Generation/BiomeMaps/default_biome_map.tres")

## Gets the height at the specified location and scales it to the min and max height
func get_height(x : float, z : float) -> float :
	var totalComponent : float = 0.0
	for component in components:
		totalComponent += component.get_component(x,z)
	return totalComponent * heightScalar + minHeight + biomeMap.get_biome_height(x,z)

#endregion
