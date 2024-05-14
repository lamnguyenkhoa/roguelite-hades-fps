extends Node3D
class_name Gun

@export var gun_resource: GunResource
@export var bullet_trail: PackedScene

@onready var barrel: Marker3D = $Barrel
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var firerate_timer: Timer = $FireRateTimer

func play_primary_shoot_animation():
    anim_player.stop()
    anim_player.play("primary_shoot")

func try_shoot() -> bool:
    if firerate_timer.is_stopped():
        firerate_timer.start(1.0 / gun_resource.firerate)
        return true
    return false