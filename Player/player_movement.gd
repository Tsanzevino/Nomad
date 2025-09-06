extends CharacterBody3D

const GRAVITY : float = 9.8
const JUMP_VELOCITY : float = 5.0
const WALK_SPEED : float = 5.0
const SPRINT_SPEED : float = 10.0

func _process(delta):
	# Jump and gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Move Character in the direction of the camera
	var input_dir : Vector2 = Input.get_vector("move_left","move_right","move_forward","move_backward")
	var direction : Vector3 = global_basis * Vector3(input_dir.x, 0.0, input_dir.y)
	direction = Vector3(direction.x, 0, direction.z).normalized()
	if Input.is_action_pressed("sprint"):
		velocity.x = direction.x * SPRINT_SPEED
		velocity.z = direction.z * SPRINT_SPEED
	else:
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	
	# Rotate the character to point in the direction of the movement
	if (%ThirdPersonCamera.spring_length != 0.0):
		if (direction.length() > 0):
			%Pivot.look_at(position + direction)
	else:
		%Pivot.basis = Basis()
	# Apply the velocities
	move_and_slide()

func get_forward() -> Vector3:
	var camForward : Vector3 = %ThirdPersonCamera.get_camera_forward()
	if (%ThirdPersonCamera.spring_length == 0.0):
		return camForward
	else:
		# Correct this to account for pivot
		return camForward
