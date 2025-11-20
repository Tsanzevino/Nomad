extends Node

@export var biomeMap : BiomeMap
@export var minSize : int = 16
@export var maxSize : int = 16 * 16
@export var step : int = 16

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	biomeMap.setup(10)
	for size in range(minSize,maxSize,step):
		var start = Time.get_ticks_msec()
		biomeMap.generate_map(Vector3.ZERO, size)
		print(Time.get_ticks_msec() - start)
	print("done")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
