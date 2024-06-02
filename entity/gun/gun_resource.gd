extends Resource
class_name GunResource

@export var name: String
@export_multiline var description: String

# Stat
@export var damage: float
@export var firerate: float # Bullet per second
@export var projectile_speed: float # How fast bullet travel
@export var is_hitscan: bool # If this ticked, ignore bullet_speed
@export var camera_shake_trauma: float = 0.2
@export var secondary_type: EnumAutoload.GunSecondaryAttackType
@export var primary_bounce_time = 0
@export var primary_pierce = false
@export var secondary_bounce_time = 0
@export var secondary_pierce = false