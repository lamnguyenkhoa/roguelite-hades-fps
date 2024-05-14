extends Resource
class_name GunResource

@export var name: String
@export_multiline var description: String

# Stat
@export var damage: float
@export var firerate: float # Bullet per second
@export var projectile_speed: float # How fast bullet travel
@export var is_hitscan: bool # If this ticked, ignore bullet_speed
