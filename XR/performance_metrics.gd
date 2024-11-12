extends Control

const SAMPLES_TO_AVERAGE := 72

class Metric:
	var samples := []

	var callback: Callable
	var label: Label
	var units: String
	var averaged: bool

	func _init(p_callback: Callable, p_label: Label, p_units: String, p_averaged := true) -> void:
		callback = p_callback
		label = p_label
		units = p_units
		averaged = p_averaged

	func clear() -> void:
		samples.clear()

	func update() -> void:
		if averaged:
			_add_sample(callback.call())
		else:
			samples = [ callback.call() ]
		label.text = ("%.3f" % get_average()) + " " + units

	func _add_sample(p_value: float) -> void:
		samples.push_back(p_value)
		if samples.size() > SAMPLES_TO_AVERAGE:
			samples.pop_front()

	func get_average() -> float:
		var total: float = 0
		for x in samples:
			total += x
		return total / samples.size()

var _viewport_rid: RID
var _metrics: Array[Metric]

func set_viewport_rid(p_viewport_rid: RID) -> void:
	if _viewport_rid.is_valid():
		RenderingServer.viewport_set_measure_render_time(_viewport_rid, false)

	_viewport_rid = p_viewport_rid

	if _viewport_rid.is_valid():
		RenderingServer.viewport_set_measure_render_time(_viewport_rid, true)

	for metric in _metrics:
		metric.clear()

func _get_cpu_time() -> float:
	return RenderingServer.viewport_get_measured_render_time_cpu(_viewport_rid) + RenderingServer.get_frame_setup_time_cpu()

func _get_gpu_time() -> float:
	return RenderingServer.viewport_get_measured_render_time_gpu(_viewport_rid)

func _get_total_time() -> float:
	return _get_cpu_time() + _get_gpu_time()

func _get_fps() -> float:
	return Performance.get_monitor(Performance.TIME_FPS)

func _ready() -> void:
	_metrics.push_back(Metric.new(_get_cpu_time, %CPURenderTimeValue, "ms"))
	_metrics.push_back(Metric.new(_get_gpu_time, %GPURenderTimeValue, "ms"))
	_metrics.push_back(Metric.new(_get_total_time, %TotalRenderTimeValue, "ms"))
	_metrics.push_back(Metric.new(_get_fps, %FPSValue, "", false))

	set_viewport_rid(get_viewport().get_viewport_rid())

func _process(_delta: float) -> void:
	if _viewport_rid.is_valid():
		for metric in _metrics:
			metric.update()
