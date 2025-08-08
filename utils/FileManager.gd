extends Node
class_name FileManager

static func write_text_to_file(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(text)
		file.close()

# load json
static func load_text_from_file(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Could not open %s" % path)
		return ""

	var text: String = f.get_as_text()
	f.close()
	return text
