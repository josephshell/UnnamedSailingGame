class_name InputComponent
extends Node

signal mouse_moved(scaled_relative_movement: Vector2)
signal movement_pressed(direction: Vector2)
signal forwards_pressed
signal backwards_pressed
signal joypad_look_pressed(direction: Vector2)
signal interact_pressed
signal exit_pressed
signal jump_pressed
signal toggle_inventory_pressed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_moved.emit(event.relative * 0.001)
	if event.is_action_pressed(&"interact"):
		interact_pressed.emit()
	if event.is_action_pressed(&"exit"):
		exit_pressed.emit()
	if event.is_action_pressed(&"toggle_inventory"):
		toggle_inventory_pressed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"jump"):
		jump_pressed.emit()
	update_joypad_look()
	update_moving_direction()

func update_joypad_look():
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	joypad_look_pressed.emit(joypad_dir)

func update_moving_direction():
	if Input.is_action_just_pressed(&"move_forward"):
		forwards_pressed.emit()
	elif Input.is_action_just_pressed(&"move_backwards"):
		backwards_pressed.emit()
	var direction = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backwards")
	movement_pressed.emit(direction)
