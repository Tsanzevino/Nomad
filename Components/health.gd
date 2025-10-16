class_name Health extends Node

@export_range(0,100,1,"or_greater") var maxHealth : int = 0
var health : int

signal healed
signal full_healed
signal damaged
signal died

func _ready() -> void:
	health = maxHealth

func heal(amount : int):
	health += amount
	if health >= maxHealth: full_heal()
	else: healed.emit()

func damage(amount : int):
	health -= amount
	if health <= 0: die()
	else: damaged.emit()

func full_heal():
	health = maxHealth
	full_healed.emit()

func die():
	health = 0
	died.emit()
