class_name InventoryUI extends MenuUI

var inventory : Inventory = preload("res://Player/PlayerInventory/inventory.tres")
var itemUI : PackedScene = preload("res://Inventory/InventoryItem/inventory_item_ui.tscn")

func _ready():
	for i in get_tree().get_nodes_in_group("Inventory"):
		i.inventory_updated.connect(update_UI)
	for n in range(inventory.items.size()):
		var invItemUI = itemUI.instantiate()
		invItemUI.change_count(0)
		invItemUI.change_image(null)
		%GridContainer.add_child(invItemUI)

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		if visible:
			exit()

func update_UI():
	var item : InventoryItem
	for n in range(inventory.items.size()):
		item = inventory.items[n]
		if item == null:
			%GridContainer.get_child(n).update_item(null, 0)
		else:
			%GridContainer.get_child(n).update_item(item.item.texture, item.count)
