class_name BiomeMapChunk extends BiomeMap

#region Fields

var quads : Variant = []
var offset : Vector2
var size : int

#endregion

#region Setup Functions
## Creates a new BiomeMapChunk centered at the provided location.
## Due to the way the chunk is compressed, mapSize must be a power of two.
## If it is not a power of two, the created map will have undefined behavior on biome edges.
func _init(centerX : float, centerZ : float, mapSize : int):
	# Assign the size and verify it.
	size = mapSize
	if not _power_of_two():
		print("ERROR: Biome map chunk must be a power of two!")
	# Turn the centered coordinates into a bottom-left offset.
	# size - 1 accounts for the fencepost problem.
	offset = Vector2(centerX - (size - 1) / 2.0, centerZ - (size - 1) / 2.0)
	# Prepare for creating the uncompressed map
	var biomeMap : BiomeMap = GenerationSettings.biomeMap
	var map : Array[PackedByteArray] = []
	var table : Array[Biome]
	var b : Biome
	var i : int
	
	# Create the uncompressed map
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
	
	# Turn the uncompressed map into a recursive chunk
	_build_recursive_chunk(map, table)

## Verifies that the size is a power of two
func _power_of_two() -> bool:
	var n : int = 1
	while n < size:
		n *= 2
	return n == size

## Wrapper function for the beginning conditions for recursion
func _build_recursive_chunk(map : Array[PackedByteArray], table : Array[Biome]):
	quads = _create_quad(map,table,size,0,0)

## Creates a quad of the map using recursive descent
func _create_quad(map : Array[PackedByteArray], table : Array[Biome], quadSize : int, relativeX : int, relativeZ : int) -> Variant:
	# Base case
	if quadSize == 1:
		return table[map[relativeX][relativeZ]]
	# Recursive decent
	# Create each quad and return either:
	# an array of four arrays representing each quad
	# OR
	# a single biome if each quad returns as the same single biome 
	var newQuads = [_create_quad(map,table,quadSize / 2,relativeX, relativeZ), \
		_create_quad(map,table,quadSize / 2,relativeX + quadSize / 2, relativeZ), \
		_create_quad(map,table,quadSize / 2,relativeX + quadSize / 2, relativeZ + quadSize / 2), \
		_create_quad(map,table,quadSize / 2,relativeX, relativeZ + quadSize / 2)]
	if _compressable(newQuads): return newQuads[0]
	else: return newQuads

## Returns true if the quad provided can be compressed to a single biome
func _compressable(q : Array) -> bool:
	for a in q:
		if a is Array:
			return false
	return q[0] == q[2] and q[1] == q[3] and q[0] == q[1]

#endregion

#region Lookup Functions

## Returns the biome height at the specified location.
## Requires that the global coordinates are
## within the bounds of the map.
func get_biome_height(x : float, z : float) -> float:
	var localPos : Vector2i = _global_to_local(x,z)
	if _out_of_bounds(localPos): return 0.0
	return _search_quads(quads,size / 2,localPos).get_component(x,z)

## Returns the biome at the specified location.
## Requires that the global coordinates are
## within the bounds of the map.
func get_biome(x : float, z : float) -> Biome:
	var localPos : Vector2i = _global_to_local(x,z)
	if _out_of_bounds(localPos): return null
	return _search_quads(quads,size / 2,localPos)

## Converts the global coordinates to map coordinates
func _global_to_local(x : float, z : float) -> Vector2i:
	return Vector2i(roundi(x - offset.x),roundi(z - offset.y))

## Verifies that the local coordinates are valid map locations
func _out_of_bounds(localPos : Vector2i) -> bool:
	return ((localPos.x < 0) or (localPos.y < 0)) or ((localPos.x >= size) or (localPos.y >= size))

## Uses recursive descent to find the Biome at the provided position
func _search_quads(q : Variant, quadSize : int, localPos : Vector2i) -> Biome:
	# Return true if the quad is a single biome
	if q is Biome: return q
	
	# Determine which quad the coordinates are in and
	# modify the size and position to search that quad.
	if localPos.x < quadSize:
		if localPos.y < quadSize: return _search_quads(q[0],quadSize / 2,localPos)
		else: return _search_quads(q[3],quadSize / 2,localPos - Vector2i(0,quadSize))
	else:
		if localPos.y < quadSize: return _search_quads(q[1],quadSize / 2,localPos - Vector2i(quadSize,0))
		else: return _search_quads(q[2],quadSize / 2,localPos - Vector2i(quadSize,quadSize))

#endregion

#region Metadata Functions

func _to_string() -> String:
	if quads is Biome:
		return quads.biomeName
	else:
		return _quad_to_string(quads,size)

## Recursively descends to fancy print the quad representation.
func _quad_to_string(q : Variant, quadSize : int, depth : int = 0) -> String:
	var depthPadding : String = ""
	for x in depth:
		depthPadding += "-"
	if q is Biome: return depthPadding + q.to_string()
	else: return "%s[\n%s,\n%s,\n%s,\n%s\n%s]" % [
	depthPadding,
	_quad_to_string(q[0],quadSize / 2, depth + 1),
	_quad_to_string(q[1],quadSize / 2, depth + 1),
	_quad_to_string(q[2],quadSize / 2, depth + 1),
	_quad_to_string(q[3],quadSize / 2, depth + 1),
	depthPadding]

## Calculates the compression efficiency as a ratio of the 
## biome instance count over the size squared. The size
## squared represents the biome instance count of a raw file.
func compression_efficiency():
	return (count_biomes_in_quad(quads,size) * 100.0) / (size * size)

## Counts the stored instances of Biomes in a quad.
## Smaller values represent higher compression rates.
func count_biomes_in_quad(q : Variant, quadSize : int = size) -> int:
	if q is Biome: return 1
	else:
		return count_biomes_in_quad(q[0],quadSize / 2) + count_biomes_in_quad(q[1],quadSize / 2) + count_biomes_in_quad(q[2],quadSize / 2) + count_biomes_in_quad(q[3],quadSize / 2)

#endregion
