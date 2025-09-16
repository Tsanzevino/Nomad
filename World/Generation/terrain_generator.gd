class_name TerrainGenerator extends Object

static var terrainSize : int = 64
static var amplitude : float = 1
static var resolution : int = 3
static var yOffset : float = 0.0
static var heightMap : HeightMap = preload("res://World/Generation/Height/default_height_map.tres")

static func generate_terrain(pos : Vector3) -> Mesh:
	var surface_tool = SurfaceTool.new()
	var index : int = 0
	var txr = terrainSize * resolution + 1
	var resolutionFactor : float = 1.0 / resolution
	var offset : Vector3 = Vector3(float(terrainSize) / -2.0,yOffset,float(terrainSize) / -2.0)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in txr:
		for x in txr:
			var resX : float = resolutionFactor * x
			var resZ : float = resolutionFactor * z
			var height = heightMap.get_height(resX + offset.x + pos.x,resZ + offset.z + pos.z)
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
	surface_tool.generate_normals()
	return surface_tool.commit()
