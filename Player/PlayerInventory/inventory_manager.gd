class_name InventoryManager extends Node

#region Class Variables

@export var ui : InventoryUI
@export var hotbarSize : int = 4

## Inventory Slot enumerator.
## Positive values represent inventories.
## Negative values represent slots independent from inventories.

enum InvSlot{HOTBAR = 0, LEFT_POUCH = 1, RIGHT_POUCH = 2, PACK = 3, LEFT_SLOT = -1, RIGHT_SLOT = -2, PACK_SLOT = -3}

var inventories : Array[Inventory] = [null, null, null, null]

var leftSlot : Pouch
var rightSlot : Pouch
var packSlot : Pack

#endregion

#region Setup

func _ready():
	inventories[InvSlot.HOTBAR] = Inventory.new(hotbarSize)
	setup_ui()

func setup_ui():
	ui.setup(self)
	
#endregion

#region Inventory Actions

func _process(_delta):
	if Input.is_action_just_pressed("sort"):
		sort()

func sort():
	for i in range(inventories.size()):
		if inventories[i] != null:
			inventories[i].sort()
	ui.update()
	
#endregion

#region Inventory Utilities

## Puts [param amount] of [param item] into whatever inventory it can.
## Returns the amount that didn't fit.
func collect_item(item : Item, amount : int) -> int:
	for i in range(inventories.size()):
		if inventories[i] != null and amount > 0:
			amount = collect_item_in(item, amount, inventories[i])
	ui.update()
	return amount

## Puts [param amount] of [param item] in the specified inventory.
## Returns the amount that didn't fit.
func collect_item_in(item : Item, amount : int, inventory : Inventory) -> int:
	# First pass pairs items with existing stacks
	var i : InventoryItem
	for n in range(inventory.size):
		i = inventory.items[n]
		if i != null and i.equals(item):
			amount = i.increase_count(amount)
			if amount == 0: return 0
	# Second pass puts items in null slots
	for n in range(inventory.size):
		i = inventory.items[n]
		if i == null:
			i = create_inventory_item(item)
			amount = i.increase_count(amount)
			inventory.items[n] = i
			if amount == 0: return 0
	return amount

## Removes the [param amount] of [param item] from whatever inventory it can.
## Removes nothing if there isn't enough [param item].
## Returns [code]false[/code] if nothing was removed.
func consume_item(item : Item, amount : int) -> bool:
	# First check that there is enough of item
	var amtInInventory : int = 0
	for i in range(inventories.size()):
		if inventories[i] != null:
			amtInInventory += inventories[i].count_item(item)
		if amtInInventory >= amount: break
	if amtInInventory < amount: return false
	# Then consume the required amount
	for i in range(inventories.size()):
		if inventories[i] != null:
			amount = consume_item_from(item, amount, inventories[i])
		if amount <= 0: break
	ui.update()
	return true

## Removes the [param amount] of [param item] from the specified inventory.
## Returns however much still needs removed.
func consume_item_from(item : Item, amount : int, inventory : Inventory) -> int:
	var i : InventoryItem
	for n in range(inventory.size):
		i = inventory.items[n]
		if i != null and i.equals(item):
			amount = i.decrease_count(amount)
			if i.count == 0: inventory.items[n] = null
			if amount == 0: break
	return amount

## Creates an InventoryItem from the given Item
func create_inventory_item(item : Item) -> InventoryItem:
	if item == null: return null
	var invItem : InventoryItem = InventoryItem.new()
	invItem.create_item(item)
	return invItem

## Returns the requested Slot.
## The value returned is an inventory if its positive,
## or an equipment slot otherwise.
func get_slot(invSlot : InvSlot):
	match invSlot :
		InvSlot.LEFT_SLOT:
			return leftSlot
		InvSlot.RIGHT_SLOT:
			return rightSlot
		InvSlot.PACK_SLOT:
			return packSlot
		_:
			return inventories[invSlot]

## Sets the value of the requested slot.
## Does nothing for inventories
func set_equipment_slot(invSlot : InvSlot, value : Item):
	if invSlot > 0: return
	match invSlot:
		InvSlot.LEFT_SLOT:
			leftSlot = value
		InvSlot.RIGHT_SLOT:
			rightSlot = value
		InvSlot.PACK_SLOT:
			packSlot = value

