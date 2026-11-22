extends CanvasLayer

@onready var mode_label = $CenterContainer/VBoxContainer/ModeLabel
@onready var time_label = $CenterContainer/VBoxContainer/TimeLabel
@onready var level_label = $CenterContainer/VBoxContainer/LevelLabel

func _ready():
	visible = false
	
func show_screen(elapsed_seconds, mode, level):
	var minutes = int(elapsed_seconds) / 60
	var seconds = int(elapsed_seconds) % 60
	
	mode_label.text = "Mode: " + mode.capitalize()
	time_label.text = "Time Survived: %02d:%02d" % [minutes, seconds]
	level_label.text = "Level Reached: " + str(level)
	
	visible = true
	get_tree().paused = true
	
func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
