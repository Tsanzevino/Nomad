@icon("res://World/Generation/Height/height_map_icon.png")
class_name HeightMap extends Resource

@export var components : Array[NoiseComponent]

@export var maxHeight : float = 25
@export var minHeight : float = 0
@export var heightSeed : int = 1
var heightScalar : float = 0.0

func setup():
	var totalWeight : float = 0.0
	for component in components:
		component.set_seed(heightSeed)
		totalWeight += component.get_weight()
	heightScalar = (maxHeight - minHeight) / totalWeight

func get_height(x : float, z : float) -> float :
	var totalComponent : float = 0.0
	for component in components:
		totalComponent += component.get_component(x,z)
	return totalComponent * heightScalar + minHeight
