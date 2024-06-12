extends Control
class_name SettingUI

@onready var tab_container: TabContainer = $TabContainer

@onready var mouse_sen_slider: HSlider = $TabContainer/Control/VBoxContainer/MouseSens/MouseSenSlider
@onready var mouse_sen_value: Label = $TabContainer/Control/VBoxContainer/MouseSens/Value
@onready var fov_slider: HSlider = $TabContainer/Graphic/VBoxContainer/FOV/FOVSlider
@onready var fov_value: Label = $TabContainer/Graphic/VBoxContainer/FOV/Value
@onready var camera_tilt_toggle: CheckButton = $TabContainer/Graphic/VBoxContainer/CameraTilt/CameraTiltToggle
@onready var fps_limit_option_button: OptionButton = $TabContainer/Graphic/VBoxContainer/FPSLimit/FPSLimitOptionButton

var pause_ui: PauseUI

func _ready() -> void:
	visible = false
	pause_ui = get_parent()
	mouse_sen_slider.value = GameManager.mouse_sensitivity
	mouse_sen_value.text = "{0}".format([GameManager.mouse_sensitivity])
	fov_slider.value = GameManager.camera_fov
	fov_value.text = "{0}".format([GameManager.camera_fov])
	camera_tilt_toggle.button_pressed = GameManager.camera_tilt
	Engine.max_fps = EnumAutoload.FPS_LIMIT_ARRAY[GameManager.fps_limit_index]
	fps_limit_option_button.selected = GameManager.fps_limit_index

func open_menu():
	visible = true

func close_menu():
	visible = false

func _on_control_option_pressed() -> void:
	tab_container.current_tab = 0

func _on_graphic_option_pressed() -> void:
	tab_container.current_tab = 1
	
func _on_audio_option_pressed() -> void:
	tab_container.current_tab = 2

func _on_back_button_pressed() -> void:
	close_menu()
	pause_ui.return_to_pause_menu()

func _on_mouse_sen_slider_value_changed(value: float) -> void:
	GameManager.mouse_sensitivity = value
	mouse_sen_value.text = "{0}".format([value])

func _on_fov_slider_value_changed(value: float) -> void:
	GameManager.camera_fov = value
	fov_value.text = "{0}".format([value])

func _on_camera_tilt_toggle_toggled(toggled_on: bool) -> void:
	GameManager.camera_tilt = toggled_on

func _on_fps_limit_option_button_item_selected(index: int) -> void:
	Engine.max_fps = EnumAutoload.FPS_LIMIT_ARRAY[index]
	GameManager.fps_limit_index = index
