extends HBoxContainer
class_name ShapekeySlider

@onready var slider: Slider = $"HSlider"

signal change_shapekeys(values: Dictionary)

var shapekeys = []

func _ready():
	slider.drag_ended.connect(slider_drag_ended)

func emit_shapekeys():
	var data = {}
	for shapekey_name in shapekeys:
		data[shapekey_name] = slider.value / 100
	change_shapekeys.emit(data)
	
func set_value(value: int):
	slider.value = value

func slider_drag_ended(value_changed):
	emit_shapekeys()
