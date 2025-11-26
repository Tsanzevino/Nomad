class_name RegionLoadingQueue extends Object

# I do love you, Brandi <3
# And nobody else </3
# At least romantically

var regionCoords : Array[Vector2i] = []

func push(regionCoord : Vector2i):
	regionCoords.push_back(regionCoord)

func pop(currentRegionCoords : Vector2i) -> Vector2i:
	var closestRegionIndex : int = 0
	var minDistance : float = regionCoords[0].distance_to(currentRegionCoords)
	for i in regionCoords.size():
		if regionCoords[i].distance_to(currentRegionCoords) < minDistance:
			closestRegionIndex = i
			minDistance = regionCoords[i].distance_to(currentRegionCoords)
	return regionCoords.pop_at(closestRegionIndex)

func has_region(regionCoord : Vector2i) -> bool:
	return regionCoords.has(regionCoord)

func remove_region(regionCoord : Vector2i):
	regionCoords.remove_at(regionCoords.find(regionCoord))

func size() -> int:
	return regionCoords.size()
