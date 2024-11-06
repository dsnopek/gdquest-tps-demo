class_name XRPlayer
extends XROrigin3D

const BULLET_SCENE := preload("../Player/Bullet.tscn")

## Speed of shot bullets.
@export var bullet_speed := 10.0
## Projectile cooldown
@export var shoot_cooldown := 0.5
## Grenade cooldown
@export var grenade_cooldown := 0.5


@onready var left_controller: XRController3D = $LeftController
@onready var right_controller: XRController3D = $RightController

@onready var left_hand_mesh: Node3D = %LeftHandMesh
@onready var right_hand_mesh: Node3D = %RightHandMesh

@onready var bullet_spawn_point: Node3D = %BulletSpawnPoint

@onready var coin_count_layer: Node3D = $CoinCountLayer
@onready var _coin_count_layer_offset: Transform3D = coin_count_layer.transform

@onready var _shoot_cooldown_tick := shoot_cooldown
@onready var _grenade_cooldown_tick := grenade_cooldown


var _coins := 0

func _on_left_controller_button_pressed(p_name:String) -> void:
	if p_name == 'trigger_click':
		left_hand_mesh.visible = false

func _on_left_controller_button_released(p_name: String) -> void:
	if p_name == 'trigger_click':
		left_hand_mesh.visible = true

func _on_right_controller_button_pressed(p_name: String) -> void:
	if p_name == 'trigger_click':
		if _shoot_cooldown_tick > shoot_cooldown:
			_shoot_cooldown_tick = 0.0
			shoot()

func _on_right_controller_button_released(p_name: String) -> void:
	pass

func _process(_delta: float) -> void:
	# Move the coin count layer to stay attached to the left controller.
	coin_count_layer.transform = left_controller.transform * _coin_count_layer_offset

func _physics_process(p_delta: float) -> void:
	_shoot_cooldown_tick += p_delta
	_grenade_cooldown_tick += p_delta

func shoot() -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.shooter = self
	var aim_direction = -bullet_spawn_point.global_transform.basis.z
	bullet.velocity = aim_direction * bullet_speed
	bullet.distance_limit = 14.0
	get_parent().add_child(bullet)
	bullet.global_position = bullet_spawn_point.global_position

func collect_coin() -> void:
	_coins += 1
	%CoinLabel.text = "Coins:\n%d" % _coins
