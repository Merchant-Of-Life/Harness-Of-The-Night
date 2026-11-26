extends CanvasLayer

const MENU_SCENE_PATH := "res://ui/main_menu.tscn"

@onready var mode_label: Label = $CenterContainer/VBoxContainer/ModeLabel
@onready var time_label: Label = $CenterContainer/VBoxContainer/TimeLabel
@onready var level_label: Label = $CenterContainer/VBoxContainer/LevelLabel

func _ready() -> void:
	visible = false
	
func show_screen(elapsed_seconds: int, mode: String, level: int) -> void:
	var minutes := int(elapsed_seconds / 60)
	var seconds := (elapsed_seconds) % 60
	
	mode_label.text = "Mode: " + mode.capitalize()
	time_label.text = "Time Survived: %02d:%02d" % [minutes, seconds]
	level_label.text = "Level Reached: " + str(level)
	
	visible = true
	get_tree().paused = true
	
func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
