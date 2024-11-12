extends Control

const SAMPLES_TO_AVERAGE := 100

class Metric:
	var samples := []
	var callback: Callable

	func _init(p_callback: Callable) -> void:
		callback = p_callback

	func clear() -> void:
		samples.clear()

	func update() -> void:
		_add_sample(callback.call())

	func _add_sample(p_value: float) -> void:
		samples.push_back(p_value)
		if samples.size() > SAMPLES_TO_AVERAGE:
			samples.pop_front()

	func get_average() -> float:
		if samples.size() == 0:
			return 0.0
		var total: float = 0
		for x in samples:
			total += x
		return total / samples.size()

class CustomXRInterface extends XRInterfaceExtension:
	var _previous_frame_ticks: int
	var _frame_time: float

	func _initialize() -> bool:
		return true

	func _is_initialized() -> bool:
		return true

	func _uninitialize() -> void:
		pass

	func _end_frame() -> void:
		if _previous_frame_ticks == 0:
			_previous_frame_ticks = Time.get_ticks_usec()
		else:
			var current_ticks := Time.get_ticks_usec()
			_frame_time = float(current_ticks - _previous_frame_ticks) / 1000.0
			_previous_frame_ticks = current_ticks

	func get_frame_time() -> float:
		return _frame_time

var _viewport_rid: RID

var _frame_time_real := Metric.new(_get_frame_time_real)
var _frame_time_estimated := Metric.new(_get_frame_time_estimated)
var _custom_xr_interface: CustomXRInterface

func _ready() -> void:
	# Add our custom XR interface.
	_custom_xr_interface = XRServer.find_interface("CustomXRInterface")
	if not _custom_xr_interface:
		_custom_xr_interface = CustomXRInterface.new()
		XRServer.add_interface(_custom_xr_interface)
	if not _custom_xr_interface.is_initialized():
		_custom_xr_interface.initialize()

	# For testing:
	#set_viewport_rid(get_viewport().get_viewport_rid())

func set_viewport_rid(p_viewport_rid: RID) -> void:
	if _viewport_rid.is_valid():
		RenderingServer.viewport_set_measure_render_time(_viewport_rid, false)

	_viewport_rid = p_viewport_rid

	if _viewport_rid.is_valid():
		RenderingServer.viewport_set_measure_render_time(_viewport_rid, true)

func _get_frame_time_real() -> float:
	if RenderingServer.get_rendering_device():
		# Only actually available on RD renderers.
		return RenderingServer.viewport_get_measured_render_time_gpu(_viewport_rid) + RenderingServer.viewport_get_measured_render_time_cpu(_viewport_rid) + RenderingServer.get_frame_setup_time_cpu()
	return 0.0

func _get_frame_time_estimated() -> float:
	if not _custom_xr_interface:
		return 0.0

	# This can be bigger than what you'd expect from our FPS, but can't be lower.
	# However, we don't have real frame time metrics on GLES, so this is an OK
	# estimate.
	return _custom_xr_interface.get_frame_time()

func _get_fps() -> float:
	return Performance.get_monitor(Performance.TIME_FPS)

func _process(_delta: float) -> void:
	if _viewport_rid.is_valid():
		_frame_time_real.update()
		_frame_time_estimated.update()

func _on_timer_timeout() -> void:
	var metrics := get_metrics()
	%FrameTimeValue.text = "%.3f ms" % metrics['frame_time_real']
	%XRFrameTimeValue.text = "%.3f ms" % metrics['frame_time_estimated']
	%FPSValue.text = "%s" % metrics['fps']

func get_metrics() -> Dictionary:
	return {
		"frame_time_real": _frame_time_real.get_average(),
		"frame_time_estimated": _frame_time_estimated.get_average(),
		"fps": Performance.get_monitor(Performance.TIME_FPS),
	}
