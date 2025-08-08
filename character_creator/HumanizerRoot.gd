extends Node3D
const TURN_SPEED := 90.0 # degrees / second

## Our directional input
@export var input_action : String = "primary"
@export var controller: XRController3D

func _physics_process(delta: float) -> void:
	# Skip if the controller isn't active
	if !controller.get_is_active():
		return

	var deadzone = 0.1
	# Read the left/right joystick axis
	var left_right := controller.get_vector2(input_action).x
	if abs(left_right) <= deadzone:
		# Not turning
		return

	# Handle smooth rotation
	left_right -= deadzone * sign(left_right)
	rotate_y(deg_to_rad(-TURN_SPEED * left_right * delta))
	return
