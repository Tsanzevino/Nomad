class_name BiomeMapChunk extends Object

var map : Array[PackedByteArray]
var offset : Vector3
var size : int
var table : Array[Biome]

func _init(m : Array[PackedByteArray], o : Vector3, s : int, t : Array[Biome]):
	if t.size() > 1: map = m
	else: map = []
	offset = o
	size = s
	table = t

func sample(x : float, z : float) -> Biome:
	if out_of_bounds(x,z): return null
	if map == []: return table[0]
	return table[map[floor(x - offset.x)][floor(z - offset.z)]]

func sample_height(x : float, z : float) -> float:
	if out_of_bounds(x,z): return 0.0
	if map == []: return table[0].get_component(x,z)
	return table[map[floor(x - offset.x)][floor(z - offset.z)]].get_component(x,z)

func out_of_bounds(x : float, z : float) -> bool:
	var offsettedX = x - offset.x
	var offsettedZ = z - offset.z
	return offsettedX < 0 or size <= offsettedX or offsettedZ < 0 or size <= offsettedZ
