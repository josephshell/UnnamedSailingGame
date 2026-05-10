class_name MovementComponent extends Node

@export var movement_force: float = 20.0
@export var turning_torque: float = 1.0
@export var max_speed: float = 5.0

var boat: Boat

func _on_input_component_movement_pressed(direction: Vector2):
	if not boat:
		push_error("Not boat?")
		return
	var boat_speed: float = boat.linear_velocity.length()
	var forward_direction = boat.global_basis * Vector3.FORWARD
	if direction.y != 0 and boat_speed <= max_speed:
		boat.apply_central_force(forward_direction * direction.y * movement_force)
	if direction.x != 0:
		var linear_turn_capability = clampf(boat_speed / max_speed, 0.2, 1.0)
		var dot_product = boat.linear_velocity.dot(forward_direction)
		var is_moving_backwards = dot_product > 0.1
		var torque_based_on_dir: float
		if is_moving_backwards:
			torque_based_on_dir = turning_torque
		else:
			torque_based_on_dir = -turning_torque
		boat.apply_torque(Vector3(0, direction.x * torque_based_on_dir * linear_turn_capability, 0))
