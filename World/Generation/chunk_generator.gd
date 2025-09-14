class_name ChunkGenerator extends MeshInstance3D

const shader : ShaderMaterial = preload("res://Shaders/height_shader.tres")

static var terrainSize : int = 25
static var amplitude : float = 1
static var resolution : int = 3
static var yOffset : float = 0.0
static var heightMap : HeightMap = preload("res://World/Generation/Height/default_height_map.tres")

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
	for z in txz:
		for x in txz:
			var resX : float = resolutionFactor * x
			var resZ : float = resolutionFactor * z
			var height = heightMap.get_height(resX + offset.x + global_position.x,resZ + offset.z + global_position.z)
			var vertexPosition = Vector3(resX, height * amplitude, resZ) + offset
			#surface_tool.set_color(Color(0,height,0))
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
	create_trimesh_collision()
