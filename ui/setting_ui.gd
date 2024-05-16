extends Control
class_name SettingUI

@onready var tab_container: TabContainer = $TabContainer

@onready var mouse_sen_slider: HSlider = $TabContainer/Control/MouseSens/MouseSenSlider

var pause_ui: PauseUI

func _ready() -> void:
	visible = false
	pause_ui = get_parent()
	mouse_sen_slider.value = GameManager.mouse_sensitivity

func open_menu():
	visible = true

func close_menu():
	visible = false

func _on_control_option_pressed() -> void:
	tab_container.current_tab = 0

func _on_audio_option_pressed() -> void:
	tab_container.current_tab = 1

func _on_graphic_option_pressed() -> void:
	tab_container.current_tab = 2

func _on_back_button_pressed() -> void:
	close_menu()
	pause_ui.return_to_pause_menu()

func _on_mouse_sen_slider_value_changed(value: float) -> void:
	GameManager.mouse_sensitivity = value
