class_name InventoryUI extends MenuUI

var itemUI : PackedScene = preload("res://Inventory/InventoryItem/UI/inventory_item_ui.tscn")

var focusedItem : InventoryItemUI
var itemOnSelect : InventoryItemUI

var invMan : InventoryManager

func _ready():
	# Get the Inventory manager from the scene
	invMan = get_tree().get_nodes_in_group("Inventory")[0]
	invMan.inventory_updated.connect(update_UI)
	# Update the hotbar with the current inventory
	for n in range(invMan.hotbar.size):
		create_item(%Hotbar)


func resize_left_pouch():
	for n in range(invMan.leftPouch.size):
		create_item(%LeftPouchInventory)

func resize_right_pouch():
	for n in range(invMan.rightPouch.size):
		create_item(%RightPouchItem)

func resize_pack():
	for n in range(invMan.pack.size):
		create_item(%PackInventory)

func create_item(parent : Control):
	var item : InventoryItemUI = itemUI.instantiate()
	item.focused.connect(_on_change_focus)
	parent.add_child(item)

func _process(_delta):
	if not visible: return
	if Input.is_action_just_pressed("inventory"):
		%Hotbar.get_child(0).grab_focus()
		exit()
	if Input.is_action_just_pressed("select"):
		print("selected")
		select_item()
	if Input.is_action_just_released("select"):
		print("deselected")
		swap_items()

func update_UI():
	for n in range(invMan.hotbar.size):
		update_item(invMan.hotbar.items[n], %Hotbar.get_child(n))
	var item = InventoryUpgradeItem.new()
	if invMan.leftSlot != null:
		item.item = invMan.leftSlot
		update_item(item, %LeftPouchItem)
	if invMan.rightSlot != null:
		item.item = invMan.rightSlot
		update_item(item, %RightPouchItem)
	if invMan.packSlot != null:
		item.item = invMan.packSlot
		update_item(item, %PackItem)

func update_item(item : InventoryItem, invItemUI : InventoryItemUI):
	if item == null:
		invItemUI.update_item(null, 0)
	else:
		invItemUI.update_item(item.item.texture, item.count)

func swap_items():
	if focusedItem == itemOnSelect: return
	if focusedItem is InventoryUpgradeUI and itemOnSelect is InventoryUpgradeUI:
		# Swap two upgrades
		swap_upgrades()
	elif not (focusedItem is InventoryUpgradeUI or itemOnSelect is InventoryUpgradeUI):
		# Swap from two inventories
		swap_from_inventories()
	else:
		# One of them is an inventory
		if focusedItem is InventoryUpgradeUI:
			swap_upgrade(focusedItem, itemOnSelect)
		else:
			swap_upgrade(itemOnSelect, focusedItem)
	print("Swapped")
	update_UI()

func swap_upgrade(to : InventoryItemUI, from : InventoryItemUI):
	var temp : InventoryUpgrade
	var aInv : Inventory = get_inventory(from.get_parent())
	var aIndex : int = from.get_index()
	if aInv.items[aIndex] == null:
		print("is null")
		return
	if to.name == "PackItem":
		if aInv.items[aIndex].item is Pack:
			temp = invMan.packSlot
			invMan.packSlot = aInv.items[aIndex].item
			if temp == null:
				aInv.items[aIndex] = null
				return
			var item = InventoryUpgradeItem.new()
			item.create_item(temp)
			aInv.items[aIndex] = item
	if aInv.items[aIndex].item is Pouch:
		if to.name == "LeftPouchItem":
			temp = invMan.leftSlot
			invMan.leftSlot = aInv.items[aIndex].item
			if temp == null:
				aInv.items[aIndex] = null
				return
			var item = InventoryUpgradeItem.new()
			item.create_item(temp)
			aInv.items[aIndex] = item
		elif to.name == "RightPouchItem":
			temp = invMan.rightSlot
			invMan.rightSlot = aInv.items[aIndex].item
			if temp == null:
				aInv.items[aIndex] = null
				return
			var item = InventoryUpgradeItem.new()
			item.create_item(temp)
			aInv.items[aIndex] = item

func swap_from_upgrade():
	if itemOnSelect.name == "PackItem":
		pass
	else:
		pass

func swap_upgrades():
	if focusedItem.name == "PackItem" or itemOnSelect.name == "PackItem":
		print("cannot insert pack upgrade into pouch upgrade or vice versa")
		return
	var temp = invMan.leftSlot
	invMan.leftSlot = invMan.rightSlot
	invMan.rightSlot = temp

func swap_from_inventories():
	var aInv := get_inventory(itemOnSelect.get_parent())
	var bInv := get_inventory(focusedItem.get_parent())
	var aIndex := itemOnSelect.get_index()
	var bIndex := focusedItem.get_index()
	# Do the swap
	var temp = aInv.items[aIndex]
	aInv.items[aIndex] = bInv.items[bIndex]
	bInv.items[bIndex] = temp
	update_UI()

func get_inventory(node : Control) -> Inventory:
	match node.name:
		"Hotbar":
			return invMan.hotbar
		"LeftPouchInventory":
			return invMan.leftPouch.inventory
		"RightPouchInventory":
			return invMan.rightPouch.inventory
		"PackInventory":
			return invMan.pack.inventory
		_:
			return null

func select_item():
	itemOnSelect = focusedItem

func _on_change_focus(item : InventoryItemUI):
	focusedItem = item
