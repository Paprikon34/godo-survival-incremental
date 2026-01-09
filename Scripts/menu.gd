extends Control

@onready var settings_panel = $SettingsPanel
@onready var debug_check = $SettingsPanel/VBoxContainer/DebugCheck
@onready var cheats_check = $SettingsPanel/VBoxContainer/CheatsCheck
@onready var fps_check = $SettingsPanel/VBoxContainer/FPSCheck

func _ready():
	# Load current state
	debug_check.button_pressed = Global.debug_enabled
	cheats_check.button_pressed = Global.cheats_enabled
	fps_check.button_pressed = Global.fps_enabled

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed():
	settings_panel.visible = true

func _on_back_button_pressed():
	settings_panel.visible = false

func _on_debug_check_toggled(toggled_on):
	Global.debug_enabled = toggled_on

func _on_cheats_check_toggled(toggled_on):
	Global.cheats_enabled = toggled_on

func _on_fps_check_toggled(toggled_on):
	Global.fps_enabled = toggled_on
