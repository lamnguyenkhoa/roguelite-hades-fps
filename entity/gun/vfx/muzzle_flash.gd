extends AnimatedSprite3D
class_name MuzzleFlash

@onready var light: OmniLight3D = $MuzzleFlashLight
@onready var timer: Timer = $MuzzleFlashTimer

func _ready() -> void:
    light.visible = false

func flash():
    light.visible = true
    play("default")
    timer.start()

func _on_muzzle_flash_timer_timeout() -> void:
    light.visible = false
