extends HBoxContainer
class_name ArrowInputBox

signal field_value_changed(new_value: String)

@export var field_name: String = ""

@onready var field_name_label: Label = $"FieldName"
@onready var field_value: Label = $"FieldValue"
@onready var left_arrow: Button = $"LeftArrow"
@onready var right_arrow: Button = $"RightArrow"

var current_index = 0
var _items = []

func _ready():
	field_name_label.text = field_name
	_connect_signals()

func set_items(new_items: Array):
	_items = new_items
	current_index = 0
	if _items.size() > 0:
		field_value.text = _items[current_index]

func _connect_signals():
	left_arrow.pressed.connect(_decrement_index)
	right_arrow.pressed.connect(_increment_index)

func _decrement_index():
	if current_index != 0 and _items.size() > 0:
		current_index -= 1
		_update_field_value()
	
func _increment_index():
	if current_index != _items.size() - 1 and _items.size() > 0:
		current_index += 1
		_update_field_value()
	
func _update_field_value():
	field_value.text = _items[current_index]
	field_value_changed.emit(_items[current_index])
