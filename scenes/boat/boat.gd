class_name Boat extends RigidBody3D

@export var water_drag: float = 0.05
@export var water_angular_drag: float = 0.05

var is_submerged: bool = false

func set_submerged(value: bool):
	is_submerged = value

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if is_submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
