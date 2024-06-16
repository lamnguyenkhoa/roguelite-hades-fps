extends BaseProjectile
class_name GunHitscan

@export var thickness = 4
@export var spark_effect: PackedScene

var alpha = 1.0

const FADE_SPEED = 4

func _ready():
	var dup_mat = material_override.duplicate()
	material_override = dup_mat

func init(pos1: Vector3, pos2: Vector3):
	self.scale = Vector3(0.01 * thickness, 0.01 * thickness, pos1.distance_to(pos2))
	self.look_at_from_position((pos1 + pos2) / 2, pos2, Vector3.UP)

func _process(delta):
	alpha -= delta * FADE_SPEED
	alpha = clamp(alpha, 0, 1)
	material_override.albedo_color.a = alpha

func create_spark(pos: Vector3, normal: Vector3):
	var relative_normal = pos + normal
	var spark_inst = spark_effect.instantiate()
	get_parent().add_child(spark_inst)
	spark_inst.global_position = pos
	spark_inst.look_at(relative_normal, Vector3.UP)

# func trigger_particles(pos, gun_pos, on_enemy):
# 	if on_enemy:
# 		blood.position = pos
# 		blood.look_at(gun_pos)
# 		blood.emitting = true
# 	else:
# 		terrain.position = pos
# 		terrain.look_at(gun_pos)
# 		terrain.emitting = true

func _on_timer_timeout():
	queue_free()