func update_inventory_upgrades():
	update_inventory_upgrade(InvSlot.LEFT_POUCH, leftSlot)
	update_inventory_upgrade(InvSlot.RIGHT_POUCH, rightSlot)
	update_inventory_upgrade(InvSlot.PACK, packSlot)

func update_inventory_upgrade(index : int, upgrade : InventoryUpgrade):
	if upgrade == null:
		if inventories[index] == null:
			return
		for i in inventories[index].items:
			if i != null: spawn_item(i.item, i.count)
		inventories[index] = null
	elif inventories[index] == null:
		inventories[index] = Inventory.new(upgrade.size)
	elif (inventories[index].size != upgrade.size):
		resize_inventory(inventories[index], upgrade.size)

func resize_inventory(inventory : Inventory, size : int):
	if size < inventory.size:
		for i in range(size, inventory.size):
			if inventory.items[i] != null: spawn_item(inventory.items[i].item, inventory.items[i].count)
	inventory.size = size
	inventory.items.resize(size)
	print("new size %d" % inventory.items.size())

func spawn_item(item : Item, amount : int = 1):
	if item == null: return
	get_child(0).spawn(item,amount)

#endregion

#region UI Interactions

func swap(invSlotA : InvSlot, invSlotB : InvSlot, indexA : int = -1, indexB : int = -1):
	if invSlotA < 0 and invSlotB < 0:
		# Swap two upgrades
		swap_equipment(invSlotA, invSlotB)
	elif invSlotA >= 0 and invSlotB >= 0:
		# Swap from two inventories
		swap_from_inventories(invSlotA, invSlotB, indexA, indexB)
	else:
		# One of them is an inventory
		if invSlotA < 0:
			swap_equipment_and_inventory(invSlotA, invSlotB, indexB)
		else:
			swap_equipment_and_inventory(invSlotB, invSlotA, indexA)
	update_inventory_upgrades()

func swap_from_inventories(invSlotA : InvSlot, invSlotB : InvSlot, indexA : int = -1, indexB : int = -1):
	var temp = inventories[invSlotA].items[indexA]
	inventories[invSlotA].items[indexA] = inventories[invSlotB].items[indexB]
	inventories[invSlotB].items[indexB] = temp

func swap_equipment(equipSlotA : InvSlot, equipSlotB : InvSlot):
	if equipSlotA == InvSlot.PACK_SLOT or equipSlotB == InvSlot.PACK_SLOT:
		print("Cannot swap to Pack Slot: Item invalid")
		return
	var temp = leftSlot
	leftSlot = rightSlot
	rightSlot = temp

func swap_equipment_and_inventory(equipSlot : InvSlot, invSlot : InvSlot, index : int = -1):
	var inv : Inventory = inventories[invSlot]
	if inv.items[index] == null:
		if not get_slot(equipSlot) == null:
			inv.items[index] = create_inventory_item(get_slot(equipSlot))
			inv.items[index].count = 1
			set_equipment_slot(equipSlot, null)
			return true
		return false
	# Item is not null, slot may be null, item may be wrong type
	if item_fits_in_slot(inv.items[index].item, equipSlot):
		if get_slot(equipSlot) == null:
			set_equipment_slot(equipSlot, inv.items[index].item)
			inv.items[index] = null
			return true
		else:
			var temp = create_inventory_item(get_slot(equipSlot))
			temp.count = 1
			set_equipment_slot(equipSlot, inv.items[index].item)
			inv.items[index] = temp
			return true
	return false

func item_fits_in_slot(item : Item, slot : InvSlot) -> bool:
	if (slot == InvSlot.LEFT_SLOT or slot == InvSlot.RIGHT_SLOT) and (item is Pouch):
		return true
	if (slot == InvSlot.PACK_SLOT) and (item is Pack):
		return true
	return false

func discard_item(invSlotA : InvSlot, indexA : int = -1):
	if invSlotA < 0:
		spawn_item(get_slot(invSlotA))
		set_equipment_slot(invSlotA, null)
		update_inventory_upgrades()
	else:
		spawn_item(inventories[invSlotA].items[indexA].item, inventories[invSlotA].items[indexA].count)
		inventories[invSlotA].items[indexA] = null

#endregion
