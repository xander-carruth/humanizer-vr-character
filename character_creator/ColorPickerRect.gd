extends TextureRect
class_name ColorPickerRect

signal color_picked(color: Color)

var _img: Image                          # RAM copy of the texture

func _ready() -> void:
	# Texture2D → Image (no lock/unlock needed in 4.x)
	_img = (texture as Texture2D).get_image()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var local = event.position
		var uv = local / size                    # 0-1 range
		if uv.x < 0.0 or uv.y < 0.0 or uv.x > 1.0 or uv.y > 1.0:
			return                                # clicked outside letterboxed area
		var px := Vector2i(uv.x * _img.get_width(),
						   uv.y * _img.get_height())
		var color = _img.get_pixel(px.x, px.y)
		color_picked.emit(color)
