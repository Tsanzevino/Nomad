class_name ChunkLoadingQueue extends Object

# I do love you, Brandi <3
# And nobody else </3
# At least romantically

var chunkCoords : Array[Vector2i] = []

func push(chunkCoord : Vector2i):
	chunkCoords.push_back(chunkCoord)

func pop(currentChunkCoords : Vector2i) -> Vector2i:
	var closestChunkIndex : int = 0
	var minDistance : float = chunkCoords[0].distance_to(currentChunkCoords)
	for i in chunkCoords.size():
		if chunkCoords[i].distance_to(currentChunkCoords) < minDistance:
			closestChunkIndex = i
			minDistance = chunkCoords[i].distance_to(currentChunkCoords)
	return chunkCoords.pop_at(closestChunkIndex)

func has_chunk(chunkCoord : Vector2i) -> bool:
	return chunkCoords.has(chunkCoord)

func remove_chunk(chunkCoord : Vector2i):
	chunkCoords.remove_at(chunkCoords.find(chunkCoord))

func size() -> int:
	return chunkCoords.size()
