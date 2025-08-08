extends CanvasLayer
signal shapekeys_changed(shapekey_values: Dictionary)
signal hair_changed(hair_name: String)
signal skin_changed(skin_color: Color)
signal save_pressed()

@export var height_slider: ShapekeySlider
@export var sex_input: ArrowInputBox
@export var hair_input: ArrowInputBox
@export var image_color_picker: ColorPickerRect
@export var save_button: Button
var sexes = ["Male", "Female"]
var hair_options = []

func _ready():
	var shapekey_categories = HumanizerTargetService.get_shapekey_categories()
	var category_keys = shapekey_categories["Macro"]
	# access "height" key
	height_slider.shapekeys.append(category_keys[2])
	height_slider.set_value(50)

	hair_options.append("Bald")
	for hair_type: HumanizerEquipmentType in HumanizerRegistry.filter_equipment({"slot"="Hair"}):
		var hair_name = hair_type.resource_name
		hair_options.append(hair_name)
	hair_input.set_items(hair_options)
	
	sex_input.set_items(sexes)
	_connect_signals()

func _connect_signals():
	height_slider.change_shapekeys.connect(_set_shapekeys)
	sex_input.field_value_changed.connect(_sex_changed)
	hair_input.field_value_changed.connect(_hair_changed)
	image_color_picker.color_picked.connect(_skin_changed)
	SignalHelper.forward_simple_signal(save_button.pressed, save_pressed)

func _set_shapekeys(shapekey_values:Dictionary):
	shapekeys_changed.emit(shapekey_values)
	
func _sex_changed(sex: String):
	if sex == "Male":
		_set_shapekeys({gender=1})
	elif sex == "Female":
		_set_shapekeys({gender=0})

func _hair_changed(hair_name: String):
	hair_changed.emit(hair_name)
	
func _skin_changed(skin_color: Color):
	skin_changed.emit(skin_color)
