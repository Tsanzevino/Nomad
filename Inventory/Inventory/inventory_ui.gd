class_name InventoryUI extends Control

var inventory : Inventory = preload("res://Player/PlayerInventory/inventory.tres")
var itemUI : PackedScene = preload("res://Inventory/InventoryItem/inventory_item_ui.tscn")

func _ready():
	for n in range(inventory.items.size()):
		var invItemUI = itemUI.instantiate()
		invItemUI.change_count(0)
		invItemUI.change_image(null)
		%GridContainer.add_child(invItemUI)


func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		update_UI()
	if Input.is_action_just_pressed("use_item"):
		update_UI()

func update_UI():
	var item : InventoryItem
	for n in range(inventory.items.size()):
		item = inventory.items[n]
		if item == null:
			%GridContainer.get_child(n).update_item(null, 0)
		else:
			%GridContainer.get_child(n).update_item(item.item.texture, item.count)
