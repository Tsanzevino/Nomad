class_name ChunkCache extends Object

static var chunkMap : Dictionary[Vector2i,Chunk]

static func get_chunk(chunkCoords : Vector2i) -> Chunk:
	if not chunkMap.has(chunkCoords): return null
	return chunkMap[chunkCoords]

static func set_chunk(chunkCoords : Vector2i, chunk : Chunk):
	chunkMap[chunkCoords] = chunk
