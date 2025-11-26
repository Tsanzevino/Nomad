class_name ChunkCache extends Object

static var chunkMap : Dictionary[Vector2i,Chunk]

static func get_chunk(chunkCoords : Vector2i) -> Chunk:
	if not chunkMap.has(chunkCoords): return null
	return chunkMap[chunkCoords]

static func set_chunk(chunkCoords : Vector2i, chunk : Chunk):
	chunkMap[chunkCoords] = chunk

## Returns the coordinates of the chunk the position is in
static func get_coordinates(position : Vector3) -> Vector2i:
	return Vector2i(roundi(position.x / Chunk.size), roundi(position.z / Chunk.size))
