class_name BiomeLookupTable extends Resource

@export var resolution : int
@export var biomeIndexTable : Array[Biome]
@export var CSVPath : String
var table : Dictionary[Vector3i,Biome]

func lookup(t : float, h : float, c : float) -> Biome:
	if not table.has(resolve(t,h,c)): return biomeIndexTable[0]
	return table[resolve(t,h,c)]

func resolve(t : float, h : float, c : float) -> Vector3i:
	return Vector3i(floori(t * resolution),floori(h * resolution),floori(c * resolution))

func load_from_csv():
	var file := FileAccess.open(CSVPath,FileAccess.READ)
	for c in resolution:
		for h in resolution:
			var contents := file.get_csv_line()
			for t in resolution:
				table[Vector3i(t,h,c)] = biomeIndexTable[int(contents[t])]
	
