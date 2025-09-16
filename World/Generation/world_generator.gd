class_name WorldGenerator extends Node3D

@export var chunkRadius : int = 4
@export var chunkSize : int = 64
@export var heightMap : HeightMap

@export var amplitude : float = 1
@export var resolution : int = 3
@export var yOffset : float = 0.0

@export var material : Material

var player : Node3D
var currentChunkCoords : Vector2i
var chunkLoadingQueue : ChunkLoadingQueue

func _ready():
	chunkLoadingQueue = ChunkLoadingQueue.new()
	heightMap.setup()
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
	load_chunks(newCoords, 1)
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

func create_new_chunk(coords : Vector2i) -> Chunk:
	var chunk := Chunk.new()
	add_child(chunk)
	chunk.position = Vector3(coords.x * chunkSize, 0, coords.y * chunkSize)
	chunk.material_override = material
	chunk.mesh = TerrainGenerator.generate_terrain(chunk.global_position)
	chunk.create_trimesh_collision()
	ChunkCache.set_chunk(coords,chunk)
	return chunk

func load_chunks(coords : Vector2i, limit : int):
	var amount = min(limit,chunkLoadingQueue.size())
	if amount == 0:
		return
	for n in amount:
		create_new_chunk(chunkLoadingQueue.pop(coords))

func prepare_terrain_generator():
	TerrainGenerator.terrainSize = chunkSize
	TerrainGenerator.amplitude = amplitude
	TerrainGenerator.resolution = resolution
	TerrainGenerator.yOffset = yOffset
	TerrainGenerator.heightMap = heightMap
	if material is ShaderMaterial:
		material.set_shader_parameter("min_height", heightMap.minHeight * amplitude)
		material.set_shader_parameter("max_height", heightMap.maxHeight * amplitude)
