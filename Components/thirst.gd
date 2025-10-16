class_name Thirst extends Node

@export var dehydrationThreshold : int
@export var hyperhydrationThreshold : int
@export var thirstTickUse : int = 1
@export_range(0.0,1.0,0.01,"or_greater") var thirstTickRate : float = 0.2

var hydration : int
var thirstTick : float = 0.0

signal dehydrated
signal hyperhydrated
signal stable
signal drank(amount : int)

func _process(delta: float) -> void:
	thirstTick += delta * thirstTickRate
	if thirstTick < 1.0: return
	thirstTick = 0.0
	use(thirstTickUse)
	evaluate_hydration()
	

func _ready() -> void:
	hydration = hyperhydrationThreshold

func drink(amount : int):
	hydration += amount
	drank.emit(amount)

func use(amount : int):
	hydration -= amount
	if hydration < 0: hydration = 0

func evaluate_hydration():
	if hydration <= dehydrationThreshold: dehydrated.emit()
	elif hydration > hyperhydrationThreshold: hyperhydrated.emit()
	else: stable.emit()
