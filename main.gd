extends Node3D

const FORCE_BENCHMARKING := false

func _ready() -> void:
	if FORCE_BENCHMARKING or OS.has_feature("vr_benchmarking") or OS.get_cmdline_user_args().has('--vr-benchmarking'):
		print("About to BENCH DRS")
		do_vr_benchmarking()

func do_vr_benchmarking() -> void:
	var benchmarking_positions: Node3D = $BenchmarkingPositions
	var xr_player: XROrigin3D = $XRPlayer

	xr_player.player_body.enabled = false

	await get_tree().create_timer(2.0).timeout

	# We use .set() in case we aren't using a version with the patch.
	XRServer.set('camera_locked_to_origin', true)
	xr_player.performance_metrics_layer.visible = false
	xr_player.performance_metrics.set_viewport_rid(get_viewport().get_viewport_rid())

	var metrics := {}

	for marker in benchmarking_positions.get_children():
		xr_player.global_transform = marker.global_transform
		await get_tree().create_timer(5.0).timeout

		metrics[marker.name] = xr_player.performance_metrics.get_metrics()

	var rn: String = "vulkan" if RenderingServer.get_rendering_device() else "compatibility"
	var fn: String = "user://metrics-%s.json" % rn

	var file := FileAccess.open(fn, FileAccess.WRITE)
	file.store_string(JSON.stringify(metrics))
	file.close()

	print("Benchmarks: ", metrics)
	print("Benchmarks written to: ", fn)

	XRServer.set('camera_locked_to_origin', false)
	xr_player.player_body.enabled = true
	xr_player.reset_position()
	xr_player.performance_metrics.set_viewport_rid(RID())
