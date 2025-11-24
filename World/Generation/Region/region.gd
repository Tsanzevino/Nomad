class_name Region extends Object

var biomeMapChunk : BiomeMapChunk
var heightMapChunk : HeightMapChunk

## The number of chunks long the region is
static var size : int = 15

var center : Vector2i

var offset : Vector2i

func _init(regionCoords : Vector2i) -> void:
	center = regionCoords * (Region.size * Chunk.size)
	offset = center - Vector2i(Region.size * (Chunk.size) / 2,Region.size * (Chunk.size) / 2)
	# Create a thread to generate the biome map chunk
	var biomeThread : Thread = Thread.new()
	biomeThread.start(create_biome_map_chunk)
	# Create a thread to generate the height map chunk
	var heightThread : Thread = Thread.new()
	heightThread.start(create_height_map_chunk)

func create_biome_map_chunk():
	var map : BiomeMapChunk = BiomeMapChunk.new(0,0,(Region.size + 1) * Chunk.size)
	call_deferred("assign_biome_map_chunk",map)

func assign_biome_map_chunk(map : BiomeMapChunk):
	biomeMapChunk = map

func create_height_map_chunk():
	var map : HeightMapChunk = HeightMapChunk.new(0,0,(Region.size + 1) * Chunk.size)
	call_deferred("assign_height_map_chunk",map)

func assign_height_map_chunk(map : HeightMapChunk):
	heightMapChunk = map

## Returns the coordinates of the region the (x,z) are in.
static func get_region_coordinates(x : float, z : float) -> Vector2i:
	return Vector2i(roundi(x / (Region.size * Chunk.size)), roundi(z / (Region.size * Chunk.size)))
