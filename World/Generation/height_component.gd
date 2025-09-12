class_name HeightComponent extends Resource

@export var heightSampler : Curve
@export var noise : FastNoiseLite
@export var weight : float = 1.0
@export var seed_offset : int = 1
func get_height_component(x : float, z : float, seed : int) -> float:
	noise.seed = seed
	return heightSampler.sample(noise.get_noise_2d(x,z)) * weight
