extends Node3D

func _ready() -> void:
	pass
	#$XRPlayer.set_force_camera_transform(true, $Marker3D.global_transform)
	#XRServer.camera_locked_to_origin = false

func _process(_delta: float) -> void:
	pass
	#print("normal kinda process")
	#$XRPlayer/XRCamera3D.global_transform = $Marker3D.global_transform
