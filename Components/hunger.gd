class_name Hunger extends Node

@export var maxHunger : int
var hunger : int
var isStarving : bool


signal starving
signal stable
signal ate(amount : int)

func _ready() -> void:
	hunger = maxHunger

func _process(_delta: float) -> void:
	if isStarving and hunger != 0:
		isStarving = false
		stable.emit()
	if not isStarving and hunger == 0:
		isStarving = true
		starving.emit()

func eat(amount : int):
	hunger += amount
	ate.emit(amount)

func use(amount : int):
	hunger -= amount
	if hunger < 0: hunger = 0
