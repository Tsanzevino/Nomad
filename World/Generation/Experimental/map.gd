class_name Map extends Object


var bleed_chance : float = 0.7
var continent_chance : float = 0.1
var island_chance : float = 0.3

var _map : Array[Array]
var _size : int

func _init(size : int) -> void:
	_size = size
	_map.resize(_size)
	for x in _size:
		_map[x].resize(_size)
		for z in _size:
			_map[x][z] = 0

func generate_starting_map():
	create_continents()
	zoom() # 2x
	merge_land()
	merge_land()
	create_islands()
	zoom() # 4x
	add_temperature()
	merge_land()
	smooth_temperature()
	zoom() # 8x
	zoom() # 16x
	zoom() # 32x
	zoom() # 64x

func create_continents() -> void:
	for x in _size:
		for z in _size:
			if continent_chance > randf():
				_map[x][z] = 1

func create_islands() -> void:
	var new_map : Array[Array]
	new_map.resize(_size)
	for x in _size:
		new_map[x].resize(_size)
		for z in _size:
			var neighbors : Array[int] = get_immediate_neighbors(x,z)
			var all_water : bool = true
			for n in neighbors: 
				if n != 0: 
					all_water = false
					break
			if all_water and island_chance > randf():
				new_map[x][z] = 1
			else:
				new_map[x][z] = _map[x][z]
	_map = new_map

func merge_land() -> void:
	var new_map : Array[Array]
	new_map.resize(_size)
	for x in _size:
		new_map[x].resize(_size)
		for z in _size:
			var neighbors : Array[int] = get_immediate_neighbors(x,z)
			var conversion_chance : float = 0
			var dry_neighbors : Array[int] = []
			for n in neighbors: 
				if n != 0: 
					conversion_chance += 1
					dry_neighbors.push_back(n)
			conversion_chance /= neighbors.size()
			if conversion_chance > randf():
				new_map[x][z] = dry_neighbors.pick_random()
			else:
				new_map[x][z] = _map[x][z]
	_map = new_map

func add_temperature() -> void:
	for x in _size:
		for z in _size:
			if _map[x][z] == 0: continue
			var n : int = randi() % 6
			if n <= 1:
				_map[x][z] += n # Creates half freezing 1 half cold 2
			else:
				_map[x][z] += 3 # Creates warm 4

func smooth_temperature() -> void:
	# turn warm into temperate
	var new_map : Array[Array]
	new_map.resize(_size)
	for x in _size:
		new_map[x].resize(_size)
		for z in _size:
			if _map[x][z] != 4: 
				new_map[x][z] = _map[x][z]
			else:
				new_map[x][z] = 4
				var neighbors = get_immediate_neighbors(x,z)
				for n in neighbors:
					if n <= 1:
						new_map[x][z] = 3
	_map = new_map
	# turn freezing into cold
	for x in _size:
		for z in _size:
			if _map[x][z] > 1 or _map[x][z] == 0: new_map[x][z] = _map[x][z]
			else:
				new_map[x][z] = 1
				var neighbors = get_immediate_neighbors(x,z)
				for n in neighbors:
					if n >= 3:
						new_map[x][z] = 2
	_map = new_map

func in_bounds(x : int, z : int) -> bool:
	return 0 <= x and x < _size and 0 <= z and z < _size

func get_value(x : int, z : int) -> int:
	if in_bounds(x,z): return _map[x][z]
	else: return -1

func set_value(x : int,z : int,value : int) -> void:
	if in_bounds(x,z):
		_map[x][z] = value

func get_size() -> int:
	return _size

func get_color(x : int, z : int) -> Color:
	if not in_bounds(x,z): return Color.BLACK
	match _map[x][z]:
		0: return Color.BLUE
		1: return Color.WHITE
		2: return Color.DARK_GREEN
		3: return Color.LIME_GREEN
		4: return Color.ORANGE_RED 
		_: return Color.BLACK

func zoom():
	var new_map : Array[Array]
	var new_size : int = 2 * _size
	new_map.resize(new_size)
	for x in new_size:
		new_map[x].resize(new_size)
		for z in new_size:
			if bleed_chance > randf():
				new_map[x][z] = _bleed(x / 2,z / 2)
			else:
				new_map[x][z] = _map[x / 2][z / 2]
	_size = new_size
	_map = new_map

func get_immediate_neighbors(x : int, z : int) -> Array[int]:
	var neighbors : Array[int]
	if in_bounds(x,z + 1): neighbors.push_back(_map[x][z + 1])
	if in_bounds(x,z - 1): neighbors.push_back(_map[x][z - 1])
	if in_bounds(x + 1,z): neighbors.push_back(_map[x + 1][z])
	if in_bounds(x - 1,z): neighbors.push_back(_map[x - 1][z])
	return neighbors

func get_diagonal_neighbors(x : int, z : int):
	var neighbors : Array[int]
	if in_bounds(x + 1,z + 1): neighbors.push_back(_map[x + 1][z + 1])
	if in_bounds(x - 1,z + 1): neighbors.push_back(_map[x - 1][z + 1])
	if in_bounds(x + 1,z - 1): neighbors.push_back(_map[x + 1][z - 1])
	if in_bounds(x - 1,z - 1): neighbors.push_back(_map[x - 1][z - 1])
	return neighbors

func get_all_neighbors(x : int, z : int):
	var neighbors = get_immediate_neighbors(x,z)
	neighbors.append_array(get_diagonal_neighbors(x,z))
	return neighbors

func _bleed(x : int, z : int) -> int:
	var random_direction : int = randi() % 4
	if random_direction % 2 == 0:
		if in_bounds(x, z + random_direction - 1): 
			return _map[x][z + random_direction - 1] 
		else: return _map[x][z + (random_direction - 1) * -1] 
	else: 
		if in_bounds(x + random_direction - 2,z): 
			return _map[x + random_direction - 2][z]
		else: return _map[x + (random_direction - 2) * -1][z]

func _to_string():
	var out : String = ""
	for x in _size:
		for z in _size:
			if _map[x][z] == 0:
				out += " "
			else:
				out += "X"#str(_map[x][z])
		out += "\n"
	return out
