extends Node


func async(f: Callable) -> Variant:
	var co := FunctionState.new()
	co.start(f)
	if co.has_completed:
		return co.result
	return co


func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout


class _Select extends RefCounted:
	signal completed(result)
	
	var _co_list: Array
	
	func _init(co_list: Array):
		assert(co_list.size() > 0)
		_co_list = co_list
		for co in co_list:
			assert(co.has_signal("completed"))
			co.completed.connect(_co_completed)
	
	func _co_completed(result = null) -> void:
		for co in _co_list:
			co.completed.disconnect(_co_completed)
		completed.emit(result)


func select(co_list: Array):
	return _Select.new(co_list)

class _Join extends RefCounted:
	signal completed(result)
	
	var _co_list: Array
	var _results: Array
	var _incomplete: int
	
	func _init(co_list: Array):
		assert(co_list.size() > 0)
		assert(co_list.size() < 64)
		_co_list = co_list
		_results = []
		_incomplete = (1 << co_list.size()) - 1
		for i in range(co_list.size()):
			assert(_co_list[i].has_signal("completed"))
			_co_list[i].completed.connect(_co_completed.bind(i))
			_results.push_back(null)
	
	func _co_completed(result, i: int):
		var bit = 1 << i
		assert(_incomplete & bit)
		_results[i] = result
		_incomplete &= ~bit
		if _incomplete == 0:
			completed.emit(_results)

func join(co_list: Array):
	return _Join.new(co_list)


