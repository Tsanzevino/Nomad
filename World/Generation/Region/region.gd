class_name Region extends Object

## The number of chunks long the region is
static var size : int = 15

var biomeMap : BiomeMap
var heightMap : HeightMap

func _init(regionCoords : Vector2i) -> void:
	# Create a thread to generate the biome map chunk
	var center := regionCoords * (Region.size * Chunk.size)
	biomeMap = BiomeMapChunk.new(center.x - 1,center.y -1,(Region.size + 1) * Chunk.size)
	heightMap = HeightMapChunk.new(center.x - 1,center.y - 1,(Region.size + 1) * Chunk.size)
