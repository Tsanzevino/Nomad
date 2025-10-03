class_name InventoryManager extends Node

@export var hotbarSize : int = 4
var hotbar : Inventory
var leftSlot : Pouch
var rightSlot : Pouch
var packSlot : Pack

signal inventory_updated

func _ready():
	hotbar = Inventory.new(hotbarSize)
	for i in get_tree().get_nodes_in_group("Collectables"):
		i.collect_item.connect(collect_item)

func _process(_delta):
	if Input.is_action_just_pressed("sort"):
		sort()

func sort():
	hotbar.sort()
	if leftSlot != null:
		leftSlot.inventory.sort()
	if rightSlot != null:
		rightSlot.inventory.sort()
	if packSlot != null:
		packSlot.inventory.sort()
	inventory_updated.emit()

func collect_item(item : Item, amount : int) -> int:
	amount = collect_item_in(item, amount, hotbar)
	if leftSlot != null and amount > 0:
		amount = collect_item_in(item, amount, leftSlot.inventory)
	if rightSlot != null and amount > 0:
		amount = collect_item_in(item, amount, rightSlot.inventory)
	if packSlot != null and amount > 0:
		amount = collect_item_in(item, amount, packSlot.inventory)
	return amount

func collect_item_in(item : Item, amount : int, inventory : Inventory) -> int:
	# First pass pairs items with existing stacks
	var i : InventoryItem
	for n in range(inventory.size):
		i = inventory.items[n]
		if i != null and i.equals(item):
			amount = i.increase_count(amount)
			if amount == 0:
				inventory_updated.emit()
				return 0
	# Second pass puts items in null slots
	for n in range(inventory.size):
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

func consume_item(item : Item, amount : int) -> bool:
	# First check that there is enough of item
	var amtInInventory : int = hotbar.count_item(item)
	if leftSlot != null and amtInInventory < amount:
		amtInInventory += leftSlot.inventory.count_item(item)
	if rightSlot != null and amtInInventory < amount:
		amtInInventory += rightSlot.inventory.count_item(item)
	if packSlot != null and amtInInventory < amount:
		amtInInventory += packSlot.inventory.count_item(item)
	if amtInInventory < amount:
		return false
	# Then consume the required amount
	amount = consume_item_from(item, amount, hotbar)
	if leftSlot != null and amount > 0:
		amount = consume_item_from(item, amount, leftSlot.inventory)
	if rightSlot != null and amount > 0:
		amount = consume_item_from(item, amount, rightSlot.inventory)
	if packSlot != null and amount > 0:
		amount = consume_item_from(item, amount, packSlot.inventory)
	return true

func consume_item_from(item : Item, amount : int, inventory : Inventory) -> int:
	var i : InventoryItem
	for n in range(inventory.size):
		i = inventory.items[n]
		if i != null and i.equals(item):
			amount = i.decrease_count(amount)
			if i.count == 0:
				inventory.items[n] = null
			if amount == 0:
				inventory_updated.emit()
				return amount
	inventory_updated.emit()
	return amount

## Creates an InventoryItem from the given Item
func create_inventory_item(item : Item) -> InventoryItem:
	var invItem : InventoryItem = InventoryItem.new()
	invItem.create_item(item)
	return invItem
