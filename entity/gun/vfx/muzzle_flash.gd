extends AnimatedSprite3D
class_name MuzzleFlash

@onready var light: OmniLight3D = $MuzzleFlashLight
@onready var timer: Timer = $MuzzleFlashTimer

func _ready() -> void:
    light.visible = false

func flash():
    light.visible = true
    play("default")
    var rotate_amount = randi_range(5, 45)
    rotate_z(rotate_amount)
    timer.start()

func _on_muzzle_flash_timer_timeout() -> void:
    light.visible = false
