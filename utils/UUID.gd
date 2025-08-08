extends Node
class_name UUID

static func uuid_v4() -> String:
	var hex = "0123456789abcdef"

	var a = _rand_hex(8)
	var b = _rand_hex(4)
	var c = "4" + _rand_hex(3)  # version 4
	var d = hex[(randi() % 4) + 8] + _rand_hex(3)  # variant
	var e = _rand_hex(12)
	return "%s-%s-%s-%s-%s" % [a, b, c, d, e]

static func _rand_hex(n) -> String:
	var hex = "0123456789abcdef"
	var s = ""
	for i in n:
		s += hex[randi() % 16]
	return s
