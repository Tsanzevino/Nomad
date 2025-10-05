extends MovementState

func physics_update(delta: float) -> void:
	# Perform State Movement
	player.velocity.x = lerpf(player.velocity.x, direction.x * SPRINT_SPEED, delta * GROUND_FRICTION)
	player.velocity.z = lerpf(player.velocity.z, direction.z * SPRINT_SPEED, delta * GROUND_FRICTION)
	player.move_and_slide()
	
	# Check to leave the state
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_pressed("jump"):
		finished.emit(JUMPING)
	elif direction.length() < DEADZONE_SIZE:
		finished.emit(IDLE)
	elif not Input.is_action_pressed("sprint"):
		finished.emit(WALKING)

func enter(_previous_state_path: String, _data := {}) -> void:
	pass

func exit() -> void:
	pass
