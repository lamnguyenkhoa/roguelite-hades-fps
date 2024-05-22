extends Resource
class_name GunResource

@export var name: String
@export_multiline var description: String

# Stat
@export var damage: float
@export var firerate: float # Bullet per second
@export var projectile_speed: float # How fast bullet travel
@export var is_hitscan: bool # If this ticked, ignore bullet_speed
@export var secondary_not_attack: bool # In case secondary is some sort of buff or utility
@export var camera_shake_trauma: float = 0.2
