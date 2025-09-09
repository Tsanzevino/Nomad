class_name InventoryItemUI extends PanelContainer

func update_item(image : Texture2D, count : int):
	change_image(image)
	change_count(count)

func change_image(image : Texture2D):
	if image == null: 
		%Image.texture = null
		return
	%Image.texture = image

func change_count(count : int):
	if count == 0:
		%Count.text = ""
		return
	%Count.text = str(count)
