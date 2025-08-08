extends Node

class_name HumanizerHelper

static func get_skin_color_ratios():
	var skin_color_ratio = 0.0
	var age = 24
	var ratios = []
	var gender = "male"
	ratios.resize(12)
	ratios.fill(1)
	var light_ratio = (100-skin_color_ratio)/100.0
	var dark_ratio = skin_color_ratio/100.0
	
	if gender == "male":
		ratios = _multiply_arrays(ratios,[1,1,1,0,0,0,1,1,1,0,0,0])
	else:
		ratios = _multiply_arrays(ratios,[0,0,0,1,1,1,0,0,0,1,1,1])
		
	var age_ranges = [0.0,50.0,100.0]
	if age < age_ranges[1]:
		var upper_age = age/age_ranges[1]
		var lower_age = 1 - upper_age
		ratios = _multiply_arrays(ratios,[lower_age,upper_age,0,lower_age,upper_age,0,lower_age,upper_age,0,lower_age,upper_age,0])
	else:
		var upper_age = (age-age_ranges[1])/(age_ranges[2]-age_ranges[1])
		var lower_age = 1 - upper_age
		ratios = _multiply_arrays(ratios,[0,lower_age,upper_age,0,lower_age,upper_age,0,lower_age,upper_age,0,lower_age,upper_age])
		
	ratios = _multiply_arrays(ratios,[light_ratio,light_ratio,light_ratio,light_ratio,light_ratio,light_ratio,dark_ratio,dark_ratio,dark_ratio,dark_ratio,dark_ratio,dark_ratio])
	return ratios

static func _multiply_arrays(array1:Array,array2:Array):
	if not array1.size() == array2.size():
		printerr("cant multiply arrays of different lengths")
		return null
	else:
		var output = []
		for i in array1.size():
			output.append(array1[i] * array2[i])
		return output
		
static func save_humanizer_to_json(humanizer: HumanizerEditorTool, skin_shader: ShaderMaterial, json_path: String):
	var humanizer_dict = {}
	# Create unique id
	humanizer_dict["uid"] = UUID.uuid_v4()
	# Get shapekey values
	humanizer_dict["shapekeys"] = humanizer.human_config.targets
	
	var character_colors = []
	# get skin color
	var skin_color_dict = {}
	skin_color_dict["name"] = "Skin"
	var skin_color: Color = skin_shader.get_shader_parameter("albedo")
	skin_color_dict["colors"] = [skin_color.r, skin_color.g, skin_color.b]
	character_colors.append(skin_color_dict)
	# get hair color
	var hair_color_dict = {}
	hair_color_dict["name"] = "Hair"
	var hair_color = humanizer.human_config.hair_color
	hair_color_dict["colors"] = [hair_color.r, hair_color.g, hair_color.b]
	character_colors.append(hair_color_dict)

	# get eye color
	var eye_color_dict = {}
	eye_color_dict["name"] = "Eyes"
	var eye_color = humanizer.human_config.eye_color
	eye_color_dict["colors"] = [eye_color.r, eye_color.g, eye_color.b]
	character_colors.append(eye_color_dict)
	
	humanizer_dict["characterColors"] = character_colors
	
	# iterate through equipment and get item name for every slots
	var wardrobe_set = []
	for equip_name in humanizer.human_config.equipment:
		var equip_item = humanizer.human_config.equipment[equip_name]
		var equip_item_dict = {}
		var equip_type = equip_item.get_type()
		var item_slot = equip_type.slots[0]
		var item_name = equip_name
		equip_item_dict["slot"] = item_slot
		equip_item_dict["recipe"] = item_name
		wardrobe_set.append(equip_item_dict)
		
	humanizer_dict["wardrobeSet"] = wardrobe_set
	var json_string := JSON.stringify(humanizer_dict, "\t", false)
	FileManager.write_text_to_file(json_path, json_string)
	
	
# add json data to human config, returns Array[Humanizer, ShaderMaterial]
static func load_humanizer_from_json_async(skin_shader: ShaderMaterial, json_path: String) -> Array:
	var humanizer = Humanizer.new()
	var humanizer_dict_text = FileManager.load_text_from_file(json_path)
	var humanizer_dict: Dictionary = JSON.parse_string(humanizer_dict_text)
	var human_config = HumanConfig.new()
	human_config.rig = HumanizerGlobalConfig.config.default_skeleton
	
	# set targets
	human_config.targets = humanizer_dict["shapekeys"]
	
	# set equipment
	var wardrobe_set = humanizer_dict["wardrobeSet"]
	for wardrobe_item in wardrobe_set:
		human_config.add_equipment(HumanizerEquipment.new(wardrobe_item["recipe"]))
		#humanizer.add_equipment(HumanizerEquipment.new(wardrobe_item["recipe"]))
	
	# set colors
	var character_colors = humanizer_dict["characterColors"]
	for color_set in character_colors:
		match color_set["name"]:
			"Skin":
				var skin_color_array = color_set["colors"]
				var skin_color = Color(skin_color_array[0], skin_color_array[1], skin_color_array[2])
				print("new skin color: ", skin_color)
				skin_shader.set_shader_parameter("albedo", skin_color)
				var ratios = HumanizerHelper.get_skin_color_ratios()
				skin_shader.set_shader_parameter("skin_ratios",ratios)
				# Tried to set the material config but it requires a StandardMaterial3D which a skin_shader
				# does not conform to
				#var body = human_config.get_equipment_in_slot("Body")
				#body.material_config.base_material_path = "res://src/materials/ToonShader/toon_material.tres"
				#humanizer.get_node("DefaultBody").set_surface_override_material(0, skin_shader)
				#human_config.skin_color = skin_color
			"Hair":
				var hair_color_array = color_set["colors"]
				var hair_color = Color(hair_color_array[0], hair_color_array[1], hair_color_array[2])
				human_config.hair_color = hair_color
			"Eyes":
				var eye_color_array = color_set["colors"]
				var eye_color = Color(eye_color_array[0], eye_color_array[1], eye_color_array[2])
				human_config.eye_color = eye_color
				
	await humanizer.load_config_async(human_config)
	humanizer.hide_clothes_vertices()
	return [humanizer, skin_shader]
