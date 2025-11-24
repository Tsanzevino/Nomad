class_name HeightMapChunk extends Object

var map : Array[PackedFloat32Array] = []
var offset : Vector2i
var size : int

func _init(centerX : int, centerZ : int, chunkSize : int):
	offset = Vector2i(centerX - (size - 1) / 2, centerZ - (size - 1) / 2)
	size = chunkSize
	var heightMap : HeightMap = WorldGenerator.heightMap
	map.resize(size)
	for x in size:
		map[x].resize(size)
		for z in size:
			map[x][z] = heightMap.get_height(x + offset.x,z + offset.y)

func get_height(x : float, z : float) -> float:
	var localPos : Vector2i =real_to_local(x,z)
	if out_of_bounds(localPos): return 0.0
	return map[localPos.x][localPos.y]

func out_of_bounds(localPos : Vector2i) -> bool:
	return ((localPos.x < 0) or (localPos.y < 0)) or ((localPos.x >= size) or (localPos.y >= size))

func real_to_local(x : float, z : float) -> Vector2i:
	return Vector2i(roundi(x - offset.x),roundi(z - offset.y))
