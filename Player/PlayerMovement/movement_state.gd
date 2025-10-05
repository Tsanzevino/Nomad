@abstract class_name MovementState extends State

const GRAVITY : float = 20.0
const JUMP_VELOCITY : float = 8.0
const WALK_SPEED : float = 10.0
const SPRINT_SPEED : float = 40.0
const AIR_SPEED : float = 20.0
const GROUND_FRICTION : float = 15
const AIR_FRICTION : float = 3
const DEADZONE_SIZE : float = 0.1

const FALLING := "Falling"
const IDLE := "Idle"
const JUMPING := "Jumping"
const SPRINTING := "Sprinting"
const WALKING := "Walking"

var player : CharacterBody3D
var direction : Vector3

func handle_input(_event: InputEvent) -> void: pass

func update(_delta : float) -> void:
	var input_dir : Vector2 = Input.get_vector("move_left","move_right","move_forward","move_backward")
	direction = player.global_basis * Vector3(input_dir.x, 0.0, input_dir.y)
	direction = Vector3(direction.x, 0, direction.z).normalized()
