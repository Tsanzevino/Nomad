class_name ChunkGenerator extends MeshInstance3D

static var generationSeed : int = 10
@export var continentalness : HeightComponent = preload("res://World/Generation/continentalness.tres")
@export var erosion : HeightComponent = preload("res://World/Generation/erosion.tres")
@export var peaksAndValleys : HeightComponent = preload("res://World/Generation/peaks_and_valleys.tres")

@export var resolution : int = 10
@export var terrainSize : int = 25
@export var amplitude : int = 1
@export var yOffset : float = 0.0
@export var shader : ShaderMaterial = preload("res://Shaders/height_shader.tres")

func _ready():
	generate_terrain()

func generate_terrain():
	var array_mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var index : int = 0
	var txz = terrainSize * resolution + 1
	var resolutionFactor : float = 1.0 / resolution
	var offset : Vector3 = Vector3(float(terrainSize) / -2.0,yOffset,float(terrainSize) / -2.0)
	var min_height : float = 100
	var max_height : float = 1
	for z in txz:
		for x in txz:
			var height = get_terrain_height(x * resolutionFactor + offset.x + global_position.x,z * resolutionFactor + offset.z + global_position.z)
			if height < min_height:
				min_height = height
			if height > max_height:
				max_height = height
			var vertexPosition = Vector3(x * resolutionFactor, height * amplitude, z * resolutionFactor) + offset
			surface_tool.set_color(Color(0,height,0))
			#surface_tool.set_uv(Vector2())
			surface_tool.add_vertex(vertexPosition)
			if z < txz - 1 and x < txz - 1:
				# First triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + 1)
				surface_tool.add_index(index + txz + 1)
				# Second triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + txz + 1)
				surface_tool.add_index(index + txz)
			index += 1
	surface_tool.generate_normals()
	array_mesh = surface_tool.commit()
	mesh = array_mesh
	material_override = shader
	#create_trimesh_collision()
	update_shader(min_height,max_height)

func update_shader(min : float, max : float):
	shader.set_shader_parameter("min_height",min)
	shader.set_shader_parameter("max_height",max)
	
func get_terrain_height(x : float, z : float) -> float:
	return continentalness.get_height_component(x, z, generationSeed) + erosion.get_height_component(x, z, generationSeed) + peaksAndValleys.get_height_component(x, z, generationSeed) 
