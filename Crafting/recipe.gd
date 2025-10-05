class_name Recipe extends Resource

@export var results : Dictionary[Item, int]

@export var ingredients : Dictionary[Item, int]

@export var conditions : Array[Condition] = []

func is_craftable(inventory : Inventory) -> bool:
	if not passes_conditions():
		return false
	if not has_enough_items(inventory):
		return false
	return true

func passes_conditions() -> bool:
	for cond in conditions:
		if not cond.is_satisified():
			return false
	return true

func has_enough_items(inventory : Inventory) -> bool:
	for ingredient in ingredients.keys():
		if ingredients[ingredient] > inventory.count_item(ingredient):
			return false
	return true
