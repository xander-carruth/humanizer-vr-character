extends Node3D

@export var root: CharacterBody3D
## Smooth turn speed in radians per second
@export var smooth_turn_speed : float = 2.0
## Our directional input
@export var input_action : String = "primary"

# Controller node
@onready var _controller := get_parent() as XRController3D

func _physics_process(delta: float) -> void:
	# Skip if the controller isn't active
	if !_controller.get_is_active():
		return

	# Read the left/right joystick axis
	var left_right := _controller.get_vector2(input_action).x
	# Handle smooth rotation
	var deadzone = 0.1
	left_right -= deadzone * sign(left_right)
	var smoothed_yaw = smooth_turn_speed * delta * left_right
	_apply_turn(smoothed_yaw)

func _apply_turn(yaw: float) -> void:
	root.rotate_y(-yaw)
