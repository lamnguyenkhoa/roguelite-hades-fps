extends CharacterBody3D
class_name Player

@onready var camera: Camera3D = $Camera3D
@onready var ground_raycast: RayCast3D = $RayCast3D
@onready var audio_player: AudioStreamPlayer3D = $PlayerAudio
@onready var speed_label: Label = $Camera3D/SpeedLabel

var landing = preload ("res://asset/sfx/jump_landing.wav")

const MAX_SPEED = 10.0
const ACCEL = 50.0
const JUMP_FORCE = 7
const RAY_REACH = 0.1
const MOUSE_SENS = 0.005
const GRAVITY = 11

var floor_col_pos = Vector3.ZERO
var jumped = false
var prev_pos = Vector3.ZERO
var camera_height = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	prev_pos = camera.position
	camera_height = camera.position.y

func _input(event):
	if event is InputEventMouseMotion:
		rotate_player(event)

func _process(delta):
	interpolate_camera_pos(delta)

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	input_dir = input_dir.rotated( - rotation.y)

	var vel_horizontal = Vector2(velocity.x, velocity.z)
	var vel_vertical = velocity.y
	
	# If the next line is for grounded only, we will have bunnyhop tech
	# If not move, gradually reduce movespeed to 0
	vel_horizontal -= vel_horizontal.normalized() * (ACCEL / 2) * delta

	if grounded():
		if jumped:
			audio_player.stream = landing
			audio_player.play()
			jumped = false
		# Stand still
		if vel_horizontal.length_squared() < 1.0 and input_dir.length_squared() < 0.01:
			vel_horizontal = Vector2.ZERO
	else:
		vel_vertical -= GRAVITY * delta

	# Use the next line will make player move faster when strafing + rotate camera
	# var current_speed = vel_horizontal.dot(input_dir)
	var current_speed = vel_horizontal.length()
	var add_speed = clamp(MAX_SPEED - current_speed, 0.0, ACCEL * delta)
	vel_horizontal += input_dir * add_speed
		
	if (Input.is_action_pressed("jump") or Input.is_action_just_pressed("jump")) and grounded():
		vel_vertical = JUMP_FORCE
		jumped = true

	velocity = Vector3(vel_horizontal.x, vel_vertical, vel_horizontal.y)
	var speedometer = snapped(vel_horizontal.length(), 0.1)
	speed_label.text = "{0} u/s".format([speedometer])
	move_and_slide()

func grounded():
	var origin = global_position + ground_raycast.position
	var target = Vector3.DOWN * RAY_REACH
	var query = PhysicsRayQueryParameters3D.create(origin, origin + target)
	if get_world_3d() == null:
		return false
	var check = get_world_3d().direct_space_state.intersect_ray(query)
	floor_col_pos = check
	return check.size() > 0

func interpolate_camera_pos(delta):
	var camera_pos = prev_pos.lerp(position, delta * 70)
	camera.global_position = camera_pos
	camera.position.y = camera_height
	prev_pos = camera_pos

func rotate_player(event):
	rotate(Vector3(0, -1, 0), event.relative.x * MOUSE_SENS)
	camera.rotate_x( - event.relative.y * MOUSE_SENS)
	camera.rotation.y = 0
	camera.rotation.z = 0
	camera.rotation.x = clamp(camera.global_rotation.x, deg_to_rad( - 90), deg_to_rad(90))