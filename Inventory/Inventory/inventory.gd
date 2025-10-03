class_name Inventory extends Object

var items : Array[InventoryItem]
var size : int
var selectedItem : int

func _init(s : int = 1):
	size = s
	items.resize(size)
	selectedItem = -1

## Counts how many of each item are in the inventory.
## Returns an array with the counts of each item.
func count_items(checkItems : Array[Item]) -> Array[int]:
	var counts : Array[int] = []
	counts.resize(checkItems.size())
	for i in range(checkItems.size()):
		counts[i] = count_item(checkItems[i])
	return counts

## Counts how many of an item are in the inventory.
## Returns the count.
func count_item(item : Item) -> int:
	var amtInInventory : int = 0
	var i : InventoryItem
	for n in range(items.size()):
		i = items[n]
		if i != null and i.equals(item):
			amtInInventory += i.count
	return amtInInventory

func sort():
	items.sort_custom(compare)

func compare(a : InventoryItem, b : InventoryItem) -> bool:
	if a == null: return false
	if b == null: return true
	if a.get_item_id() < b.get_item_id(): return true
	elif a.get_item_id() == b.get_item_id(): return a.count > b.count
	return false
