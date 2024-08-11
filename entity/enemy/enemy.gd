extends CharacterBody3D
class_name Enemy

@export var data: EnemyResource
@export var bloodsplatter: PackedScene

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var current_hp: int
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var navigation_initialized = false

func _ready():
	current_hp = data.max_hp
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	navigation_initialized = true

func _physics_process(_delta):
	if GameManager.player:
		nav_agent.target_position = GameManager.player.global_position

	if navigation_initialized:
		var current_position = global_position
		var next_position = nav_agent.get_next_path_position()
		var move_dir = (next_position - current_position).normalized()
		var new_velocity = move_dir * data.base_movespeed
		nav_agent.velocity = new_velocity

## Return true if this kill enemy
func damaged(value: int) -> bool:
	current_hp = clamp(current_hp - value, 0, data.max_hp)
	if current_hp <= 0:
		dead()
		return true
	return false

func play_on_damaged_effect(pos: Vector3, normal: Vector3):
	var bs_inst = bloodsplatter.instantiate()
	get_parent().add_child(bs_inst)
	bs_inst.global_position = pos

	if normal.is_equal_approx(Vector3.DOWN):
		bs_inst.rotation_degrees.x = -90
	elif normal.is_equal_approx(Vector3.UP):
		bs_inst.rotation_degrees.x = 90
	else:
		bs_inst.look_at(pos + normal, Vector3.UP)

func dead():
	call_deferred("queue_free")

func _on_navigation_agent_3d_target_reached() -> void:
	print("Reached! Attacked player")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
