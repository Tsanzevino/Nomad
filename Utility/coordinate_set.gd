class_name CoordinateSet extends Object

var coordSet : Dictionary[Vector2i, bool] = {}

func get_set() -> Array[Vector2i]:
	return coordSet.keys()

func has(coords : Vector2i) -> bool:
	return coordSet.has(coords)

func add(coords : Vector2i):
	coordSet[coords] = true

func remove(coords : Vector2i):
	coordSet.erase(coords)

func empty():
	coordSet = {}

func intersection(otherSet : CoordinateSet) -> CoordinateSet:
	var returnSet : CoordinateSet = CoordinateSet.new()
	for coords in coordSet.keys():
		if otherSet.has(coords):
			returnSet.add(coords)
	return returnSet

func union(otherSet : CoordinateSet) -> CoordinateSet:
	var returnSet : CoordinateSet = CoordinateSet.new()
	for coords in coordSet.keys():
		returnSet.add(coords)
	for coords in otherSet.keys():
		returnSet.add(coords)
	return returnSet

## Returns the difference between the two sets.
## Any shared values between the sets will be removed, with only
## those originating from the calling set remaining
func difference(otherSet : CoordinateSet) -> CoordinateSet:
	var returnSet : CoordinateSet = CoordinateSet.new()
	for coords in coordSet.keys():
		if not otherSet.has(coords):
			returnSet.add(coords)
	return returnSet
