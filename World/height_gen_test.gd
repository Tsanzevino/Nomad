extends MeshInstance3D

var size : int = 512
var heightScalar : float = 0
var minHeight : float = 0
var maxHeight : float = 50.0

var map : Map

@export var erosionMap : NoiseComponent
@export var continentalnessMap : NoiseComponent
@export var amplitudeMap : NoiseComponent

func _ready():
	seed(0)
	map = Map.new(8)
	map.generate_starting_map()
	var totalWeight : float = 0.0
	totalWeight += erosionMap.get_weight()
	totalWeight += continentalnessMap.get_weight()
	heightScalar = (maxHeight - minHeight) / totalWeight
	mesh = generate_mesh()

func generate_mesh() -> Mesh:
	var surface_tool = SurfaceTool.new()
	var index : int = 0
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var offset : Vector3 = Vector3(float(size) / -2.0,0.0,float(size) / -2.0)
	
	for z in (size + 1):
		for x in (size + 1):
			var vertexPosition = Vector3(x, get_height(x,z), z) + offset
			surface_tool.set_color(map.get_color(x,z))
			surface_tool.set_uv(Vector2(float(x)/size,float(z)/size))
			surface_tool.add_vertex(vertexPosition)
			if z < size and x < size:
				# First triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + 1)
				surface_tool.add_index(index + size + 2)
				# Second triangle of mesh square
				surface_tool.add_index(index)
				surface_tool.add_index(index + size + 2)
				surface_tool.add_index(index + size + 1)
			index += 1
	surface_tool.generate_normals()
	return surface_tool.commit()

func get_height(x : float, z : float) -> float :
	var totalComponent : float = 0.0
	totalComponent += erosionMap.get_component(x,z)
	totalComponent += continentalnessMap.get_component(x,z)
	return (totalComponent * heightScalar + minHeight) * amplitudeMap.get_component(x,z)
