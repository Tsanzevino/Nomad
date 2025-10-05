class_name InventoryUI extends MenuUI

#region Class Variables
var itemUI : PackedScene = preload("res://Inventory/InventoryItem/UI/inventory_item_ui.tscn")

var focusedItem : InventoryItemUI
var itemOnSelect : InventoryItemUI

var invMan : InventoryManager

#endregion

#region UI Interactions

func _process(_delta):
	if not visible: return
	if Input.is_action_just_pressed("inventory"):
		exit()
	if Input.is_action_just_pressed("select"):
		select_item()
	if Input.is_action_just_released("select"):
		swap_items()
	if Input.is_action_just_pressed("discard"):
		discard_item()

func swap_items():
	if focusedItem == itemOnSelect: return
	var invSlotA := get_inventory(focusedItem) if (focusedItem is InventoryUpgradeUI)\
			   else get_inventory(focusedItem.get_parent())
	var invSlotB := get_inventory(itemOnSelect) if (itemOnSelect is InventoryUpgradeUI)\
			   else get_inventory(itemOnSelect.get_parent())
	var indexA := focusedItem.get_index()
	var indexB := itemOnSelect.get_index()
	invMan.swap(invSlotA,invSlotB,indexA,indexB)
	update()

func setup(im : InventoryManager):
	invMan = im
	# Update the hotbar with the current inventory
	match_inventory_size(%Hotbar)
	match_inventory_size(%LeftPouchInventory)
	match_inventory_size(%RightPouchInventory)
	match_inventory_size(%PackInventory)

func select_item():
	itemOnSelect = focusedItem

func discard_item():
	var invSlotA := get_inventory(focusedItem) if (focusedItem is InventoryUpgradeUI)\
			   else get_inventory(focusedItem.get_parent())
	var indexA := focusedItem.get_index()
	invMan.discard_item(invSlotA,indexA)
	update()

func _on_change_focus(item : InventoryItemUI):
	focusedItem = item

#endregion

#region Utility

func match_inventory_size(node : Control):
	if get_inventory(node) < 0: return
	var inventory := invMan.inventories[get_inventory(node)]
	if inventory == null or inventory.size == 0:
		for c in node.get_children(): c.queue_free()
		return
	var diff : int = inventory.size - node.get_child_count()
	if diff >= 0:
		for n in range(diff): create_item_for_parent(node)
	else:
		for i in range(inventory.size, node.get_child_count()): node.get_child(i).queue_free()

func create_item_for_parent(parent : Control):
	var item : InventoryItemUI = itemUI.instantiate()
	item.focused.connect(_on_change_focus)
	parent.add_child(item)

func get_inventory(node : Control) -> InventoryManager.InvSlot:
	match node.name:
		"Hotbar":
			return InventoryManager.InvSlot.HOTBAR
		"LeftPouchInventory":
			return InventoryManager.InvSlot.LEFT_POUCH
		"RightPouchInventory":
			return InventoryManager.InvSlot.RIGHT_POUCH
		"PackInventory":
			return InventoryManager.InvSlot.PACK
		"LeftPouchSlot":
			return InventoryManager.InvSlot.LEFT_SLOT
		"RightPouchSlot":
			return InventoryManager.InvSlot.RIGHT_SLOT
		"PackSlot":
			return InventoryManager.InvSlot.PACK_SLOT
		_:
			return InventoryManager.InvSlot.HOTBAR

#endregion

#region Update
func update():
	check_inventory_sizes()
	for i in range(invMan.inventories.size()):
		if invMan.inventories[i] == null: continue
		var node = get_child(i)
		for n in range(invMan.inventories[i].size):
			update_item(invMan.inventories[i].items[n], node.get_child(n))
	
	var item : InventoryItem
	if invMan.leftSlot != null:
		item = InventoryItem.new()
		item.item = invMan.leftSlot
	else: item = null
	update_item(item, %LeftPouchSlot)
	if invMan.rightSlot != null:
		item = InventoryItem.new()
		item.item = invMan.rightSlot
	else: item = null
	update_item(item, %RightPouchSlot)
	if invMan.packSlot != null:
		item = InventoryItem.new()
		item.item = invMan.packSlot
	else: item = null
	update_item(item, %PackSlot)

func update_item(item : InventoryItem, invItemUI : InventoryItemUI):
	if item == null:
		invItemUI.update_item(null, 0)
	else:
		invItemUI.update_item(item.item.texture, item.count)

func check_inventory_sizes():
	match_inventory_size(%Hotbar)
	match_inventory_size(%LeftPouchInventory)
	match_inventory_size(%RightPouchInventory)
	match_inventory_size(%PackInventory)

#endregion
