class_name UIManager extends CanvasLayer

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		toggle_pause()
		for c in get_children():
			if c is InventoryUI:
				c.visible = !c.visible
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
