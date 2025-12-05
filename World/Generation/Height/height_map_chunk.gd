class_name HeightMapChunk extends HeightMap

#region Fields

var map : Array[PackedFloat32Array] = []
var offset : Vector2
var size : int

#endregion

#region Setup Functions

func _init(centerX : float, centerZ : float, chunkSize : int, smoothRadius : int = 10):
	size = chunkSize
	offset = Vector2(centerX - (size - 1) / 2.0, centerZ - (size - 1) / 2.0)
	var heightMap : HeightMap = GenerationSettings.heightMap
	var rawMap : Array[PackedFloat32Array] = []
	var rawSize : int = size + 2 * smoothRadius
	rawMap.resize(rawSize)
	for x in rawSize:
		rawMap[x].resize(rawSize)
		for z in rawSize:
			rawMap[x][z] = heightMap.get_height((x - smoothRadius) + offset.x,(z - smoothRadius) + offset.y)
	
	map.resize(size)
	for x in range(smoothRadius, size + smoothRadius):
		map[x - smoothRadius].resize(size)
		for z in range(smoothRadius, size + smoothRadius):
			var heightAcc : float = 0.0
			for rawx in range(-smoothRadius,smoothRadius + 1):
				for rawz in range(-smoothRadius,smoothRadius + 1):
					heightAcc += rawMap[x + rawx][z + rawz]
			map[x - smoothRadius][z - smoothRadius] = heightAcc / ((smoothRadius * 2 + 1) *(smoothRadius * 2 + 1))

#endregion

#region Lookup Functions

## Returns the height at the specified location.
## Requires that the global coordinates are
## within the bounds of the map.
func get_height(x : float, z : float) -> float:
	var localPos : Vector2i = _global_to_local(x,z)
	if _out_of_bounds(localPos): return 0.0
	return map[localPos.x][localPos.y]

## Converts the global coordinates to map coordinates
func _out_of_bounds(localPos : Vector2i) -> bool:
	return ((localPos.x < 0) or (localPos.y < 0)) or ((localPos.x >= size) or (localPos.y >= size))

## Verifies that the local coordinates are valid map locations
func _global_to_local(x : float, z : float) -> Vector2i:
	return Vector2i(roundi(x - offset.x),roundi(z - offset.y))

#endregion

#region Generation Functions

func generate_image() -> Image:
	var finalImage := Image.create_empty(size,size,false,Image.FORMAT_RF)
	for x in range(size):
		for z in range(size):
			var normalizedHeight : float = (get_height(offset.x + x, offset.y + z) - GenerationSettings.heightMap.minHeight) / GenerationSettings.heightMap.maxHeight
			finalImage.set_pixel(x,z, Color(normalizedHeight,normalizedHeight,normalizedHeight))
	return finalImage

#endregion
