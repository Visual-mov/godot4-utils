extends Camera3D

## [freecam.gd]
## simple free-flying 3d camera
## version: 4.5.1

@export var move_speed: float = 12
@export var acceleration: float = 15
@export var friction: float = 10
@export var use_basis_for_y_movement: bool = false
@export var mouse_sensitivity: float = 0.001 # dependent on window resolution
@export_category("Bounding box")
@export var use_bounding_box: bool = false
@export var box_origin: Node3D = null
@export var box_width: float = 0.0
@export var box_height: float = 0.0

@onready var viewport = get_viewport()
var cam_origin: Vector3 = Vector3.ZERO
var mouse_pos: Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO
var bound_min: Vector3 = Vector3.ZERO
var bound_max: Vector3 = Vector3.ZERO
var input_enabled: bool = true

func _ready() -> void:
	if use_bounding_box:
		cam_origin = global_position if box_origin == null else box_origin.global_position
		bound_min = cam_origin - Vector3(box_width, box_height, box_width)
		bound_max = cam_origin + Vector3(box_width, box_height, box_width)
		
	_capture_mouse()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = event.relative

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("cam_toggle"):
		if input_enabled:
			_release_mouse()
		else:
			_capture_mouse()
			
	var movement = Vector3.ZERO
	
	if input_enabled:
		# update pitch and yaw
		var pos = -mouse_pos * mouse_sensitivity
		rotation.y += pos.x
		rotation.x = clamp(rotation.x + pos.y, -PI/2, PI/2)
		mouse_pos = Vector2(0, 0)
		
		# camera movement
		var move_dir = Input.get_vector("cam_forward", "cam_back", "cam_left", "cam_right")
		movement += move_dir.x * transform.basis.z + move_dir.y * transform.basis.x
		
		if Input.is_action_pressed("cam_up"):
			movement += transform.basis.y if use_basis_for_y_movement else Vector3.UP
		if Input.is_action_pressed("cam_down"):
			movement += -transform.basis.y if use_basis_for_y_movement else Vector3.DOWN
			
		velocity += movement
		
	_update_position(movement, delta)
		
func _update_position(movement: Vector3, delta: float) -> void:
	# apply friction/acceleration
	var weight = friction if movement == Vector3.ZERO else acceleration
	velocity = velocity.lerp(move_speed * movement, weight * delta).limit_length(move_speed)
	
	position += velocity * delta
	if use_bounding_box:
		position = position.clamp(bound_min, bound_max)
	
func _release_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_active(false)
	
func _capture_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_active(true)

func set_active(toggle: bool) -> void:
	input_enabled = toggle
