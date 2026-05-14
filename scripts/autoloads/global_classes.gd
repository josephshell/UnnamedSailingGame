extends Node


class Rumor:
	var description: String
	var target_location: Node3D
	
	func _init(_description: String, _target_location: Node3D):
		description = _description
		target_location = _target_location
