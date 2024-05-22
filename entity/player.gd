extends CharacterBody3D
class_name Player

@export var can_wall_jump: bool
@export var can_wall_cling: bool
@export var max_air_jump = 2
@export var dash_cd = 0.5

@onready var player_camera: Camera3D = $Neck/Camera3D
@onready var audio_player: AudioStreamPlayer3D = $PlayerAudio
@onready var debug_label: Label = $Neck/Camera3D/DebugLabel
@onready var dash_duration_timer: Timer = $DashDuration
@onready var neck: Node3D = $Neck
@onready var state_chart: StateChart = $StateChart
@onready var wall_raycast: RayCast3D = $WallRaycast

@onready var gun_container = $Neck/Camera3D/GunContainer
@onready var aim_ray: RayCast3D = $Neck/Camera3D/AimRay
@onready var aim_ray_end: Marker3D = $Neck/Camera3D/AimRay/AimRayEnd

var landing_sfx = preload ("res://asset/sfx/jump_landing.wav")

const MAX_SPEED = 8.0
const MAX_FALL_SPEED = 50.0
const ACCEL_RATE = 40.0
const JUMP_FORCE = 8
const RAY_REACH = 0.1
const MOUSE_SENS = 0.005
const GRAVITY = 14

const DASH_SPEED = 15
const SLIDE_SPEED = 5

var floor_col_pos = Vector3.ZERO
var jumped = false
var vel_horizontal = Vector2(0, 0)
var vel_vertical = 0
var is_dashing = false
var is_sliding = false
var bonus_speed = 0
var raw_input_dir = Vector2(0, 0)
var input_dir = Vector2(0, 0)

var gun_container_offset: Vector3
var last_dashed_timestamp
var current_air_jump_count = 0
var slide_dir = Vector2(0, 0)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gun_container_offset = gun_container.position
	last_dashed_timestamp = Time.get_ticks_msec() - dash_cd * 1000

func _input(event):
	if event is InputEventMouseMotion:
		rotate_player(event)
	if event.is_action_pressed("dash"):
		if last_dashed_timestamp + dash_cd * 1000 <= Time.get_ticks_msec():
			last_dashed_timestamp = Time.get_ticks_msec()
			is_dashing = true
			vel_vertical = 0
			dash_duration_timer.start()
	if event.is_action_pressed("primary_attack"):
		primary_attack()
	if event.is_action_pressed("secondary_attack"):
		secondary_attack()

func _physics_process(delta):
	if is_dashing or is_sliding:
		if raw_input_dir == Vector2.ZERO:
			raw_input_dir = Vector2(0, -1)
			input_dir = raw_input_dir.rotated( - rotation.y)
	if not is_dashing and not is_sliding:
		raw_input_dir = Input.get_vector("left", "right", "up", "down")
		input_dir = raw_input_dir.rotated( - rotation.y)

	# If the next line is for grounded only, we will have bunnyhop tech
	# If not move, gradually reduce movespeed to 0 (speed decay)
	vel_horizontal -= vel_horizontal.normalized() * (ACCEL_RATE / 2) * delta
	# Stand still
	if vel_horizontal.length_squared() < 1.0 and input_dir.length_squared() < 0.01:
		vel_horizontal = Vector2.ZERO

	if is_on_floor():
		state_chart.send_event("grounded")
		current_air_jump_count = 0
		if vel_vertical < 0:
			play_sfx(landing_sfx)
			jumped = false
			vel_vertical = 0
	else:
		state_chart.send_event("airborne")

	# Use the next line will make player move faster when strafing + rotate camera
	# var current_speed = vel_horizontal.dot(input_dir)
	var current_speed = vel_horizontal.length()
	var add_speed = clamp(MAX_SPEED - current_speed, 0.0, ACCEL_RATE * delta)

	if is_dashing or is_sliding:
		vel_horizontal = input_dir * MAX_SPEED
	else:
		vel_horizontal += input_dir * add_speed

	velocity = Vector3(vel_horizontal.x, vel_vertical, vel_horizontal.y)

	# Bonus speed
	if is_dashing:
		bonus_speed = DASH_SPEED
	elif is_sliding:
		bonus_speed = SLIDE_SPEED
	else:
		if is_on_floor():
			bonus_speed = lerpf(bonus_speed, 0, delta * 9)
		else:
			bonus_speed = lerpf(bonus_speed, 0, delta * 3)

	var velocity_dir = velocity.normalized()
	velocity += Vector3(velocity_dir.x, 0, velocity_dir.z) * bonus_speed
	move_and_slide()

	show_debug_label()
	var gun_sway_velocity = velocity * transform.basis
	gun_container.position = lerp(gun_container.position, gun_container_offset - (gun_sway_velocity / 500), delta * 10)
	camera_tilt(delta)

