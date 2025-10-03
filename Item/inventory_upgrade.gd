class_name InventoryUpgrade extends Item

@export var size : int = 1

var inventory : Inventory = null

func _init():
	inventory = Inventory.new(size)

func equals(_item : Item) -> bool:
	return false
