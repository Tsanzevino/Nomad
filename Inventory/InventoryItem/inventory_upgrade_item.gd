class_name InventoryUpgradeItem extends InventoryItem

## Creates the item with a default count of 0
func create_item(i : Item):
	item = i
	count = 1

func get_item_id() -> int:
	return item.id

func equals(_i : Item) -> bool:
	return false