func play_sfx(sfx: AudioStream):
	audio_player.stream = sfx
	audio_player.pitch_scale = randf_range(0.8, 1.2)
	audio_player.play()

func show_debug_label():
	var h_speed = snapped(Vector3(velocity.x, 0, velocity.z).length(), 0.1)
	var v_speed = snapped(vel_vertical, 0.1)
	debug_label.text = "HSpeed: {0} u/s\nVSpeed: {1} u/s".format([h_speed, v_speed])
	debug_label.text += "\nOn ground: {0} | wall-cling: {1}".format([is_on_floor(), moving_toward_wall()])
	debug_label.text += "\nIs dashing: {0} | Is sliding: {1}".format([is_dashing, is_sliding])
	debug_label.text += "\nAir jumps left: {0}".format([max_air_jump - current_air_jump_count])

func jump(multiplier=1.0):
	vel_vertical = JUMP_FORCE * multiplier
	jumped = true
	state_chart.send_event("jump")
	is_dashing = false
	is_sliding = false

func primary_attack():
	var gun: Gun = gun_container.get_child(0)
	if not gun.try_primary_attack():
		return
	gun.play_primary_attack_anim()
	perform_attack(gun)

func secondary_attack():
	var gun: Gun = gun_container.get_child(0)
	if not gun.try_secondary_attack():
		return
	gun.play_secondary_attack_anim()
	if not gun.gun_resource.secondary_not_attack:
		perform_attack(gun)

func perform_attack(gun: Gun):
	var bullet_inst: GunHitscan = gun.bullet_trail.instantiate()
	if aim_ray.is_colliding():
		bullet_inst.init(gun.barrel.global_position, aim_ray.get_collision_point())
		if aim_ray.get_collider().is_in_group("enemy"):
			# TODO: Damage enemy here
			return
	else:
		bullet_inst.init(gun.barrel.global_position, aim_ray_end.global_position)
	get_parent().add_child(bullet_inst)

func rotate_player(event):
	rotate(Vector3(0, -1, 0), event.relative.x * (GameManager.mouse_sensitivity / 10000))
	player_camera.rotate_x( - event.relative.y * (GameManager.mouse_sensitivity / 10000))
	player_camera.rotation.y = 0
	player_camera.rotation.z = 0
	player_camera.rotation.x = clamp(player_camera.global_rotation.x, deg_to_rad( - 80), deg_to_rad(80))

func camera_tilt(delta):
	if raw_input_dir.x < 0:
		neck.rotation.z = lerp(neck.rotation.z, deg_to_rad(3.0), delta * 5)
	elif raw_input_dir.x > 0:
		neck.rotation.z = lerp(neck.rotation.z, deg_to_rad( - 3.0), delta * 5)
	else:
		neck.rotation.z = lerp(neck.rotation.z, deg_to_rad(0), delta * 5)

	if is_sliding:
		neck.position.y = lerp(neck.position.y, -1.0, delta * 5)
	else:
		neck.position.y = lerp(neck.position.y, 0.0, delta * 5)

func _on_dash_duration_timeout() -> void:
	is_dashing = false

func _on_grounded_state_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		jump()

func _on_airborne_state_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		if moving_toward_wall() and can_wall_jump:
			var wall_normal = get_wall_normal()
			# Jump away from wall
			vel_horizontal += Vector2(wall_normal.x, wall_normal.z) * 16
			jump(0.8)
		elif current_air_jump_count < max_air_jump:
			current_air_jump_count += 1
			jump()

func _on_grounded_state_physics_processing(_delta: float):
	if Input.is_action_pressed("crouch"):
		is_sliding = true
	else:
		is_sliding = false

func _on_airborne_state_entered() -> void:
	is_sliding = false

func _on_airborne_state_physics_processing(delta: float) -> void:
	if not is_dashing:
		vel_vertical -= GRAVITY * delta
	if moving_toward_wall() and can_wall_cling:
		vel_vertical = clampf(vel_vertical, -1, 10000)
	vel_vertical = clamp(vel_vertical, -MAX_FALL_SPEED, 10000)

func moving_toward_wall() -> bool:
	wall_raycast.target_position = Vector3(raw_input_dir.x, 0, raw_input_dir.y)
	if is_on_wall_only() and wall_raycast.is_colliding():
		return true
	return false