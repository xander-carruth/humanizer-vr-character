extends Node3D

@onready var character_creator_menu = $"CharacterCreatorMenu/Viewport/CharacterCreatorMenu"
@onready var humanizer = $"HumanizerRoot/AutoUpdatingHumanizer"
var skin_shader: ShaderMaterial = load("res://CharacterCreator/skin_color_shader.tres")

func _ready():
	_setup_humanizer()
	_connect_signals()

func _setup_humanizer():
	humanizer.get_node("DefaultBody").set_surface_override_material(0, skin_shader)
	humanizer.set_shapekeys({gender=1})
	humanizer.add_equipment(HumanizerEquipment.new("LeftEye-LowPolyEyeball"))
	humanizer.add_equipment(HumanizerEquipment.new("RightEye-LowPolyEyeball"))
	humanizer.add_equipment(HumanizerEquipment.new("LeftEyelash"))
	humanizer.add_equipment(HumanizerEquipment.new("RightEyelash"))
	humanizer.add_equipment(HumanizerEquipment.new("MaleDefaultPants"))
	humanizer.add_equipment(HumanizerEquipment.new("MaleDefaultShirt"))
	humanizer.hide_clothes_vertices()
	update_skin_texture()
	
func _connect_signals():
	character_creator_menu.shapekeys_changed.connect(_on_shapekeys_changed)
	character_creator_menu.hair_changed.connect(_on_hair_changed)
	character_creator_menu.skin_changed.connect(_on_skin_changed)
	character_creator_menu.save_pressed.connect(_on_save_pressed)
	
func _on_shapekeys_changed(shapekey_values: Dictionary):
	humanizer.set_shapekeys(shapekey_values)

func _on_hair_changed(hair_name: String):
	if hair_name == "Bald":
		humanizer.remove_equipment_in_slot("Hair")
	else:
		humanizer.add_equipment(HumanizerEquipment.new(hair_name))
	
func _on_skin_changed(skin_color: Color):
	skin_shader.set_shader_parameter("albedo", skin_color)
	
func update_skin_texture():
	var ratios = HumanizerHelper.get_skin_color_ratios()
	skin_shader.set_shader_parameter("skin_ratios",ratios)
	#print(ratios)

func _on_save_pressed():
	HumanizerHelper.save_humanizer_to_json(humanizer, skin_shader, "res://data/test.json")
