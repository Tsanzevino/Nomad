class_name RegionCache extends Object

static var regionMap : Dictionary[Vector2i,Region]

static func get_region(regionCoords : Vector2i) -> Region:
	if not regionMap.has(regionCoords): return null
	return regionMap[regionCoords]

static func set_region(regionCoords : Vector2i, region : Region):
	regionMap[regionCoords] = region
