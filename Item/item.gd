@icon("res://Item/item_icon.png")
class_name Item extends Resource

@export var name : String = ""
@export var texture : Texture2D
@export var id : int = 0

func equals(item : Item) -> bool:
	return item.id == id
