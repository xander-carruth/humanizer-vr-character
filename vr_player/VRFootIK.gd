extends Node3D

@export var left_eff_path: NodePath
@onready var left_eff: GodotIKEffector = get_node(left_eff_path)
@export var right_eff_path: NodePath
@onready var right_eff: GodotIKEffector = get_node(right_eff_path)
@export var head_eff_path: NodePath
@onready var head_eff: Node3D = get_node(head_eff_path)

@export var foot_offset: Vector3 = Vector3.UP * 0.03	# small lift above ground
@export var right_foot_rot_offset: Vector3
@export var left_foot_rot_offset: Vector3
@export_range(0.0, 1.0, 0.01) var left_pos_weight  : float = 1.0
@export_range(0.0, 1.0, 0.01) var left_rot_weight  : float = 1.0
@export_range(0.0, 1.0, 0.01) var right_pos_weight : float = 1.0
@export_range(0.0, 1.0, 0.01) var right_rot_weight : float = 1.0
@export var ground_collision_layer :=  1 << (3 - 1)

var _space: PhysicsDirectSpaceState3D

func _ready() -> void:
	_space = get_world_3d().direct_space_state

func _physics_process(delta: float) -> void:
	_process_foot(right_eff, right_pos_weight, right_rot_weight, convert_rot_vector_to_basis(right_foot_rot_offset), delta)
	_process_foot(left_eff,  left_pos_weight,  left_rot_weight, convert_rot_vector_to_basis(left_foot_rot_offset), delta)

func convert_rot_vector_to_basis(rot_vector: Vector3) -> Basis:
	return Basis.from_euler(Vector3(deg_to_rad(rot_vector.x), deg_to_rad(rot_vector.y), deg_to_rad(rot_vector.z)))

var cooldown = 0.0

func _process_foot(eff: GodotIKEffector, pos_w: float, rot_w: float, basis_offset: Basis, delta: float) -> void:
	if eff == null or pos_w == 0.0:
		return

	var foot_tf : Transform3D = eff.global_transform
	var foot_pos: Vector3     = foot_tf.origin
	
	# TODO: delete this
	cooldown -= delta
	#if cooldown <= 0.0:
		#print("Foot pos: ", foot_pos)
		#cooldown = 0.3
	#

	# Ray-cast straight down from a point 1 m above the current foot position.
	var from := foot_pos + Vector3.UP
	var to := foot_pos + Vector3.DOWN * 2.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = ground_collision_layer
	query.collide_with_areas = false		# (ground = bodies only)

	var res: Dictionary = _space.intersect_ray(query)

	# No ground was hit
	if res.is_empty():
		eff.influence = 0.0
		return
	var hit_pt: Vector3 = res.position
	var hit_norm: Vector3 = res.normal.normalized()
	
	# 1 · position
	var tgt_pos := hit_pt + foot_offset

	# 2 · rotation — align foot Y with ground normal, keep avatar fwd in XZ
	var avatar_fwd := -head_eff.global_transform.basis.z
	var tgt_basis = Basis.looking_at(project_on_plane(avatar_fwd, hit_norm), hit_norm)
	tgt_basis = tgt_basis * basis_offset
	
	# 3 · blend by weights
	eff.influence = pos_w		# controls position blend internally
	eff.global_transform = Transform3D(tgt_basis, tgt_pos).interpolate_with(
			eff.global_transform, 1.0 - pos_w)

	# influence handles rotation as well; optional extra rotation weighting:
	if rot_w < 1.0:
		var interp_basis := eff.global_transform.basis.slerp(tgt_basis, rot_w)
		eff.global_transform.basis = interp_basis

func project_on_plane(v: Vector3, n: Vector3) -> Vector3:
	return v - n * v.dot(n)
