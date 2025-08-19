extends Node3D
const XR_TO_MODEL := Basis(Vector3.UP, PI)  # rotate 180° around Y

# Change this to be onready
@export var xr_camera: Camera3D
@export var root_node: Node3D
@export var skeleton_path: NodePath
@onready var skeleton: Skeleton3D = get_node(skeleton_path)
@export var head_effector_path: NodePath
@onready var head_effector: GodotIKEffector = get_node(head_effector_path)
@export var head_pos_offset := Vector3.ZERO

@export var hand_lerp_speed: float = 12.0
@export var left_controller: XRController3D
@export var left_effector_path: NodePath
@onready var left_effector: GodotIKEffector = get_node(left_effector_path)
@export var left_rot_offset_deg := Vector3.ZERO

@export var right_controller: XRController3D
@export var right_effector_path: NodePath
@onready var right_effector: GodotIKEffector = get_node(right_effector_path)
@export var right_rot_offset_deg := Vector3.ZERO


var _head_body_offset := 0.0
#var _adjust_head_offset := 0.0
var _first_run := false

var head_bone_name := "Head"
var l_foot_idx: int
var r_foot_idx: int

func _ready() -> void:
	l_foot_idx = skeleton.find_bone("LeftFoot")
	r_foot_idx = skeleton.find_bone("RightFoot")
	
	head_effector.set_transform_to_bone()
	left_effector.set_transform_to_bone()
	right_effector.set_transform_to_bone()
	
	#await get_tree().process_frame          # wait 1 frame so tracking is valid
 #
	#var avatar_head_y : float = skeleton.get_bone_global_pose(_head_idx).origin.y
	#print("Avatar height: " + str(avatar_head_y))
	#var user_head_y: float = xr_camera.global_transform.origin.y
	#print("Camera height: " + str(user_head_y))
	## fallback for seated-mode before tracking
	#if user_head_y == 0.0:
		#user_head_y = 1.7                    
	
func _process(delta: float) -> void:
	map_head_to_rig()
	map_hand_to_rig(delta, left_controller, left_effector, left_rot_offset_deg, hand_lerp_speed)
	map_hand_to_rig(delta, right_controller, right_effector, right_rot_offset_deg, hand_lerp_speed)

func map_head_to_rig():
	# Update head target pose

	# One-time head/body spacing (works once headset is tracked)
	if !_first_run and head_effector.global_transform.origin.y > 0.01:
		# Get skeleton head height
		# Get vr camera height
		# rig origin should be placed skeleton - camera height higher/lower
		var head_idx = skeleton.find_bone("Head")
		var head_transform : Transform3D = skeleton.get_bone_global_pose(head_idx)
		var head_height = head_transform.origin.y
		print("head height: ", head_height)
		var camera_height = xr_camera.global_transform.origin.y
		print("camera height: ", camera_height)
		var rig_offset = head_height - camera_height
		
		var xr_rig  = xr_camera.get_parent()
		xr_rig.global_transform.origin.y = xr_rig.global_transform.origin.y + rig_offset
		_head_body_offset  = head_height - root_node.global_transform.origin.y
		print("head body offset: ", _head_body_offset)
		#_adjust_head_offset = 0.2 * (1.6 - _head_body_offset) / 1.6	# same formula as Unity example
		_first_run = true

	head_effector.global_transform.origin = xr_camera.to_global(head_pos_offset)
	head_effector.global_transform.basis = xr_camera.global_transform.basis * XR_TO_MODEL
	
	# Keep body root under the head 
	var head_pos := head_effector.global_transform.origin
	root_node.global_transform.origin = Vector3(
		head_pos.x,
		head_pos.y - _head_body_offset,
		head_pos.z
	)
	
func map_hand_to_rig(delta: float, controller: XRController3D, effector: GodotIKEffector, rot_offset_deg: Vector3, lerp_speed: float):
	if !controller: return
	# lerp hand with offset towards controller position
	var rot_offset_rad = Vector3(deg_to_rad(rot_offset_deg.x), deg_to_rad(rot_offset_deg.y), deg_to_rad(rot_offset_deg.z))
	var target = controller.global_transform
	target.basis = target.basis * Basis.from_euler(rot_offset_rad)
	var lerp_weight = clamp(hand_lerp_speed * delta, 0.0, 1.0)
	effector.global_transform = effector.global_transform.interpolate_with(target, lerp_weight)
