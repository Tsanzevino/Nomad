class_name WorldGenerator extends Node3D

@export var chunkRadius : int = 10
@export var chunkSize : int = 16

func _ready():
	generateWorld()

func generateWorld():
	var chunksToGenerate : int = chunkRadius * chunkRadius * 4.0
	var chunksGenerated : int = 0
	for z in range(-chunkRadius, chunkRadius, 1):
		for x in range(-chunkRadius, chunkRadius, 1):
			var chunk : ChunkGenerator = ChunkGenerator.new()
			chunk.terrainSize = chunkSize
			chunk.position = Vector3(z * chunkSize, 0, x * chunkSize)
			add_child(chunk)
			chunksGenerated += 1
			print("progress : ", chunksGenerated, " / ", chunksToGenerate)
