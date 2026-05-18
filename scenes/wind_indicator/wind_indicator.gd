@tool
class_name WindIndicator extends Node3D

var wind_manager: WindManager

func _physics_process(delta):
	if wind_manager:
		var global_coordinates = Vector2(global_position.x, global_position.z)
		global_rotation.y = Vector2.UP.angle_to(wind_manager.get_wind_direction(global_coordinates))
	self.global_rotation.x = 0
	self.global_rotation.z = 0
