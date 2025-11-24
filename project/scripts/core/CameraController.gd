class_name CameraController
extends Camera2D

@export_group("Zoom Settings")
@export var min_zoom: float = 0.1
@export var max_zoom: float = 5.0
@export var zoom_speed: float = 0.1

@export_group("Pan Settings")
@export var pan_speed: float = 500.0

var _is_dragging: bool = false
var _last_mouse_pos: Vector2

# Touch handling
var _touch_points: Dictionary = {}
var _start_zoom: Vector2
var _start_dist: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_last_mouse_pos = event.position
			else:
				_is_dragging = false
	
	elif event is InputEventMouseMotion and _is_dragging:
		var delta = _last_mouse_pos - event.position
		position += delta / zoom.x
		_last_mouse_pos = event.position
		
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touch_points[event.index] = event.position
		else:
			_touch_points.erase(event.index)
		
		if _touch_points.size() == 2:
			var points = _touch_points.values()
			_start_dist = points[0].distance_to(points[1])
			_start_zoom = zoom
			
	elif event is InputEventScreenDrag:
		_touch_points[event.index] = event.position
		
		if _touch_points.size() == 1:
			var delta = event.relative
			position -= delta / zoom.x
		elif _touch_points.size() == 2:
			var points = _touch_points.values()
			var current_dist = points[0].distance_to(points[1])
			var zoom_factor = current_dist / _start_dist
			var new_zoom = _start_zoom * zoom_factor
			zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _process(delta: float) -> void:
	# Keyboard panning
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		position += input_dir * pan_speed * delta / zoom.x

func _zoom_camera(amount: float) -> void:
	var new_zoom = zoom + Vector2(amount, amount)
	zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

