class_name HeightComponent extends Resource

@export var heightSampler : Curve
@export var noise : FastNoiseLite
@export var weight : float = 1.0

func get_height_component(x : float, z : float) -> float:
	return heightSampler.sample(noise.get_noise_2d(x,z)) * weight
