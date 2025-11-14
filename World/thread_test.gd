extends Node3D

@export var chunkRadius : int = 4
@export var chunkSize : int = 64
@export var generationSeed : int = 1
@export var heightMap : HeightMap = preload("res://Data/World/Generation/HeightMaps/default_height_map.tres")
@export var biomeMap : BiomeMap = preload("res://Data/World/Generation/BiomeMaps/default_biome_map.tres")

@export var amplitude : float = 1
@export var resolution : int = 3
@export var yOffset : float = 0.0

@export var material : Material

var player : Node3D
var currentChunkCoords : Vector2i
var chunkLoadingQueue : ChunkLoadingQueue

var totalVertexTime : int = 0
var totalNoiseTime : int = 0
var totalNormalTime : int = 0

var thread : Thread

func _ready():
	thread = Thread.new()
	thread.start(generate_terrain.bind(Vector3.ZERO, $MeshInstance3D2))

func attach_mesh(mesh : Mesh, instance : MeshInstance3D):
	instance.mesh = mesh

func generate_terrain(pos : Vector3, instance : MeshInstance3D):
	var start = Time.get_ticks_msec()
	var surface_tool = SurfaceTool.new()
	var index : int = 0
	var txr = chunkSize * resolution + 1
	var resolutionFactor : float = 1.0 / resolution
	var offset : Vector3 = Vector3(float(chunkSize) / -2.0,yOffset,float(chunkSize) / -2.0)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in txr:
		for x in txr:
			var resX : float = resolutionFactor * x
			var resZ : float = resolutionFactor * z
			start = Time.get_ticks_msec()
			var height = heightMap.get_height(resX + offset.x + pos.x,resZ + offset.z + pos.z)
			var b = biomeMap.get_biome(Vector3(resX + offset.x + pos.x,0.0,resZ + offset.z + pos.z))
			height += b.get_component(resX + offset.x + pos.x,resZ + offset.z + pos.z)
			surface_tool.set_color(b.biomeColor)
			totalNoiseTime += Time.get_ticks_msec() - start
			start = Time.get_ticks_msec()
			var vertexPosition = Vector3(resX, height * amplitude, resZ) + offset
			#surface_tool.set_color(Color(0,height,0))
			surface_tool.set_uv(Vector2(float(x)/txr,float(z)/txr))
			surface_tool.add_vertex(vertexPosition)
			if z < txr - 1 and x < txr - 1:
				# First triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + 1)
				surface_tool.add_index(index + txr + 1)
				# Second triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + txr + 1)
				surface_tool.add_index(index + txr)
			index += 1
			totalVertexTime += Time.get_ticks_msec() - start
	start = Time.get_ticks_msec()
	surface_tool.generate_normals()
	totalNormalTime += Time.get_ticks_msec() - start
	call_deferred("attach_mesh", surface_tool.commit(), instance)
	print("Test Success!")
