extends Control
class_name SettingUI

@onready var tab_container: TabContainer = $TabContainer

var pause_ui: PauseUI

func _ready() -> void:
	visible = false
	pause_ui = get_parent()

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