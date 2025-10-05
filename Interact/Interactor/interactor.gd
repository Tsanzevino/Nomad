class_name Interactor extends Area3D

const MAX_DOT : float = 0.985
var targets : Array[Interactable] = []
var bestTarget : Interactable

func _ready():
	collision_layer = 8
	collision_mask = 128
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta : float):
	if (Input.is_action_just_pressed("interact")):
		if bestTarget != null:
			bestTarget.interact(owner)

func _physics_process(_delta : float):
	var newBestTarget : Interactable = get_best_target()
	if bestTarget == newBestTarget:
		return
	if bestTarget != null:
		bestTarget.set_active()
		pass
	if newBestTarget != null:
		newBestTarget.set_targetted()
		pass
	bestTarget = newBestTarget

func _on_area_entered(area):
	#Toggle color/indicator for interactable objects
	if area is not Interactable:
		return
	area.set_active()
	targets.append(area as Interactable)

func _on_area_exited(area):
	#Toggle color/indicator for interactable objects
	if area is not Interactable:
		return
	area.set_inactive()
	if area == bestTarget:
		bestTarget = null
	targets.remove_at(targets.find(area))

func get_best_target() -> Interactable:
	var forward : Vector3 = owner.get_forward()
	var newTarget : Interactable = null
	var highest_dot : float = MAX_DOT
	for target : Interactable in targets:
		# Creating Variables for readability.
		var targetPos : Vector3 = target.global_position
		var targetDirection = global_position.direction_to(targetPos)
		var dot := forward.dot(targetDirection)
		if dot > highest_dot:
			# Create a raycast to check if the pathway is clear
			# to the grappling point
			var ray : RayCast3D = RayCast3D.new()
			ray.target_position = targetPos - global_position
			ray.collision_mask = 1
			add_child(ray)
			ray.global_basis = Basis()
			ray.force_raycast_update()
			remove_child(ray)
			# Checks if clear before continuing
			if (!ray.is_colliding()):
				# Calculating the dot product from the forward vector of the camera
				# to the direction from player to target.
				# This dot product will be 1.0 if the player is looking directly
				# at the target.
				highest_dot = dot
				newTarget = target
	return newTarget
