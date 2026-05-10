class_name FloatComponent extends Node3D

const water_height := 0.0

@export var floatable: RigidBody3D
@export var float_force: float = 1.0
@export var gravity_force: float = 1.0
@export var buoys: Array[Buoy] = []

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(_delta):
	var any_buoy_submerged: bool = false
	for buoy in buoys:
		var depth = water_height - buoy.global_position.y
		var is_submerged = depth > 0
		if is_submerged:
			any_buoy_submerged = true
			apply_float(buoy.global_position, depth)
		apply_buoy_gravity(buoy.global_position)
	
	if floatable.has_method("set_submerged"):
		floatable.set_submerged(any_buoy_submerged)
	

func apply_float(buoy_global_position: Vector3, buoy_depth: float):
	var float_force_vector = Vector3.UP * float_force * gravity * buoy_depth
	floatable.apply_force(float_force_vector, buoy_global_position - floatable.global_position)

func apply_buoy_gravity(buoy_global_position: Vector3):
	var gravity_force_vector = Vector3.DOWN * gravity_force * gravity
	floatable.apply_force(gravity_force_vector, buoy_global_position - floatable.global_position)
