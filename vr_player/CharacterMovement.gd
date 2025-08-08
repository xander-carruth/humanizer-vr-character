extends Node3D

@export var root: CharacterBody3D
@export var max_speed : float = 1.0
@export var input_action : String = "primary"
@onready var _controller := get_parent() as XRController3D



# Perform jump movement
func _physics_process(delta: float) -> void:
	# Skip if the controller isn't active
	if !_controller.get_is_active():
		return 

	# get input action with deadzone correction applied
	var input = XRToolsUserSettings.get_adjusted_vector2(_controller, input_action)
	var direction := Vector3(-input.x, 0, input.y)
	var world_dir := (root.global_transform.basis * direction).normalized()

	root.velocity.x = world_dir.x * max_speed
	root.velocity.z = world_dir.z * max_speed

	root.move_and_slide()
