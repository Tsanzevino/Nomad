## This Node loads the chunks as the player moves through the world.
class_name ChunkLoader extends Node3D

@export var chunkRadius : int = 7

var currentChunkCoords : Vector2i
var chunkLoadingQueue : ChunkLoadingQueue
var loadedSet : CoordinateSet = CoordinateSet.new()

@export var threadCount : int = 1
var threads : Array[Thread]
var queueMutex : Mutex
var quit : bool = false

static var chunkParent : Node3D

func _ready():
	# Create the loading queue
	chunkLoadingQueue = ChunkLoadingQueue.new()
	# Find the target parent for the chunks
	chunkParent = get_tree().get_first_node_in_group("World")
	# Set up the threads
	setup_threads()
	# Generates the chunks around the player before they spawn in
	generate_spawn()

## Creates the number of threads specified in threadCount,
## attaching them to run [code]load_from_queue()[/code]
func setup_threads():
	threads.resize(threadCount)
	queueMutex = Mutex.new()
	for i in threadCount:
		threads[i] = Thread.new()
		threads[i].start(load_from_queue)

## The threads' loading instructions
## Loads new chunks on a loop while there are new chunks to load
func load_from_queue():
	while(not quit):
		# Take from queue
		queueMutex.lock()
		if chunkLoadingQueue.size() > 0:
			# Get the nearest chunk to load
			var newChunkCoords := chunkLoadingQueue.pop(currentChunkCoords)
			queueMutex.unlock()
			# Load the chunk
			create_new_chunk(newChunkCoords)
		else: 
			queueMutex.unlock()

## Before quitting, the threads must finish, so
## the threads are signalled and then waited on.
func _exit_tree():
	quit = true
	for i in threadCount:
		threads[i].wait_to_finish()

## Generates the chunks initially surrounding the player
func generate_spawn():
	Stopwatch.start("Spawn Generation")
	queueMutex.lock()
	fill_set(loadedSet,currentChunkCoords)
	for z in range(-chunkRadius, chunkRadius + 1):
		for x in range(-chunkRadius, chunkRadius + 1):
			chunkLoadingQueue.push(Vector2i(x,z))
	queueMutex.unlock()
	while(chunkLoadingQueue.size() > 0): pass
	Stopwatch.stop("Spawn Generation")

func _physics_process(_delta):
	# Get the new chunk coordinates
	var newCoords := ChunkCache.get_coordinates(global_position)
	# If they haven't changed, we can skip
	if newCoords == currentChunkCoords:
		return
	# Print the coordinates for debugging
	print(newCoords)
	# Get the direction the chunk changed in
	currentChunkCoords = newCoords
	update_loaded_chunks()

func update_loaded_chunks():
	# Update the loaded set
	loadedSet.empty()
	fill_set(loadedSet, currentChunkCoords)
	# Loop through the set and load the new chunks
	queueMutex.lock()
	for chunkCoords in loadedSet.get_set():
		if chunkLoadingQueue.has_chunk(chunkCoords): continue
		var chunk : Chunk = ChunkCache.get_chunk(chunkCoords)
		if chunk == null:
			# Need to generate a new chunk
			chunkLoadingQueue.push(chunkCoords)
		else:
			# Chunk found in cache, reload it
			if chunk.get_parent() != chunkParent:
				chunkParent.add_child(chunk)
	
	# Loop through the active chunks and unload unneeded chunks
	for chunk : Chunk in chunkParent.get_children():
		var coords = ChunkCache.get_coordinates(chunk.global_position)
		if loadedSet.has(coords): continue
		# If we got here, we should need to remove the chunk
		if chunkLoadingQueue.has_chunk(coords):
			chunkLoadingQueue.remove_chunk(coords)
		else:
			chunkParent.remove_child(chunk)
	queueMutex.unlock()
	

func fill_set(coordSet : CoordinateSet, coords : Vector2i):
	if (coords.distance_to(currentChunkCoords) > chunkRadius + 0.5): return
	if coordSet.has(coords): return
	coordSet.add(coords)
	fill_set(coordSet, coords + Vector2i.DOWN)
	fill_set(coordSet, coords + Vector2i.UP)
	fill_set(coordSet, coords + Vector2i.RIGHT)
	fill_set(coordSet, coords + Vector2i.LEFT)

func create_new_chunk(coords : Vector2i) -> void:
	var pos := Vector3(coords.x * Chunk.size, 0, coords.y * Chunk.size)
	var mesh := generate_mesh(pos)
	var chunk := Chunk.new()
	call_deferred("apply",chunk,mesh,pos,coords)

func apply(chunk : Chunk, mesh : Mesh, pos : Vector3, coords : Vector2i):
	print("loaded %s" % coords)
	chunkParent.add_child(chunk)
	chunk.global_position = pos
	chunk.mesh = mesh
	ChunkCache.set_chunk(coords,chunk)
	# SOURCE OF LAG: SHOULD DO ON THREAD
	chunk.create_trimesh_collision()

func generate_mesh(pos : Vector3) -> Mesh:
	var surface_tool = SurfaceTool.new()
	var index : int = 0
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var offset : Vector3 = Vector3(float(Chunk.size) / -2.0,0.0,float(Chunk.size) / -2.0)
	var region = RegionCache.get_region(RegionCache.get_coordinates(pos))
	var biomeMap : BiomeMap
	var heightMap : HeightMap
	if region == null:
		print("fallback", RegionCache.get_coordinates(pos))
		biomeMap = GenerationSettings.biomeMap
		heightMap = GenerationSettings.heightMap
	else:
		biomeMap = BiomeMapChunk.new(pos.x,pos.z,Chunk.size * 2)
		heightMap = HeightMapChunk.new(pos.x,pos.z,Chunk.size * 2)
	for z in (Chunk.size + 1):
		for x in (Chunk.size + 1):
			var b = biomeMap.get_biome(x + offset.x + pos.x, z + offset.z + pos.z)
			var vertexPosition = Vector3(x, heightMap.get_height(x + offset.x + pos.x, z + offset.z + pos.z) * GenerationSettings.amplitude, z) + offset
			surface_tool.set_color(b.biomeColor)
			surface_tool.set_uv(Vector2(float(x)/Chunk.size,float(z)/Chunk.size))
			surface_tool.add_vertex(vertexPosition)
			if z < Chunk.size and x < Chunk.size:
				# First triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + 1)
				surface_tool.add_index(index + Chunk.size + 2)
				# Second triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + Chunk.size + 2)
				surface_tool.add_index(index + Chunk.size + 1)
			index += 1
	surface_tool.generate_normals()
	return surface_tool.commit()
