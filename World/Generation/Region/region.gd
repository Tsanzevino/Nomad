class_name Region extends Object

var biomeMapChunk : BiomeMapChunk :
	get():
		mut.lock()
		mut.unlock()
		return biomeMapChunk
var heightMapChunk : HeightMapChunk:
	get():
		mut.lock()
		mut.unlock()
		return heightMapChunk

var generationThread : Thread = Thread.new()
var mut : Mutex = Mutex.new()

## The number of chunks long the region is
static var size : int = 15

var center : Vector2i

#region Setup Functions

func _init(regionCoords : Vector2i) -> void:
	# Create a thread to generate the biome map chunk
	generationThread.start(create_height_map)
	center = regionCoords * (Region.size * Chunk.size)

func create_height_map():
	mut.lock()
	var biomeMap = create_biome_map()
	var heightMap = HeightMapChunk.new(0,0,(Region.size + 1) * Chunk.size)
	heightMap.add_biome_heights(biomeMap)
	heightMapChunk = heightMap
	biomeMapChunk = biomeMap
	mut.unlock()
	RegionCache.set_region(get_region_coordinates(center.x,center.y), self)
	print("Loaded")

func create_biome_map() -> BiomeMapChunk:
	var biomeMap : BiomeMapChunk = BiomeMapChunk.new(0,0,(Region.size + 1) * Chunk.size)
	return biomeMap

#endregion

## Returns the coordinates of the region the (x,z) are in.
static func get_region_coordinates(x : float, z : float) -> Vector2i:
	return Vector2i(roundi(x / (Region.size * Chunk.size)), roundi(z / (Region.size * Chunk.size)))
