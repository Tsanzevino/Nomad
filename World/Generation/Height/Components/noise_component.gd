@icon("res://World/Generation/Height/Components/noise_component_icon.png")
class_name NoiseComponent extends Resource

#region Fields

@export var noiseSampler : Curve
@export var noise : FastNoiseLite
@export var weight : float = 0.0
@export var seed_offset : int = 1

#endregion

#region Functions

## Sets the seed of the component as [code]s + seed_offset
func set_seed(s : int):
	noise.seed = s + seed_offset

## Gets the noise component at the provided coordinates
func get_component(x : float, z : float) -> float:
	return noiseSampler.sample(noise.get_noise_2d(x,z)) * weight

## Gets the unweighted noise component at the provided coordinates
func get_raw_component(x : float, z : float) -> float:
	return noiseSampler.sample(noise.get_noise_2d(x,z))

## Gets the weight of the noise component
func get_weight() -> float:
	return weight

#endregion
