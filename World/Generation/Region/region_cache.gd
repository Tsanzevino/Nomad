class_name RegionCache extends Node

static var regionMap : Dictionary[Vector2i,Region]

static func get_region(regionCoords : Vector2i) -> Region:
	if not regionMap.has(regionCoords): return null
	return regionMap[regionCoords]

static func set_region(regionCoords : Vector2i, region : Region):
	regionMap[regionCoords] = region

## Returns the coordinates of the region the position is in
static func get_coordinates(position : Vector3) -> Vector2i:
	return Vector2i(roundi(position.x / (Region.size * Chunk.size)), roundi(position.z / (Region.size * Chunk.size)))
