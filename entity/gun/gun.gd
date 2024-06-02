extends Node3D
class_name Gun

@export var gun_resource: GunResource
@export var bullet_trail: PackedScene

@onready var barrel: Marker3D = $Barrel
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var firerate_timer: Timer = $FireRateTimer

func play_primary_attack_anim():
    anim_player.stop()
    anim_player.play("primary_attack")

func play_secondary_attack_anim():
    anim_player.stop()
    anim_player.play("secondary_attack")

func try_primary_attack() -> bool:
    if firerate_timer.is_stopped():
        firerate_timer.start(1.0 / gun_resource.firerate)
        return true
    return false

func try_secondary_attack() -> bool:
    if firerate_timer.is_stopped():
        firerate_timer.start(1.0 / gun_resource.firerate)
        return true
    return false

func set_animation_idle():
    anim_player.play("idle")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
    anim_player.play("idle")

func check_if_animation_playing(anim_name: String = ""):
    if anim_name == "":
        return anim_player.is_playing()
    else:
        return anim_player.is_playing() and anim_player.current_animation == anim_name
