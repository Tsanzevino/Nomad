## This Node loads Regions as the player moves through the world.
## A Region is a preloaded map of the heights and biomes to speed up
## region generation.
class_name RegionLoader extends Node3D

@export var regionRadius : int = 1
@export var threadCount : int = 2

var currentRegionCoords : Vector2i
var regionLoadingQueue : RegionLoadingQueue

var threads : Array[Thread]
var queueMutex : Mutex
var quit : bool = false

func _ready():
	# Create the loading queue
	regionLoadingQueue = RegionLoadingQueue.new()
	# Set up the threads
	setup_threads()
	# Generates the regions around the player before they spawn in
	generate_spawn()

## Creates the number of threads specified in threadCount,
## attaching them to run [code]load_from_queue()[/code]
func setup_threads():
	threads.resize(threadCount)
	queueMutex = Mutex.new()
	for i in threadCount:
		threads[i] = Thread.new()
		threads[i].start(load_from_queue)

## The threads' loading instructions
## Loads new regions on a loop while there are new regions to load
func load_from_queue():
	while(not quit):
		# Take from queue
		queueMutex.lock()
		if regionLoadingQueue.size() > 0:
			# Get the nearest region to load
			var newRegionCoords := regionLoadingQueue.pop(currentRegionCoords)
			queueMutex.unlock()
			# Load the region
			create_new_region(newRegionCoords)
		else: queueMutex.unlock()

## Before quitting, the threads must finish, so
## the threads are signalled and then waited on.
func _exit_tree():
	quit = true
	for i in threadCount:
		threads[i].wait_to_finish()

## Generates the regions initially surrounding the player
func generate_spawn():
	Stopwatch.start("Spawn Region Generation")
	currentRegionCoords = Vector2i(0,0)
	queueMutex.lock()
	for z in range(-regionRadius, regionRadius + 1):
		for x in range(-regionRadius, regionRadius + 1):
			regionLoadingQueue.push(Vector2i(x,z))
	var coords := regionLoadingQueue.pop(currentRegionCoords)
	queueMutex.unlock()
	RegionCache.set_region(coords,Region.new(coords))
	Stopwatch.stop("Spawn Region Generation")

func _physics_process(_delta):
	# Get the new region coordinates
	var newCoords := RegionCache.get_coordinates(global_position)
	# If they haven't changed, we can skip
	if newCoords == currentRegionCoords:
		return
	# Print the coordinates for debugging
	print("Region Coords: ",newCoords)
	# Get the direction the region changed in
	var moveDirection : Vector2i = newCoords - currentRegionCoords
	currentRegionCoords = newCoords
	# Its possible to move diagonally, and that has to be treated differently
	if moveDirection.length() > 1.1:
		update_loaded_regions(Vector2i(moveDirection.x, 0), currentRegionCoords - Vector2i(0, moveDirection.y))
		update_loaded_regions(Vector2i(0, moveDirection.y), currentRegionCoords)
	else:
		update_loaded_regions(moveDirection, currentRegionCoords)

func update_loaded_regions(moveDirection : Vector2i, coords : Vector2i):
	# Load new regions
	var xRange := [(moveDirection.x * regionRadius) + coords.x] if moveDirection.x != 0 \
		else range(-regionRadius + coords.x, regionRadius + coords.x + 1)
	var zRange := [(moveDirection.y * regionRadius) + coords.y] if moveDirection.y != 0 \
		else range(-regionRadius + coords.y, regionRadius + coords.y + 1)
	queueMutex.lock()
	for x in xRange:
		for z in zRange:
			var regionCoords := Vector2i(x,z)
			var region : Region = RegionCache.get_region(regionCoords)
			if region == null:
				# Need to generate a new region
				regionLoadingQueue.push(regionCoords)
	queueMutex.unlock()
	# Remove old regions
	xRange = [(-moveDirection.x * (regionRadius + 1)) + coords.x] if moveDirection.x != 0 else range(-regionRadius + coords.x, regionRadius + coords.x + 1)
	zRange = [(-moveDirection.y * (regionRadius + 1)) + coords.y] if moveDirection.y != 0 else range(-regionRadius + coords.y, regionRadius + coords.y + 1)
	queueMutex.lock()
	for x in xRange:
		for z in zRange:
			var remove := Vector2i(x,z)
			if regionLoadingQueue.has_region(remove):
				regionLoadingQueue.remove_region(remove)
	queueMutex.unlock()

func create_new_region(coords : Vector2i) -> void:
	var region := Region.new(coords)
	call_deferred("apply",region,coords)

func apply(region : Region, coords : Vector2i) -> void:
	RegionCache.set_region(coords,region)
