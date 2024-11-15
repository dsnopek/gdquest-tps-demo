extends Node3D

const TRIPLANAR_TERRAIN_MATERIAL = preload("res://Environment/Terrain/terrain_mat.tres")
const TRIPLANAR_LARGE_TRUNK_MATERIAL = preload("res://Environment/large_tree_trunk/large_tree_trunk_mat.tres")

#const BAKED_TERRAIN_MATERIAL = preload("res://Environment/Terrain/terrain_mat_baked.tres")
const BAKED_TERRAIN_MATERIAL = preload("res://Environment/Terrain/terrain_mat_baked_4k.tres")
const BAKED_PLANE_MATERAIL = preload("res://Environment/Terrain/plane_mat_baked.tres")
const BAKED_LARGE_TRUNK_MATERIAL = preload("res://Environment/large_tree_trunk/large_tree_trunk_mat_baked.tres")

const FORCE_BENCHMARKING := false

@onready var terrain_mesh = $NavigationRegion3D/terrain_main_ground/terrain
@onready var plane_mesh = $NavigationRegion3D/terrain_main_ground/Plane

var _benchmarking_in_progress := false
var _using_triplanar_materials := true

func _ready() -> void:
	var auto_resume_demo_page := false

	var xr_interface := XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		auto_resume_demo_page = true

		var player: Node3D = $Player
		remove_child(player)
		player.queue_free()

		var xr_player: Node3D = $XRPlayer
		xr_player.left_controller.button_pressed.connect(func (p_button):
			if p_button == 'menu_button':
				do_vr_benchmarking()
		)

		xr_player.left_controller.button_pressed.connect(func (p_button):
			if p_button == 'grip_click':
				_using_triplanar_materials = not _using_triplanar_materials
				if _using_triplanar_materials:
					terrain_mesh.material_override = TRIPLANAR_TERRAIN_MATERIAL
					plane_mesh.material_override = TRIPLANAR_TERRAIN_MATERIAL
					get_tree().set_group('large_trunk_material', 'material_override', TRIPLANAR_LARGE_TRUNK_MATERIAL)
				else:
					terrain_mesh.material_override = BAKED_TERRAIN_MATERIAL
					plane_mesh.material_override = BAKED_PLANE_MATERAIL
					get_tree().set_group('large_trunk_material', 'material_override', BAKED_LARGE_TRUNK_MATERIAL)
		)
	else:
		var xr_player: Node3D = $XRPlayer
		remove_child(xr_player)
		xr_player.queue_free()

	if FORCE_BENCHMARKING or OS.has_feature("vr_benchmarking") or OS.get_cmdline_user_args().has('--vr-benchmarking'):
		do_vr_benchmarking()
		auto_resume_demo_page = true

	if auto_resume_demo_page:
		$DemoPage.resume_demo()

func do_vr_benchmarking() -> void:
	if _benchmarking_in_progress:
		return
	_benchmarking_in_progress = true

	var benchmarking_positions: Node3D = $BenchmarkingPositions
	var xr_player: XROrigin3D = $XRPlayer

	xr_player.player_body.enabled = false

	await get_tree().create_timer(2.0).timeout

	# We use .set() in case we aren't using a version with the patch.
	# See: https://github.com/godotengine/godot/pull/99145
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

	_benchmarking_in_progress = false
