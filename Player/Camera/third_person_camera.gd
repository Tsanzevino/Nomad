extends SpringArm3D

const sensitivity_scale : float = 0.1
const pitch_limit : float = 80.0

# Camera Settings
@export var sensitivity : float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var controller = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	var input : Vector2 = controller * sensitivity * delta
	
	(get_parent() as Node3D).rotation.y -= input.x
	rotation.x = clamp(rotation.x - input.y, deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
	

func _input(event):
	# Actual Camera controls
	if (not event is InputEventMouseMotion): return
	var input : Vector2 = event.relative * sensitivity * get_process_delta_time()
	
	(get_parent() as Node3D).rotation.y -= input.x
	rotation.x = clamp(rotation.x - input.y, deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
	

func get_camera_forward():
	return -$Camera3D.global_basis.z
