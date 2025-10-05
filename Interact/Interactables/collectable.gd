class_name Collectable extends Interactable

const HINT_Y_OFFSET : float = 0.2
const NAME_Y_OFFSET : float = 0.35

var hintLabel : Label3D
var nameLabel : Label3D

@export var hintStr : String = "Collect"
@export var item : Item

var countFunction := func(): return randi() % 5

func _enter_tree():
	add_to_group("Collectables")
	collision_layer = 128
	collision_mask = 8

func _ready():
	# Create the name label
	create_name()
	# Create the hint label
	create_hint()

func create_name():
	nameLabel = Label3D.new()
	nameLabel.text = item.name
	nameLabel.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	nameLabel.visible = false
	add_child(nameLabel)
	nameLabel.position.y += NAME_Y_OFFSET

func create_hint():
	hintLabel = Label3D.new()
	hintLabel.text = "[%s]" % hintStr
	hintLabel.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	hintLabel.visible = false
	add_child(hintLabel)
	hintLabel.position.y += HINT_Y_OFFSET

func interact(player : Player):
	# Give the player the item
	player.collect_item(item, countFunction.call())
	# Remove the interactable from the world
	queue_free()

func set_active():
	hintLabel.visible = false
	nameLabel.visible = true

func set_targetted():
	hintLabel.visible = true
	nameLabel.visible = true

func set_inactive():
	hintLabel.visible = false
	nameLabel.visible = false
