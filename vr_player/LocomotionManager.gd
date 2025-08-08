extends Node3D

@export var speed_threshold: float = 0.1
@export_range(0.0, 1.0) var smoothing: float = 0.15

@export var xr_rig_target: Node3D
#@export var origin: Node3D
@export var anim_tree: AnimationTree
@export var anim_expression_manager: Node3D

const BLEND_PATH := "parameters/StateMachine/Locomotion/blend_position"
const PLAYBACK_PATH := "parameters/StateMachine/playback"

var _prev_pos: Vector3
var _blend: Vector2 

func _ready() -> void:
	anim_tree.active = true
	anim_tree.set("parameters/LegMask/blend_amount", 1.0)
	#_blend = Vector2(0.1, 0.1)
	#anim_tree.set(BLEND_PATH, _blend)
	
func direction_to_local(global_direction: Vector3) -> Vector3:
	var global_to_local: Transform3D = global_transform.affine_inverse()
	return global_to_local * global_direction - global_to_local * Vector3.ZERO
	
func _physics_process(delta: float) -> void:
	var vel = (xr_rig_target.global_position - _prev_pos) / delta
	_prev_pos = xr_rig_target.global_position
	vel.y = 0.0

	var local = direction_to_local(vel)
	
	# magnitude gate (idle vs walk)
	anim_expression_manager.moving = local.length() > speed_threshold
	#anim_tree.set(MOVING_PATH, )

	# clamp and lerp
	var target = Vector2(
		clamp(local.x, -1.0, 1.0),      # strafe
		clamp(local.z, -1.0, 1.0)       # forward/back
	)
	target.x = -target.x
	_blend = _blend.lerp(target, smoothing)
	#_blend = Vector2(0.2, 0.2)
	anim_tree.set(BLEND_PATH, _blend)
	var test = anim_tree.get(BLEND_PATH)
