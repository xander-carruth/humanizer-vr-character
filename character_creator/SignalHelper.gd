extends Node
class_name SignalHelper

static func forward_signal(from_signal: Signal, to_signal: Signal):
	from_signal.connect(func(val): to_signal.emit(val))

static func forward_simple_signal(from_signal: Signal, to_signal: Signal):
	from_signal.connect(func(): to_signal.emit())
