extends MovementState

func physics_update(delta: float) -> void:
	# Perform State Movement
	player.velocity.x = lerpf(player.velocity.x, direction.x * AIR_SPEED, delta * AIR_FRICTION)
	player.velocity.z = lerpf(player.velocity.z, direction.z * AIR_SPEED, delta * AIR_FRICTION)
	player.move_and_slide()
	
	# Check to leave the state
	if player.is_on_floor():
		if direction.length() < DEADZONE_SIZE:
			finished.emit(IDLE)
		else:
			if Input.is_action_pressed("sprint"):
				finished.emit(SPRINTING)
			else:
				finished.emit(WALKING)
	elif not Input.is_action_pressed("jump"):
		finished.emit(FALLING)

func enter(_previous_state_path: String, _data := {}) -> void:
	player.velocity.y = JUMP_VELOCITY

func exit() -> void:
	pass
