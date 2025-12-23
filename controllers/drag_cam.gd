extends Camera2D

## [drag_cam.gd]
## top-down camera with touchscreen and keyboard support
## version: 4.5.1
## last updated: 11/26/25

const KEYBOARD_ENABLED = true
const ZOOM_THRESHOLD = 20       # For pinch to zoom, determines the finger distance before the camera zooms
const ZOOM_LERP_FACTOR = 18     # how quickly the camera will apply the new zoom
const ZOOM_SENSITIVITY = 0.05   # Determines the zoom delta for every input event
const ZOOM_MAX = 5
const ZOOM_MIN = 0.3
const MOVE_SPEED_MIN := 1000.0
const MOVE_SPEED_MAX := MOVE_SPEED_MIN * 2.5

var touch_events = {}
var input_enabled: bool = true
var camera_rect: Rect2
var target_zoom: float
var drag_dist = 0

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 20.0
	target_zoom = zoom.x
	_update_cam_rect()

func _physics_process(delta: float) -> void:
	if zoom.distance_to(Vector2.ONE * target_zoom) > 0.01:
		zoom = lerp(zoom, Vector2.ONE * target_zoom, ZOOM_LERP_FACTOR * delta)
		_update_cam_rect()

	if input_enabled and KEYBOARD_ENABLED and touch_events.size() == 0:
		var move_dir = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
		var zoom_factor = remap(zoom.x, ZOOM_MIN, ZOOM_MAX, 1, 0.1)
		var move_speed = MOVE_SPEED_MAX if Input.is_action_pressed("cam_speed_up") else MOVE_SPEED_MIN
		_move_cam(position + move_dir * move_speed * zoom_factor * delta)

func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	
	if event is InputEventScreenTouch:
		if event.is_pressed():
			touch_events[event.index] = event
		else:
			touch_events.erase(event.index)
			
	# Scroll to zoom
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(1 + ZOOM_SENSITIVITY)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(1 - ZOOM_SENSITIVITY)
			
	elif event is InputEventScreenDrag:
		touch_events[event.index] = event
		# Camera dragging
		if touch_events.size() == 1:
			var offset_pos = position + event.relative.rotated(PI) * (1/zoom.x) # scale drag distance to zoom
			_move_cam(offset_pos)
		# Pinch zooming
		elif touch_events.size() == 2:
			var dist = touch_events[0].position.distance_to(touch_events[1].position)
			if abs(dist - drag_dist) > ZOOM_THRESHOLD:
				_apply_zoom(1 + ZOOM_SENSITIVITY * (-1 if dist < drag_dist else 1))
				drag_dist = dist

func _move_cam(new_pos: Vector2) -> void:
	position = new_pos
	# ensure camera center stays within limits using camera rect size
	position = position.clamp(
		Vector2(limit_left  + camera_rect.size.x/2, limit_top    + camera_rect.size.y/2),
		Vector2(limit_right - camera_rect.size.x/2, limit_bottom - camera_rect.size.y/2)
		)

func _apply_zoom(new_zoom: float) -> void:
	target_zoom = clamp(target_zoom * new_zoom, ZOOM_MIN, ZOOM_MAX)

func _update_cam_rect() -> void:
	camera_rect = get_canvas_transform().affine_inverse() * get_viewport_rect()

## Enables/disables input processing for the camera
func set_input_enabled(enable: bool) -> void:
	input_enabled = enable
