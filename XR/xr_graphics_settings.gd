extends Control

var xr_interface: OpenXRInterface

@onready var root_viewport: Viewport = get_tree().get_root().get_viewport()

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")

	if xr_interface:
		%VRS.button_pressed = (root_viewport.vrs_mode == Viewport.VRS_XR)
		%VRSStrength.value = xr_interface.vrs_strength
		%VRSRadius.value = xr_interface.vrs_min_radius

func _on_vrs_toggled(p_enabled: bool) -> void:
	if xr_interface:
		root_viewport.vrs_mode = Viewport.VRS_XR if p_enabled else Viewport.VRS_DISABLED
		root_viewport.vrs_update_mode = Viewport.VRS_UPDATE_ONCE

func _on_vrs_strength_value_changed(p_value: float) -> void:
	if xr_interface:
		xr_interface.vrs_strength = p_value
		root_viewport.vrs_update_mode = Viewport.VRS_UPDATE_ONCE

func _on_vrs_radius_value_changed(p_value: float) -> void:
	if xr_interface:
		xr_interface.vrs_min_radius = p_value
		root_viewport.vrs_update_mode = Viewport.VRS_UPDATE_ONCE
