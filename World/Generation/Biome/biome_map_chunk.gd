class_name BiomeMapChunk extends Object

var map : Array[PackedByteArray]
var table : Array[Biome]

var offset : Vector2
var bounds : Rect2

func _init(m : Array[PackedByteArray], o : Vector3, s : int, t : Array[Biome]):
	if t.size() > 1: map = m
	offset = Vector2(o.x,o.z)
	table = t
	bounds = Rect2(offset,Vector2(s,s))
	
func get_biome(pos : Vector3) -> Biome: 
	if out_of_bounds(pos): return null
	if map_is_simple(): return table[0]
	return table[map[floor(pos.x - offset.x)][floor(pos.z - offset.y)]]

func get_biome_height(pos : Vector3) -> float:
	if out_of_bounds(pos): return 0.0
	if map_is_simple(): return table[0].get_component(pos.x,pos.z)
	return table[map[floor(pos.x - offset.x)][floor(pos.z - offset.y)]].get_component(pos.x,pos.z)

## Checks if the map consists of a single biome, meaning it is simple.
## This is meant to save space when producing many maps
func map_is_simple() -> bool:
	return table.size() <= 1

func out_of_bounds(pos : Vector3) -> bool:
	return not bounds.has_point(Vector2(pos.x,pos.z))
