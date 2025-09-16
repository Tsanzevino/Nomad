class_name HeightComponent extends Resource

@export var heightSampler : Curve
@export var noise : FastNoiseLite
@export var weight : float = 0.0
@export var seed_offset : int = 1

func set_seed(s : int):
	noise.seed = s + seed_offset

func get_component(x : float, z : float) -> float:
	return heightSampler.sample(noise.get_noise_2d(x,z)) * weight

func get_weight() -> float:
	return weight
