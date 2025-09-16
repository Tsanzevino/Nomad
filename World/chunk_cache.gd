class_name ChunkCache extends Object

static var chunkMap : Dictionary[Vector2i,Chunk]
static var chunkSize : int

static func get_chunk_coordinates(position : Vector2) -> Vector2i:
	if chunkSize == 0:
		print("ERROR: Chunk Size not set")
		return Vector2i.ZERO
	
	return ((position - Vector2(chunkSize / 2.0, chunkSize / 2.0)) / chunkSize).floor() + Vector2(1.0,1.0)

static func get_chunk(chunkCoords : Vector2i) -> Chunk:
	if not chunkMap.has(chunkCoords): return null
	return chunkMap[chunkCoords]

static func set_chunk(chunkCoords : Vector2i, chunk : Chunk):
	chunkMap[chunkCoords] = chunk
