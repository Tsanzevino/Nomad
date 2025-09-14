class_name WorldGenerator extends Node3D

@export var chunkRadius : int = 4
@export var chunkSize : int = 64
@export var heightMap : HeightMap

@export var amplitude : float = 1
@export var resolution : int = 3
@export var yOffset : float = 0.0

func _ready():
	heightMap.setup()
	prepare_chunk_generator()
	generate_world()

func generate_world():
	var timeStart = Time.get_ticks_msec()
	var chunksToGenerate : int = (chunkRadius * (chunkRadius + 1)) * 4.0 + 1
	var chunksGenerated : int = 0
	for z in range(-chunkRadius, chunkRadius + 1, 1):
		for x in range(-chunkRadius, chunkRadius + 1, 1):
			var chunk : ChunkGenerator = ChunkGenerator.new()
			chunk.position = Vector3(z * chunkSize, 0, x * chunkSize)
			add_child(chunk)
			chunksGenerated += 1
			print("progress : ", chunksGenerated, " / ", chunksToGenerate)
	print("Took ", (Time.get_ticks_msec() - timeStart) / 1000.0, " seconds")

func prepare_chunk_generator():
	ChunkGenerator.terrainSize = chunkSize
	ChunkGenerator.amplitude = amplitude
	ChunkGenerator.resolution = resolution
	ChunkGenerator.yOffset = yOffset
	ChunkGenerator.heightMap = heightMap
	ChunkGenerator.shader.set_shader_parameter("max_height",heightMap.maxHeight)
	ChunkGenerator.shader.set_shader_parameter("min_height",heightMap.minHeight)
