extends MeshInstance3D
class_name GunHitscan

var alpha = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var dup_mat = material_override.duplicate()
	material_override = dup_mat

func init(pos1: Vector3, pos2: Vector3):
	var thickness = 2
	self.scale = Vector3(0.01 * thickness, 0.01 * thickness, pos1.distance_to(pos2))
	self.look_at_from_position((pos1 + pos2) / 2, pos2, Vector3.UP)

func _process(delta):
	alpha -= delta * 5
	alpha = clamp(alpha, 0, 1)
	material_override.albedo_color.a = alpha

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
