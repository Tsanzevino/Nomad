class_name InventoryItem extends Object

var item : Item
var count : int

## Creates the item with a default count of 0
func create_item(i : Item):
	item = i
	count = 0

func get_item_id() -> int:
	return item.id

func equals(i : Item) -> bool:
	return item.id == i.id

## Increases the inventory count and returns positive overflow
func increase_count(amount : int) -> int:
	# amount should never be negative
	if amount < 0 : print("InventoryItem has BAD NEWS: amount is negative")
	# Add the amount to count
	var newCount = count + amount
	var overflow = 0
	# If the new count exceeds the max stack size,
	# take the overflow and clamp to max stack size
	var maxStack : int = 1 if not (item is Stackable) else item.maxStackSize
	if (newCount > maxStack):
		overflow = newCount - maxStack
		newCount = maxStack
	count = newCount
	return overflow

## Decreases the inventory count and returns negative overflow
func decrease_count(amount : int) -> int:
	# amount should never be negative
	if amount < 0 : print("InventoryItem has BAD NEWS: amount is negative")
	# Subtract the amount from count
	var newCount = count - amount
	var overflow = 0
	# If the new count is negative, take its
	# overflow as positive and clamp the count
	if (newCount < 0):
		overflow = -newCount
		newCount = 0
	count = newCount
	return overflow
