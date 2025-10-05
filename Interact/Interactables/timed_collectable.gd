class_name TimedCollectable extends Collectable

@export var lifetime : float = 30

func _ready():
	# Create the name label
	create_name()
	# Create the hint label
	create_hint()
	#Create Lifetime timer
	create_lifetime_timer()

func create_lifetime_timer():
	if lifetime > 0:
		var timer := get_tree().create_timer(lifetime)
		timer.timeout.connect(func(): queue_free())
