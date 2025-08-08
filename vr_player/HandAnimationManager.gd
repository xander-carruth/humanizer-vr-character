extends Node3D

@export var left_controller: XRController3D
@export var right_controller: XRController3D
@export var animation_tree: AnimationTree

## Name of the Grip action in the OpenXR Action Map.
@export var grip_action : String = "grip"
## Name of the Trigger action in the OpenXR Action Map.
@export var trigger_action : String = "trigger"

func _ready() -> void:
	animation_tree.set("parameters/HandCharacterBlend/blend_amount", 1.0)
	animation_tree.set("parameters/LeftRightHandAdd/add_amount", 1.0)

func _physics_process(delta: float) -> void:
	_animate_hand(left_controller, "Left")
	_animate_hand(right_controller, "Right")

func _animate_hand(controller: XRController3D, prefix: String) -> void:
	# Animate the hand mesh with the controller inputs
	if controller:
		var grip : float = controller.get_float(grip_action)
		var trigger : float = controller.get_float(trigger_action)
		
		var parameter_prefix = "parameters/" + prefix
		animation_tree.set(parameter_prefix + "Grip/blend_amount", grip)
		animation_tree.set(parameter_prefix + "Trigger/blend_amount", trigger)
