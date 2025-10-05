class_name RecipeManager extends Node

@export var recipes : Array[Recipe]

func find_simple_recipe(item : InventoryItem) -> Recipe:
	var tempInv = Inventory.new(1)
	tempInv.items[0] = item
	for recipe in recipes:
		if recipe.is_craftable(tempInv):
			return recipe
	return null
