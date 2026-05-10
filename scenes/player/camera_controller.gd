extends Node

@export var character: Node3D
@export var camera: Camera3D
@export var base_follow_distance: float = 10.0
@export var camera_aim_height: float = 5.0

@export var camera_sensitivity: float = 1.0

@onready var camera_follow_vector = Vector3(0, 0, -base_follow_distance)
@onready var follow_distance: float = base_follow_distance
@onready var camera_aim_modifier: Vector3 = Vector3(0, camera_aim_height, 0)

var max_pitch: float = deg_to_rad(75.0)
var min_pitch: float = deg_to_rad(-10.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not character or not camera:
		push_error("Error in camera controller ready. Character: ", character, " camera: ", camera)
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not character or not camera:
		return
	camera.global_position = character.global_position + camera_follow_vector + camera_aim_modifier
	camera.look_at(character.global_position + camera_aim_modifier)
	

func _on_input_component_mouse_moved(scaled_relative_movement: Vector2) -> void:
	if camera:
		var camera_yaw = scaled_relative_movement.x * camera_sensitivity
		handle_yaw(camera_yaw)
		var current_pitch = calculate_current_pitch()
		var camera_pitch = scaled_relative_movement.y * camera_sensitivity
		handle_pitch(camera_pitch, current_pitch)

## Calculates the pitch in radians of the camera_follow_vector
func calculate_current_pitch() -> float:
	var flattened_follow_vector = Vector3(camera_follow_vector.x, 0, camera_follow_vector.z)
	return camera_follow_vector.signed_angle_to(flattened_follow_vector, flattened_follow_vector.rotated(Vector3.UP, PI/2.0))

## Rotates the camera [param camera_yaw] radians about the y-axis, moving the camera left and right
func handle_yaw(camera_yaw: float) -> void:
	camera_follow_vector = camera_follow_vector.rotated(Vector3.DOWN, camera_yaw)

## Rotates the the camera [param camera_pitch] radians about the X axis, moving the camera up and
## down. [param current_pitch] is the current signed angle to the flat axis.
func handle_pitch(camera_pitch: float, current_pitch: float) -> void:
	# if lowering camera, and lowering camera would lower it beyond minimum pitch, then do not lower it
	if camera_pitch < 0 and current_pitch + camera_pitch < min_pitch:
		camera_pitch = 0
	# else if raising camera, and raising it would raise it beyond the max pitch, then do not raise it
	elif camera_pitch > 0 and current_pitch + camera_pitch > max_pitch:
		camera_pitch = 0
	camera_follow_vector = camera_follow_vector.rotated(camera.global_basis * Vector3.LEFT, camera_pitch)
