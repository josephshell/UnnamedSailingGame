class_name MovementComponent extends Node

var _speed_by_mode: Dictionary[SpeedMode, float] = {}
var _acceleration_by_mode: Dictionary[SpeedMode, float] = {}

var _speed_mode: SpeedMode = SpeedMode.NONE

## The amount of turning done by the ship this frame. Like a ships steering wheel, it increases
## and decreases slowly
var _current_turn_amount: float = 0

var boat: Boat

func configure(new_boat: Boat):
	var stats: MovementCharacteristics = new_boat.movement_characteristics
	_speed_by_mode[SpeedMode.NONE] = 0.0
	_speed_by_mode[SpeedMode.REVERSE] = stats.speed_reverse
	_speed_by_mode[SpeedMode.LOW] = stats.speed_low
	_speed_by_mode[SpeedMode.MEDIUM] = stats.speed_medium
	_speed_by_mode[SpeedMode.FAST] = stats.speed_fast
	_acceleration_by_mode[SpeedMode.NONE] = 0.0
	_acceleration_by_mode[SpeedMode.REVERSE] = stats.acceleration_reverse
	_acceleration_by_mode[SpeedMode.LOW] = stats.acceleration_low
	_acceleration_by_mode[SpeedMode.MEDIUM] = stats.acceleration_medium
	_acceleration_by_mode[SpeedMode.FAST] = stats.acceleration_fast
	boat = new_boat
	

func _physics_process(_delta):
	if not boat:
		return
	_handle_velocity()
	_handle_turning()

func increase_speed():
	if _speed_mode != SpeedMode.FAST:
		_speed_mode += 1

func decrease_speed():
	if _speed_mode != SpeedMode.REVERSE:
		_speed_mode -= 1

func get_speed_mode() -> SpeedMode:
	return _speed_mode

func on_turn_input(turn_input: float):
	if not boat:
		return
	var turn_amount := 0.0
	if turn_input == 0.0 and abs(_current_turn_amount) > 0.1:
		var direction_to_zero_turn = -sign(_current_turn_amount)
		turn_amount = boat.movement_characteristics.turning_drift * direction_to_zero_turn
	else:
		turn_amount = boat.movement_characteristics.turning_speed * turn_input

	_current_turn_amount = clampf(_current_turn_amount + turn_amount, -boat.movement_characteristics.max_turning_speed, boat.movement_characteristics.max_turning_speed)

## TODO: Front of ship needs to be pointing along the -Z axis
func _get_boat_forward_direction() -> Vector3:
	return boat.global_basis * Vector3.FORWARD

func _handle_velocity():
	var boat_speed: float = boat.linear_velocity.length()
	var forward_direction = _get_boat_forward_direction() ## TODO: This forward is +Z axis, which is backwards from standard
	if boat_speed <= _speed_by_mode[_speed_mode]:
		forward_direction = -forward_direction if not _speed_mode == SpeedMode.REVERSE else forward_direction
		boat.apply_central_force(forward_direction * _acceleration_by_mode[_speed_mode] * boat.mass)

func _handle_turning():
	var boat_speed = boat.linear_velocity.length()
	if abs(_current_turn_amount) > 0.1:
		var linear_turn_capability = clampf(boat_speed / _speed_by_mode[SpeedMode.FAST], 0.2, 1.0)
		var dot_product = boat.linear_velocity.dot(_get_boat_forward_direction())
		var is_moving_backwards = dot_product > 0.1
		var torque_based_on_dir: float
		if is_moving_backwards:
			torque_based_on_dir = boat.movement_characteristics.turning_torque
		else:
			torque_based_on_dir = -boat.movement_characteristics.turning_torque
		boat.apply_torque(Vector3(0, _current_turn_amount * torque_based_on_dir * linear_turn_capability, 0))

enum SpeedMode {
	REVERSE,
	NONE,
	LOW,
	MEDIUM,
	FAST
}
