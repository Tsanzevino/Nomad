class_name BiomeMapChunk extends Object

var quads : Variant = []
var offset : Vector2
var size : int

func _init(centerX : int, centerZ : int, mapSize : int):
	size = mapSize
	if not power_of_two():
		print("ERROR: Biome map chunk must be a power of two!")
	offset = Vector2(centerX - (size - 1) / 2.0, centerZ - (size - 1) / 2.0)
	var biomeMap : BiomeMap = WorldGenerator.biomeMap
	var map : Array[PackedByteArray] = []
	var table : Array[Biome]
	var b : Biome
	var i : int
	map.resize(size)
	for x in size:
		map[x].resize(size)
		for z in size:
			b = biomeMap.get_biome(offset.x + x, offset.y + z)
			i = table.find(b)
			if i == -1:
				map[x][z] = table.size()
				table.push_back(b)
			else:
				map[x][z] = i
	build_recursive_chunk(map, table)

func power_of_two() -> bool:
	var n : int = 1
	while n < size:
		n *= 2
	print(size)
	return n == size

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

func get_biome_height(x : float, z : float) -> float:
	var localPos : Vector2i = real_to_local(x,z)
	if out_of_bounds(localPos): return 0.0
	return search_quads(quads,size / 2,localPos).get_component(x,z)

func get_biome(x : float, z : float) -> Biome:
	var localPos : Vector2i = real_to_local(x,z)
	if out_of_bounds(localPos): return null
	return search_quads(quads,size / 2,localPos)

func out_of_bounds(localPos : Vector2i) -> bool:
	return ((localPos.x < 0) or (localPos.y < 0)) or ((localPos.x >= size) or (localPos.y >= size))

func real_to_local(x : float, z : float) -> Vector2i:
	return Vector2i(roundi(x - offset.x),roundi(z - offset.y))

func search_quads(q : Variant, quadSize : int, localPos : Vector2i) -> Biome:
	if q is Biome: return q
	if localPos.x < quadSize:
		if localPos.y < quadSize: return search_quads(q[0],quadSize / 2,localPos)
		else: return search_quads(q[3],quadSize / 2,localPos - Vector2i(0,quadSize))
	else:
		if localPos.y < quadSize: return search_quads(q[1],quadSize / 2,localPos - Vector2i(quadSize,0))
		else: return search_quads(q[2],quadSize / 2,localPos - Vector2i(quadSize,quadSize))

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
