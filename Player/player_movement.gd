extends CharacterBody3D

const GRAVITY : float = 20.0
const JUMP_VELOCITY : float = 8.0
const WALK_SPEED : float = 3.0
const SPRINT_SPEED : float = 6.0
const GROUND_FRICTION : float = 15
const AIR_FRICTION : float = 3

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
	# Apply sprint
	if Input.is_action_pressed("sprint"):
		direction *= SPRINT_SPEED
	else:
		direction *= WALK_SPEED
	
	if is_on_floor():
		velocity.x = lerpf(velocity.x, direction.x, delta * GROUND_FRICTION)
		velocity.z = lerpf(velocity.z, direction.z, delta * GROUND_FRICTION)
	else:
		velocity.x = lerpf(velocity.x, direction.x, delta * AIR_FRICTION)
		velocity.z = lerpf(velocity.z, direction.z, delta * AIR_FRICTION)
	
	# Rotate the character to point in the direction of the movement
	if (%ThirdPersonCamera.spring_length != 0.0):
		if (direction.length () > 0):
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
