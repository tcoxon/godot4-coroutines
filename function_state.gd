extends RefCounted
class_name FunctionState

signal completed(result)

var _f: Callable
var has_completed := false
var result

func start(f: Callable) -> void:
	assert(!_f)
	_f = f
	result = await(f.call())
	has_completed = true
	completed.emit(result)

func _to_string() -> String:
	return "<FunctionState:" + str(_f) + ">"
