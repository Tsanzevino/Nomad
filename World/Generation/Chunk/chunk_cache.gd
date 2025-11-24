class_name ChunkCache extends Object

static var chunkMap : Dictionary[Vector2i,Chunk]

static func get_chunk_coordinates(position : Vector2) -> Vector2i:
	return ((position - Vector2(Chunk.size / 2.0, Chunk.size / 2.0)) / Chunk.size).floor() + Vector2(1.0,1.0)

static func get_chunk(chunkCoords : Vector2i) -> Chunk:
	if not chunkMap.has(chunkCoords): return null
	return chunkMap[chunkCoords]

static func set_chunk(chunkCoords : Vector2i, chunk : Chunk):
	chunkMap[chunkCoords] = chunk
