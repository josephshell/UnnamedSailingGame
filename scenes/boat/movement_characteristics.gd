class_name MovementCharacteristics extends Node

## The torque force applied to the ship when the wheel is turned
@export var turning_torque: float = 1.0
## The maximum speed in radians per second that the ship may turn
@export var max_turning_speed: float = TAU / 10
## The speed that the ship's wheel will turn when actively changing direction
@export var turning_speed: float = 0.01
## The speed that the ship's wheel will return to zero turn when controls are released
@export var turning_drift: float = 0.01
@export var speed_reverse: float = 5.0
@export var acceleration_reverse: float = 20.0
@export var speed_low: float = 5.0
@export var acceleration_low: float = 20.0
@export var speed_medium: float = 8.0
@export var acceleration_medium: float = 30.0
@export var speed_fast: float = 13.0
@export var acceleration_fast: float = 50.0
