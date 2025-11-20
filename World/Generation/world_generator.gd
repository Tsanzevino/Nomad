class_name WorldGenerator extends Node3D

@export var chunkRadius : int = 4
@export var chunkSize : int = 16
@export var generationSeed : int = 1


@export var amplitude : float = 1

@export var material : Material

var player : Node3D
var currentChunkCoords : Vector2i
var chunkLoadingQueue : ChunkLoadingQueue

@export var heightMap : HeightMap
@export var biomeMap : BiomeMap

@export var threadCount : int = 3
var threads : Array[Thread]

func _ready():
	threads.resize(threadCount)
	for i in threadCount:
		threads[i] = Thread.new()
	PlayerStats.biomeMap = biomeMap
	chunkLoadingQueue = ChunkLoadingQueue.new()
	heightMap.setup(generationSeed)
	biomeMap.setup(generationSeed)
	ChunkCache.chunkSize = chunkSize
	prepare_terrain_generator()
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
	var coords = Vector2(player.global_position.x,player.global_position.z)
	var newCoords : Vector2i = ChunkCache.get_chunk_coordinates(coords)
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
	chunk.position = Vector3(coords.x * chunkSize, 0, coords.y * chunkSize)
	chunk.material_override = material
	# SOURCE OF LAG: CAN BE PERFORMED ON THREAD
	#chunk.biomeMapChunk = biomeMap.generate_map(chunk.global_position - Vector3((chunkSize + 4)/2.0,0,(chunkSize + 4)/2.0),chunkSize + 4)
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

func prepare_terrain_generator():
	if material is ShaderMaterial:
		material.set_shader_parameter("min_height", heightMap.minHeight * amplitude)
		material.set_shader_parameter("max_height", heightMap.maxHeight * amplitude)

func generate_terrain(pos : Vector3, chunk : Chunk) -> void:
	var surface_tool = SurfaceTool.new()
	var index : int = 0
	var offset : Vector3 = Vector3(float(chunkSize) / -2.0,0.0,float(chunkSize) / -2.0)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in (chunkSize + 1):
		for x in (chunkSize + 1):
			var height = heightMap.get_height(x + offset.x + pos.x,z + offset.z + pos.z)
			var b = biomeMap.get_biome(x + offset.x + pos.x,z + offset.z + pos.z)
			height += b.get_component(x + offset.x + pos.x,z + offset.z + pos.z)
			surface_tool.set_color(b.biomeColor)
			var vertexPosition = Vector3(x, height * amplitude, z) + offset
			surface_tool.set_uv(Vector2(float(x)/chunkSize,float(z)/chunkSize))
			surface_tool.add_vertex(vertexPosition)
			if z < chunkSize and x < chunkSize:
				# First triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + 1)
				surface_tool.add_index(index + chunkSize + 2)
				# Second triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + chunkSize + 2)
				surface_tool.add_index(index + chunkSize + 1)
			index += 1
	surface_tool.generate_normals()
	call_deferred("assign_mesh", surface_tool.commit(), chunk)

func assign_mesh(mesh : Mesh, chunk : Chunk):
	chunk.mesh = mesh
	# SOURCE OF LAG: SHOULD DO ON THREAD
	chunk.create_trimesh_collision()
