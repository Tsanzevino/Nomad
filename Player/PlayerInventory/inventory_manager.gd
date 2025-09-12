class_name InventoryManager extends Node3D

var inventory : Inventory = preload("res://Player/PlayerInventory/inventory.tres")
@export var size : int = 12

signal inventory_updated

func _ready():
	inventory.items.resize(size)
	print(inventory.items.size())
	for i in get_tree().get_nodes_in_group("Collectables"):
		i.collect_item.connect(collect_item)

func _process(_delta):
	if Input.is_action_just_pressed("sort"):
		sort()

func resize_inventory(newSize : int):
	size = newSize
	inventory.items.resize(newSize)
	inventory_updated.emit()

func collect_item(item : Item, amount : int) -> int:
	# First pass pairs items with existing stacks
	var i : InventoryItem
	for n in range(size):
		i = inventory.items[n]
		if i != null and i.equals(item):
			amount = i.increase_count(amount)
			if amount == 0:
				inventory_updated.emit()
				return 0
	# Second pass puts items in null slots
	for n in range(size):
		i = inventory.items[n]
		if i == null:
			i = create_inventory_item(item)
			amount = i.increase_count(amount)
			inventory.items[n] = i
			if amount == 0:
				inventory_updated.emit()
				return 0
	inventory_updated.emit()
	return amount

func use_item(item : Item, amount : int) -> bool:
	if not validate_item_count(item, amount):
		print("Failed to use item %s: not enough in inventory" % item.name)
		return false
	var i : InventoryItem
	for n in range(size):
		i = inventory.items[n]
		if i != null and i.equals(item):
			amount = i.decrease_count(amount)
			if i.count == 0:
				inventory.items[n] = null
			if amount == 0:
				inventory_updated.emit()
				return true
	inventory_updated.emit()
	return true

## Validates that the inventory contains the
## specified amounts of a list of items.
func validate_item_counts(items : Array[Item], amounts : Array[int]) -> bool:
	if items.size() != amounts.size(): 
		print("Validation failed: item and amount arrays differ in size")
		return false
	for i in range(items.size()):
		if not validate_item_count(items[i], amounts[i]): return false
	return true

## Validates that the inventory contains the
## specified amount of a certain item.
func validate_item_count(item : Item, amount : int) -> bool:
	var amtInInventory : int = 0
	var i : InventoryItem
	for n in range(size):
		i = inventory.items[n]
		if i != null and i.equals(item):
			amtInInventory += i.count
	return amtInInventory >= amount

func sort():
	inventory.items.sort_custom(compare)
	inventory_updated.emit()

func compare(a : InventoryItem, b : InventoryItem) -> bool:
	if a == null:
		return false
	if b == null:
		return true
	if a.get_item_id() < b.get_item_id():
		return true
	elif a.get_item_id() == b.get_item_id():
		return a.count > b.count
	return false

## Creates an InventoryItem from the given Item
func create_inventory_item(item : Item) -> InventoryItem:
	var invItem : InventoryItem = InventoryItem.new()
	invItem.create_item(item)
	return invItem
