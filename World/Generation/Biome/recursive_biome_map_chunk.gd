class_name RecursiveBiomeMapChunk extends Object

var quads : Variant = []
var offset : Vector2i
var size : int

func _init(offsetX : int, offsetZ : int, mapSize : int, map : Array[PackedByteArray], table : Array[Biome]):
	offset = Vector2i(offsetX,offsetZ)
	size = mapSize
	build_recursive_chunk(map, table)

func build_recursive_chunk(map : Array[PackedByteArray], table : Array[Biome]):
	quads = create_quad(map,table,size,0,0)

func create_quad(map : Array[PackedByteArray], table : Array[Biome], quadSize : int, relativeX : int, relativeZ : int) -> Variant:
	# Base case
	if quadSize == 1:
		return table[map[relativeX][relativeZ]]
	# Recursive decent
	# Create each quad and return either:
	# an array of four arrays representing each quad
	# OR
	# a single biome if each quad returns as the same single biome 
	var newQuads = [create_quad(map,table,quadSize / 2,relativeX, relativeZ), \
		create_quad(map,table,quadSize / 2,relativeX + quadSize / 2, relativeZ), \
		create_quad(map,table,quadSize / 2,relativeX + quadSize / 2, relativeZ + quadSize / 2), \
		create_quad(map,table,quadSize / 2,relativeX, relativeZ + quadSize / 2)]
	if compressable(newQuads): return newQuads[0]
	else: return newQuads

func compressable(q : Array):
	for a in q:
		if a is Array:
			return false
	return q[0] == q[2] and q[1] == q[3] and q[0] == q[1]

func get_biome(x : int, z : int) -> Biome: 
	if out_of_bounds(x,z): return null
	return search_quads(quads,size / 2,x,z)

func search_quads(q : Variant, quadSize : int, x : int, z : int) -> Biome:
	if q is Biome: return q
	if x < quadSize:
		if z < quadSize: return search_quads(q[0],quadSize / 2,x,z)
		else: return search_quads(q[3],quadSize / 2,x,z - quadSize)
	else:
		if z < quadSize: return search_quads(q[1],quadSize / 2,x - quadSize,z)
		else: return search_quads(q[2],quadSize / 2,x - quadSize,z - quadSize)

func get_biome_height(x : int, z : int) -> float:
	return get_biome(x,z).get_component(x,z)

func out_of_bounds(x : int, z : int) -> bool:
	return ((x < offset.x) or (z < offset.y)) or ((x >= offset.x + size) or (z >= offset.y + size))

func _to_string() -> String:
	if quads is Biome:
		return quads.biomeName
	else:
		return quad_to_string(quads,size)

func quad_to_string(q : Variant, quadSize : int, depth : int = 0) -> String:
	var depthPadding : String = ""
	for x in depth:
		depthPadding += "-"
	if q is Biome: return depthPadding + q.to_string()
	else: return "%s[\n%s,\n%s,\n%s,\n%s\n%s]" % [
	depthPadding,
	quad_to_string(q[0],quadSize / 2, depth + 1),
	quad_to_string(q[1],quadSize / 2, depth + 1),
	quad_to_string(q[2],quadSize / 2, depth + 1),
	quad_to_string(q[3],quadSize / 2, depth + 1),
	depthPadding]

func compression_efficiency():
	return (count_biomes_in_quad(quads,size) * 100.0) / (size * size)

func count_biomes_in_quad(q : Variant, quadSize : int) -> int:
	if q is Biome: return 1
	else:
		return count_biomes_in_quad(q[0],quadSize / 2) + count_biomes_in_quad(q[1],quadSize / 2) + count_biomes_in_quad(q[2],quadSize / 2) + count_biomes_in_quad(q[3],quadSize / 2)
