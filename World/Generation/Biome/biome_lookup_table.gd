## A Biome Lookup Table is used to map temperature, humidity, and continentalness to a specific biome.
## A B.L.T. is specified in a CSV file, with resolution columns and resolution ^ 2 rows. Using the index
## of the biome from the Biomes array to indicate which biomes go where.
class_name BiomeLookupTable extends Resource

## The number of descrete values each parameter can take. For example, 
## a resolution of 6 means that temperature can be any value from 0-5, 
## and the noise value will be discretized evenly between these values.
@export var resolution : int
## The biome list used for this B.L.T.
@export var biomes : Array[Biome]
## The path to the CSV representation of the B.L.T.
@export var CSVPath : String

## The B.L.T. that was loaded in from the CSV file.
var table : Dictionary[Vector3i,Biome]

## Sets the seed of all biomes in the table.
func set_seed(biomeSeed : int) -> void:
	for b in biomes:
		b.set_seed(biomeSeed)

## Turns the T.H.C. values into a biome using the B.L.T.
func lookup(t : float, h : float, c : float) -> Biome:
	if not table.has(resolve(t,h,c)): return biomes[0]
	return table[resolve(t,h,c)]

## Discretizes the T.H.C. values to fit within the table resolution.
func resolve(t : float, h : float, c : float) -> Vector3i:
	return Vector3i(floori(t * resolution),floori(h * resolution),floori(c * resolution))

## Loads the table in from the CSV file.
func load_from_csv() -> void:
	var file := FileAccess.open(CSVPath,FileAccess.READ)
	for c in resolution:
		for h in resolution:
			var contents := file.get_csv_line()
			for t in resolution:
				table[Vector3i(t,h,c)] = biomes[int(contents[t])]
	
