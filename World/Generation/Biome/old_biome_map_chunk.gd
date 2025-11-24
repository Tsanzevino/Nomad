class_name OldBiomeMapChunk extends Object

var map : Array[PackedByteArray]
var table : Array[Biome]

var offset : Vector2
var bounds : Rect2

func _init(m : Array[PackedByteArray], o : Vector3, s : int, t : Array[Biome]):
	if t.size() > 1: map = m
	offset = Vector2(o.x,o.z)
	table = t
	bounds = Rect2(offset,Vector2(s,s))
	
func get_biome(x : float, z : float) -> Biome: 
	if out_of_bounds(x,z): return null
	if map_is_simple(): return table[0]
	return table[map[floor(x - offset.x)][floor(z - offset.y)]]

func get_biome_height(x : float, z : float) -> float:
	if out_of_bounds(x,z): return 0.0
	if map_is_simple(): return table[0].get_component(x,z)
	return table[map[floor(x - offset.x)][floor(z - offset.y)]].get_component(x,z)

## Checks if the map consists of a single biome, meaning it is simple.
## This is meant to save space when producing many maps
func map_is_simple() -> bool:
	return table.size() <= 1

func out_of_bounds(x : float, z : float) -> bool:
	return not bounds.has_point(Vector2(x,z))
