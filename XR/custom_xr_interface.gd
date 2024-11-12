extends XRInterfaceExtension

const MAX_FRAME_TIME_SAMPLES := 72

var _initialized := false

var _previous_frame_ticks: int = 0
var _frame_time_samples := []

func _get_name() -> StringName:
	return "CustomXRInterface"

func _initialize() -> bool:
	if _initialized:
		return true

	_initialized = true

	return true

func _is_initialized() -> bool:
	return _initialized

func _uninitialize() -> void:
	if not _initialized:
		return

	_initialized = false

	_previous_frame_ticks = 0
	_frame_time_samples.clear()

func _end_frame() -> void:
	if _previous_frame_ticks == 0:
		_previous_frame_ticks = Time.get_ticks_usec()
	else:
		var current_ticks := Time.get_ticks_usec()
		var frame_time = float(current_ticks - _previous_frame_ticks) / 1000.0
		_previous_frame_ticks = current_ticks

		_frame_time_samples.push_back(frame_time)
		if _frame_time_samples.size() > MAX_FRAME_TIME_SAMPLES:
			_frame_time_samples.pop_front()

func get_frame_time() -> float:
	if _initialized and _frame_time_samples.size() > 0:
		var total: float = 0.0
		for sample in _frame_time_samples:
			total += sample
		return total / _frame_time_samples.size()

	return 0.0
