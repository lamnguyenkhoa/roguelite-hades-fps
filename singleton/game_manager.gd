extends Node2D

var pause_ui: PauseUI
var player: Player

# Setting
var mouse_sensitivity: float = 50.0
var camera_fov: float = 90: # From 60 to 120
    set(value):
        if value != camera_fov:
            player.player_camera.set_fov(value)
        camera_fov = value
var camera_tilt = true