extends CharacterBody3D
class_name Player

@onready var player_camera: Camera3D = $Camera3D
@onready var ground_raycast: RayCast3D = $RayCast3D
@onready var audio_player: AudioStreamPlayer3D = $PlayerAudio
@onready var speed_label: Label = $Camera3D/SpeedLabel
@onready var dash_timer: Timer = $DashTimer

@onready var gun_container = $Camera3D/GunContainer
@onready var aim_ray: RayCast3D = $Camera3D/AimRay
@onready var aim_ray_end: Marker3D = $Camera3D/AimRay/AimRayEnd

var landing_sfx = preload ("res://asset/sfx/jump_landing.wav")

const MAX_SPEED = 8.0
const MAX_FALL_SPEED = 50.0
const ACCEL_RATE = 40.0
const JUMP_FORCE = 8
const RAY_REACH = 0.1
const MOUSE_SENS = 0.005
const GRAVITY = 14

const DASH_SPEED = 20

var floor_col_pos = Vector3.ZERO
var jumped = false
var prev_pos = Vector3.ZERO
var camera_height = 0
var vel_horizontal = Vector2(0, 0)
var vel_vertical = 0
var is_dashing = false
var bonus_speed = 0
var raw_input_dir = Vector2(0, 0)
var input_dir = Vector2(0, 0)

var gun_container_offset: Vector3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	prev_pos = player_camera.position
	camera_height = player_camera.position.y
	gun_container_offset = gun_container.position

func _input(event):
	if event is InputEventMouseMotion:
		rotate_player(event)
	if event.is_action_pressed("jump") and is_on_floor():
		vel_vertical = JUMP_FORCE
		jumped = true
	if event.is_action_pressed("dash"):
		is_dashing = true
		vel_vertical = 0
		dash_timer.start()
	if event.is_action_pressed("primary_shoot"):
		primary_shoot()

func _process(delta):
	interpolate_camera_pos(delta)

func _physics_process(delta):
	if not is_dashing:
		raw_input_dir = Input.get_vector("left", "right", "up", "down")
		input_dir = raw_input_dir.rotated( - rotation.y)

	# If the next line is for grounded only, we will have bunnyhop tech
	# If not move, gradually reduce movespeed to 0
	vel_horizontal -= vel_horizontal.normalized() * (ACCEL_RATE / 2) * delta
	# Stand still
	if vel_horizontal.length_squared() < 1.0 and input_dir.length_squared() < 0.01:
		vel_horizontal = Vector2.ZERO

	if is_on_floor():
		if vel_vertical < - 1:
			audio_player.stream = landing_sfx
			audio_player.play()
			jumped = false
			vel_vertical = 0
	else:
		if not is_dashing:
			vel_vertical -= GRAVITY * delta
			vel_vertical = clamp(vel_vertical, -MAX_FALL_SPEED, 10000)

	# Use the next line will make player move faster when strafing + rotate camera
	# var current_speed = vel_horizontal.dot(input_dir)
	var current_speed = vel_horizontal.length()
	var add_speed = clamp(MAX_SPEED - current_speed, 0.0, ACCEL_RATE * delta)
	vel_horizontal += input_dir * add_speed

	velocity = Vector3(vel_horizontal.x, vel_vertical, vel_horizontal.y)

	if is_dashing:
		bonus_speed = DASH_SPEED
	else:
		bonus_speed = lerpf(bonus_speed, 0, delta * 10)
	velocity += velocity.normalized() * bonus_speed
	var h_speed = snapped(vel_horizontal.length() + bonus_speed, 0.1)
	var v_speed = snapped(vel_vertical, 0.1)
	speed_label.text = "HSpeed: {0} u/s\nVSpeed: {1} u/s".format([h_speed, v_speed])
	move_and_slide()

	var gun_sway_velocity = velocity * transform.basis
	gun_container.position = lerp(gun_container.position, gun_container_offset - (gun_sway_velocity / 500), delta * 10)

	camera_tilt(delta)

func primary_shoot():
	var gun: Gun = gun_container.get_child(0)
	if not gun.try_shoot():
		return
	gun.play_primary_shoot_animation()
	var bullet_inst: GunHitscan = gun.bullet_trail.instantiate()
	if aim_ray.is_colliding():
		bullet_inst.init(gun.barrel.global_position, aim_ray.get_collision_point())
		if aim_ray.get_collider().is_in_group("enemy"):
			# TODO: Damage enemy here
			return
	else:
		bullet_inst.init(gun.barrel.global_position, aim_ray_end.global_position)
	get_parent().add_child(bullet_inst)

func interpolate_camera_pos(delta):
	var camera_pos = prev_pos.lerp(position, delta * 70)
	player_camera.global_position = camera_pos
	player_camera.position.y = camera_height
	prev_pos = camera_pos

func rotate_player(event):
	rotate(Vector3(0, -1, 0), event.relative.x * MOUSE_SENS)
	player_camera.rotate_x( - event.relative.y * MOUSE_SENS)
	player_camera.rotation.x = clamp(player_camera.global_rotation.x, deg_to_rad( - 90), deg_to_rad(90))

func camera_tilt(delta):
	if raw_input_dir.x < 0:
		player_camera.rotation.z = lerp(player_camera.rotation.z, deg_to_rad(3.0), delta * 5)
	elif raw_input_dir.x > 0:
		player_camera.rotation.z = lerp(player_camera.rotation.z, deg_to_rad( - 3.0), delta * 5)
	else:
		player_camera.rotation.z = lerp(player_camera.rotation.z, deg_to_rad(0), delta * 5)

func _on_dash_timer_timeout() -> void:
	is_dashing = false
