class_name Item extends Resource

@export var name : String = ""
@export var texture : Texture2D
@export var maxStackSize : int = 16
@export var id : int = 0

func equals(item : Item) -> bool:
	return item.id == id
