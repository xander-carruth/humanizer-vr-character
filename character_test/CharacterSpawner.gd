extends Node3D
@export var vr_player_scene: PackedScene
@export var godot_ik_scene: PackedScene
@export var spawn_location: Vector3 = Vector3(0, 0, 0)

var skin_shader: ShaderMaterial = load("res://CharacterCreator/skin_color_shader.tres")

func _ready():
	await create_new_human_async() 

func create_new_human_async():
	var result = await HumanizerHelper.load_humanizer_from_json_async(skin_shader, "res://data/test.json")
	var humanizer := result[0] as Humanizer
	var updated_skin_shader = result[1]
	var head_height = humanizer.get_head_height()
	print("head height: ", head_height)
	HumanizerJobQueue.add_job(func():
		var vr_player = create_vr_player(humanizer, vr_player_scene, godot_ik_scene)
		#var player_body := vr_player.get_node("XrRig/PlayerBody") as XRToolsPlayerBody
		var collision_shape := vr_player.get_node("CollisionShape3D") as CollisionShape3D
		var capsule = collision_shape.shape
		capsule.height = head_height
		collision_shape.position.y = head_height/2
		#player_body.player_height_max = head_height + 0.2
		#player_body.player_height_min = 0
		call_deferred("add_child", vr_player)
		vr_player.get_node("Character").get_node("Avatar").set_surface_override_material(0, updated_skin_shader)
		vr_player.global_position = spawn_location
		print("Loaded human")
		)
		
func create_vr_player(humanizer: Humanizer, vr_player_scene: PackedScene, godot_ik_scene: PackedScene):
	var vr_player := vr_player_scene.instantiate()
	var human := vr_player.get_node("Character")
	
	# Remove default meshes
	clear_default_body(human)
	# Regenerate body with humanizer settings
	humanizer.hide_clothes_vertices()
	var skeleton = generate_skeleton(human, humanizer)
	generate_body_mesh(human, humanizer, skeleton)
	#Add IK
	generate_skeleton_ik(skeleton)
	return vr_player
	
func clear_default_body(human: Node3D):
	var old_skeleton = human.get_node("GeneralSkeleton")
	var old_avatar_mesh = human.get_node("Avatar")
	old_skeleton.queue_free()
	old_avatar_mesh.queue_free()

func generate_skeleton(human: Node3D, humanizer: Humanizer) -> Skeleton3D:
	var skeleton = humanizer.get_skeleton()
	human.add_child(skeleton)
	skeleton.set_unique_name_in_owner(true)
	return skeleton

func generate_body_mesh(human: Node3D, humanizer: Humanizer, skeleton: Skeleton3D):
	var body_mesh = MeshInstance3D.new()
	body_mesh.name = "Avatar"

	body_mesh.mesh = humanizer.get_combined_meshes()
	human.add_child(body_mesh)
	body_mesh.skeleton = NodePath('../' + skeleton.name)
	body_mesh.skin = skeleton.create_skin_from_rest_transforms()
	skeleton.owner = human
	
func generate_skeleton_ik(skeleton: Skeleton3D):
	var godot_ik = godot_ik_scene.instantiate()
	configure_leg_ik(skeleton, godot_ik, "LeftLowerLeg", "LeftKneeTarget")
	configure_leg_ik(skeleton, godot_ik, "RightLowerLeg", "RightKneeTarget")
	skeleton.add_child(godot_ik)

func configure_leg_ik(skeleton: Skeleton3D, godot_ik: Node, leg_bone_name: String, knee_target_name: String):
	var lower_leg_idx = skeleton.find_bone(leg_bone_name)
	var lower_leg_pose = skeleton.get_bone_global_pose(lower_leg_idx)
	var knee_target = godot_ik.get_node(knee_target_name)
	var knee_target_origin = lower_leg_pose.origin
	knee_target_origin.y = knee_target_origin.y + knee_target_origin.y * 0.25
	knee_target_origin.x = knee_target_origin.x * 2
	knee_target_origin.z = knee_target_origin.y / 2
	knee_target.global_transform.origin = knee_target_origin
