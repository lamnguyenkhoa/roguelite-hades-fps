extends Control
class_name SettingUI

@onready var tab_container: TabContainer = $TabContainer

@onready var mouse_sen_slider: HSlider = $TabContainer/Control/VBoxContainer/MouseSens/MouseSenSlider
@onready var mouse_sen_value: Label = $TabContainer/Control/VBoxContainer/MouseSens/Value
@onready var fov_slider: HSlider = $TabContainer/Graphic/VBoxContainer/FOV/FOVSlider
@onready var fov_value: Label = $TabContainer/Graphic/VBoxContainer/FOV/Value
@onready var camera_tilt_toggle: CheckButton = $TabContainer/Graphic/VBoxContainer/CameraTilt/CameraTiltToggle
@onready var fps_limit_option_button: OptionButton = $TabContainer/Graphic/VBoxContainer/FPSLimit/FPSLimitOptionButton
@onready var vsync_option_button: OptionButton = $TabContainer/Graphic/VBoxContainer/Vsync/VsyncOptionButton

@onready var master_slider: HSlider = $TabContainer/Audio/VBoxContainer/Master/MasterSlider
@onready var master_value: Label = $TabContainer/Audio/VBoxContainer/Master/Value
@onready var bgm_slider: HSlider = $TabContainer/Audio/VBoxContainer/BGM/BGMSlider
@onready var bgm_value: Label = $TabContainer/Audio/VBoxContainer/BGM/Value
@onready var sfx_slider: HSlider = $TabContainer/Audio/VBoxContainer/SFX/SFXSlider
@onready var sfx_value: Label = $TabContainer/Audio/VBoxContainer/SFX/Value
@onready var ui_slider: HSlider = $TabContainer/Audio/VBoxContainer/UI/UISlider
@onready var ui_value: Label = $TabContainer/Audio/VBoxContainer/UI/Value

var pause_ui: PauseUI

func _ready() -> void:
	visible = false
	pause_ui = get_parent()
	mouse_sen_slider.value = GameManager.mouse_sensitivity
	mouse_sen_value.text = "{0}".format([GameManager.mouse_sensitivity])
	fov_slider.value = GameManager.camera_fov
	fov_value.text = "{0}".format([GameManager.camera_fov])
	camera_tilt_toggle.set_pressed_no_signal(GameManager.camera_tilt)
	Engine.max_fps = EnumAutoload.FPS_LIMIT_ARRAY[GameManager.fps_limit_index]
	fps_limit_option_button.selected = GameManager.fps_limit_index
	DisplayServer.window_set_vsync_mode(GameManager.vsync_option_index)
	vsync_option_button.selected = GameManager.vsync_option_index
	SoundManager.set_master_volume(GameManager.master_audio / 100.0)
	SoundManager.set_music_volume(GameManager.bgm_audio / 100.0)
	SoundManager.set_sound_volume(GameManager.sfx_audio / 100.0)
	SoundManager.set_ui_sound_volume(GameManager.ui_audio / 100.0)
	master_slider.value = GameManager.master_audio
	master_value.text = "{0}".format([GameManager.master_audio])
	bgm_slider.value = GameManager.bgm_audio
	bgm_value.text = "{0}".format([GameManager.bgm_audio])
	sfx_slider.value = GameManager.sfx_audio
	sfx_value.text = "{0}".format([GameManager.sfx_audio])
	ui_slider.value = GameManager.ui_audio
	ui_value.text = "{0}".format([GameManager.ui_audio])

func open_menu():
	visible = true

func close_menu():
	visible = false

func _on_control_option_pressed() -> void:
	tab_container.current_tab = 0
	SoundManager.play_button_click_sfx()

func _on_graphic_option_pressed() -> void:
	tab_container.current_tab = 1
	SoundManager.play_button_click_sfx()
	
func _on_audio_option_pressed() -> void:
	tab_container.current_tab = 2
	SoundManager.play_button_click_sfx()

func _on_back_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	close_menu()
	pause_ui.return_to_pause_menu()

func _on_mouse_sen_slider_value_changed(value: float) -> void:
	GameManager.mouse_sensitivity = value
	mouse_sen_value.text = "{0}".format([value])

func _on_fov_slider_value_changed(value: float) -> void:
	GameManager.camera_fov = value
	fov_value.text = "{0}".format([value])

func _on_camera_tilt_toggle_toggled(toggled_on: bool) -> void:
	SoundManager.play_button_click_sfx()
	GameManager.camera_tilt = toggled_on

func _on_fps_limit_option_button_item_selected(index: int) -> void:
	SoundManager.play_button_click_sfx()
	Engine.max_fps = EnumAutoload.FPS_LIMIT_ARRAY[index]
	GameManager.fps_limit_index = index

func _on_vsync_option_button_item_selected(index: int) -> void:
	SoundManager.play_button_click_sfx()
	DisplayServer.window_set_vsync_mode(index)
	GameManager.vsync_option_index = index

func _on_master_slider_value_changed(value: float) -> void:
	SoundManager.set_master_volume(value / 100.0)
	master_value.text = "{0}".format([value])
	GameManager.master_audio = value

func _on_ui_slider_value_changed(value: float) -> void:
	SoundManager.set_ui_sound_volume(value / 100.0)
	ui_value.text = "{0}".format([value])
	GameManager.ui_audio = value

func _on_sfx_slider_value_changed(value: float) -> void:
	SoundManager.set_sound_volume(value / 100.0)
	sfx_value.text = "{0}".format([value])
	GameManager.sfx_audio = value

func _on_bgm_slider_value_changed(value: float) -> void:
	SoundManager.set_music_volume(value / 100.0)
	bgm_value.text = "{0}".format([value])
	GameManager.bgm_audio = value

func _on_audio_option_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_graphic_option_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_control_option_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_back_button_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_ui_slider_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_sfx_slider_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_bgm_slider_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_master_slider_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_vsync_option_button_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_vsync_option_button_item_focused(_index: int) -> void:
	SoundManager.play_button_hover_sfx()

func _on_fps_limit_option_button_item_focused(_index: int) -> void:
	SoundManager.play_button_hover_sfx()

func _on_fps_limit_option_button_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_camera_tilt_toggle_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_fov_slider_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()

func _on_mouse_sen_slider_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()
