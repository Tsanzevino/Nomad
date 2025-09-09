class_name Plant extends Interactable

const HINT_Y_OFFSET : float = 0.2
const NAME_Y_OFFSET : float = 0.35

var hintLabel : Label3D
var nameLabel : Label3D

@export var nameStr : String = ""
@export var hintStr : String = "Collect"

func _ready():
	collision_layer = 128
	collision_mask = 8
	# Create the name label
	nameLabel = Label3D.new()
	nameLabel.text = nameStr
	nameLabel.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	nameLabel.visible = false
	add_child(nameLabel)
	nameLabel.position.y += NAME_Y_OFFSET
	# Create the hint label
	hintLabel = Label3D.new()
	hintLabel.text = "[%s]" % hintStr
	hintLabel.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	hintLabel.visible = false
	add_child(hintLabel)
	hintLabel.position.y += HINT_Y_OFFSET

func interact():
	# Remove the interactable from the world
	queue_free()
	# Give the player the item

func set_active():
	hintLabel.visible = false
	nameLabel.visible = true

func set_targetted():
	hintLabel.visible = true
	nameLabel.visible = true

func set_inactive():
	hintLabel.visible = false
	nameLabel.visible = false
