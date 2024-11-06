class_name XRPlayer
extends XROrigin3D

const BULLET_SCENE := preload("../Player/Bullet.tscn")

## Speed of shot bullets.
@export var bullet_speed := 10.0

@onready var left_controller: XRController3D = $LeftController
@onready var right_controller: XRController3D = $RightController

@onready var left_hand_mesh: Node3D = %LeftHandMesh
@onready var right_hand_mesh: Node3D = %RightHandMesh

func _on_left_controller_button_pressed(p_name:String) -> void:
	if p_name == 'trigger_click':
		left_hand_mesh.visible = false

func _on_left_controller_button_released(p_name: String) -> void:
	if p_name == 'trigger_click':
		left_hand_mesh.visible = true

func _on_right_controller_button_pressed(p_name: String) -> void:
	if p_name == 'trigger_click':
		shoot()

func _on_right_controller_button_released(p_name: String) -> void:
	pass

func shoot() -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.shooter = self
	var aim_direction = -right_controller.global_transform.basis.z
	bullet.velocity = aim_direction * bullet_speed
	bullet.distance_limit = 14.0
	get_parent().add_child(bullet)
	bullet.global_position = right_controller.global_position


