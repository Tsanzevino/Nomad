class_name WorldGenerator extends Node3D

@export var chunkRadius : int = 4
@export var amplitude : float = 1
@export var material : Material

var player : Node3D
var currentChunkCoords : Vector2i
var chunkLoadingQueue : ChunkLoadingQueue

var spawnRegion : Region

@export var threadCount : int = 1
var threads : Array[Thread]

func _ready():
	threads.resize(threadCount)
	for i in threadCount:
		threads[i] = Thread.new()
	chunkLoadingQueue = ChunkLoadingQueue.new()
	spawnRegion = Region.new(Vector2i(0,0))
	generate_world()
	player = get_tree().get_first_node_in_group("Player")

func generate_world():
	var timeStart = Time.get_ticks_msec()
	var chunksToGenerate : int = (chunkRadius * (chunkRadius + 1)) * 4 + 1
	var chunksGenerated : int = 0
	for z in range(-chunkRadius, chunkRadius + 1):
		for x in range(-chunkRadius, chunkRadius + 1):
			create_new_chunk(Vector2i(x,z))
			chunksGenerated += 1
			print("progress : ", chunksGenerated, " / ", chunksToGenerate)
	print("Took ", (Time.get_ticks_msec() - timeStart) / 1000.0, " seconds")

func _physics_process(_delta):
	var newCoords : Vector2i = ChunkCache.get_coordinates(player.global_position)
	load_chunks(newCoords)
	if newCoords == currentChunkCoords:
		return
	print(newCoords)
	# Get the direction the chunk changed in
	var moveDirection : Vector2i = newCoords - currentChunkCoords
	currentChunkCoords = newCoords
	# Its possible to move diagonally, and that has to be treated differently
	if moveDirection.length() > 1.1:
		update_loaded_chunks(Vector2i(moveDirection.x, 0), currentChunkCoords - Vector2i(0, moveDirection.y))
		update_loaded_chunks(Vector2i(0, moveDirection.y), currentChunkCoords)
	else:
		update_loaded_chunks(moveDirection, currentChunkCoords)

func update_loaded_chunks(moveDirection : Vector2i, coords : Vector2i):
	# Load new chunks
	var xRange := [(moveDirection.x * chunkRadius) + coords.x] if moveDirection.x != 0 else range(-chunkRadius + coords.x, chunkRadius + coords.x + 1)
	var zRange := [(moveDirection.y * chunkRadius) + coords.y] if moveDirection.y != 0 else range(-chunkRadius + coords.y, chunkRadius + coords.y + 1)
	for x in xRange:
		for z in zRange:
			var chunkCoords := Vector2i(x,z)
			var chunk : Chunk = ChunkCache.get_chunk(chunkCoords)
			if chunk == null:
				# Need to generate a new chunk
				chunkLoadingQueue.push(chunkCoords)
			else:
				# Chunk found in cache, reload it
				add_child(chunk)
	# Remove old chunks
	xRange = [(-moveDirection.x * (chunkRadius + 1)) + coords.x] if moveDirection.x != 0 else range(-chunkRadius + coords.x, chunkRadius + coords.x + 1)
	zRange = [(-moveDirection.y * (chunkRadius + 1)) + coords.y] if moveDirection.y != 0 else range(-chunkRadius + coords.y, chunkRadius + coords.y + 1)
	for x in xRange:
		for z in zRange:
			var remove := Vector2i(x,z)
			if chunkLoadingQueue.has_chunk(remove):
				chunkLoadingQueue.remove_chunk(remove)
			else:
				remove_child(ChunkCache.get_chunk(remove))

func create_new_chunk(coords : Vector2i) -> void:
	var chunk := Chunk.new()
	add_child(chunk)
	chunk.position = Vector3(coords.x * Chunk.size, 0, coords.y * Chunk.size)
	chunk.material_override = material
	ChunkCache.set_chunk(coords,chunk)
	# Offload to thread if possible
	if not thread_is_available():
		generate_terrain(chunk.global_position, chunk)
	else:
		get_free_thread().start(generate_terrain.bind(chunk.global_position, chunk))

func thread_is_available() -> bool:
	for t in threads:
		if not t.is_alive():
			return true
	return false

func threads_available() -> int:
	var count : int = 0
	for t in threads:
		if not t.is_alive():
			count += 1
	return count

func get_free_thread() -> Thread:
	for t in threads:
		if not t.is_alive():
			if t.is_started(): t.wait_to_finish()
			return t
	return null

func load_chunks(coords : Vector2i):
	var amount = min(threads_available(),chunkLoadingQueue.size())
	if amount == 0:
		return
	for n in amount:
		create_new_chunk(chunkLoadingQueue.pop(coords))

func generate_terrain(pos : Vector3, chunk : Chunk) -> void:
	var surface_tool = SurfaceTool.new()
	var index : int = 0
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var offset : Vector3 = Vector3(float(Chunk.size) / -2.0,0.0,float(Chunk.size) / -2.0)
	var biomeMapChunk = spawnRegion.biomeMapChunk if spawnRegion.biomeMapChunk != null else BiomeMapChunk.new(pos.x,pos.z,Chunk.size * 2)
	var heightMapChunk = HeightMapChunk.new(pos.x,pos.z,Chunk.size * 2)
	heightMapChunk.add_biome_heights(biomeMapChunk)
	for z in (Chunk.size + 1):
		for x in (Chunk.size + 1):
			var b = biomeMapChunk.get_biome(x + offset.x + pos.x, z + offset.z + pos.z)
			surface_tool.set_color(b.biomeColor)
			var vertexPosition = Vector3(x, heightMapChunk.get_height(x + offset.x + pos.x, z + offset.z + pos.z) * amplitude, z) + offset
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
	call_deferred("assign_mesh", surface_tool.commit(), chunk)

func smooth_heights(heights : Array[Array]) -> Array[Array]:
	var newHeights : Array[Array] = []
	newHeights.resize(Chunk.size + 1)
	for z in (Chunk.size + 1):
		newHeights[z].resize(Chunk.size + 1)
		for x in (Chunk.size + 1):
			newHeights[z][x] = (heights[z][x] + heights[z-1][x] + heights[z+1][x] + heights[z][x-1] + heights[z][x+1]) / 5
	return newHeights

func assign_mesh(mesh : Mesh, chunk : Chunk):
	chunk.mesh = mesh
	# SOURCE OF LAG: SHOULD DO ON THREAD
	chunk.create_trimesh_collision()
