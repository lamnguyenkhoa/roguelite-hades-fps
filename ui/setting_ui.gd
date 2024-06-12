extends Control
class_name SettingUI

@onready var tab_container: TabContainer = $TabContainer

@onready var mouse_sen_slider: HSlider = $TabContainer/Control/VBoxContainer/MouseSens/MouseSenSlider
@onready var mouse_sen_value: Label = $TabContainer/Control/VBoxContainer/MouseSens/Value
@onready var fov_slider: HSlider = $TabContainer/Graphic/VBoxContainer/FOV/FOVSlider
@onready var fov_value: Label = $TabContainer/Graphic/VBoxContainer/FOV/Value

var pause_ui: PauseUI

func _ready() -> void:
	visible = false
	pause_ui = get_parent()
	mouse_sen_slider.value = GameManager.mouse_sensitivity
	mouse_sen_value.text = "{0}".format([GameManager.mouse_sensitivity])
	fov_slider.value = GameManager.camera_fov
	fov_value.text = "{0}".format([GameManager.camera_fov])

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
