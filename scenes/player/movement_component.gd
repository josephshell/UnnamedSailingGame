class_name MovementComponent extends Node

@export var turning_torque: float = 1.0
@export var speed_reverse: float = 5.0
@export var acceleration_reverse: float = 20.0
@export var speed_low: float = 5.0
@export var acceleration_low: float = 20.0
@export var speed_medium: float = 8.0
@export var acceleration_medium: float = 30.0
@export var speed_fast: float = 13.0
@export var acceleration_fast: float = 50.0

var _speed_by_mode: Dictionary[SpeedMode, float] = {}
var _acceleration_by_mode: Dictionary[SpeedMode, float] = {}

var _speed_mode: SpeedMode = SpeedMode.NONE

var boat: Boat

func _ready():
	_speed_by_mode[SpeedMode.NONE] = 0.0
	_speed_by_mode[SpeedMode.REVERSE] = speed_reverse
	_speed_by_mode[SpeedMode.LOW] = speed_low
	_speed_by_mode[SpeedMode.MEDIUM] = speed_medium
	_speed_by_mode[SpeedMode.FAST] = speed_fast
	_acceleration_by_mode[SpeedMode.NONE] = 0.0
	_acceleration_by_mode[SpeedMode.REVERSE] = acceleration_reverse
	_acceleration_by_mode[SpeedMode.LOW] = acceleration_low
	_acceleration_by_mode[SpeedMode.MEDIUM] = acceleration_medium
	_acceleration_by_mode[SpeedMode.FAST] = acceleration_fast
	

func _physics_process(delta):
	_handle_velocity()

func increase_speed():
	if _speed_mode != SpeedMode.FAST:
		_speed_mode += 1

func decrease_speed():
	if _speed_mode != SpeedMode.REVERSE:
		_speed_mode -= 1

func get_speed_mode() -> SpeedMode:
	return _speed_mode

## TODO: Front of ship needs to be pointing along the -Z axis
func _get_boat_forward_direction() -> Vector3:
	return boat.global_basis * Vector3.FORWARD

func _handle_velocity():
	var boat_speed: float = boat.linear_velocity.length()
	var forward_direction = _get_boat_forward_direction() ## TODO: This forward is +Z axis, which is backwards from standard
	if boat_speed <= _speed_by_mode[_speed_mode]:
		forward_direction = -forward_direction if not _speed_mode == SpeedMode.REVERSE else forward_direction
		boat.apply_central_force(forward_direction * _acceleration_by_mode[_speed_mode] * boat.mass)

func on_turn_input(turn_amount: float):
	_handle_turning(turn_amount, boat.linear_velocity.length())

func _handle_turning(turn_amount: float, boat_speed: float):
	if turn_amount != 0:
		var linear_turn_capability = clampf(boat_speed / _speed_by_mode[SpeedMode.FAST], 0.2, 1.0)
		var dot_product = boat.linear_velocity.dot(_get_boat_forward_direction())
		var is_moving_backwards = dot_product > 0.1
		var torque_based_on_dir: float
		if is_moving_backwards:
			torque_based_on_dir = turning_torque
		else:
			torque_based_on_dir = -turning_torque
		boat.apply_torque(Vector3(0, turn_amount * torque_based_on_dir * linear_turn_capability, 0))

enum SpeedMode {
	REVERSE,
	NONE,
	LOW,
	MEDIUM,
	FAST
}
