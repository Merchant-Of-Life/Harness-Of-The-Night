extends Control

@onready var title_logo = $TitleLogo
@onready var main_buttons = $MainButtons
@onready var mode_buttons = $ModeButtons

func _ready():
	main_buttons.visible = true
	mode_buttons.visible = false
	title_logo.play("scatter")

func _on_title_logo_animation_finished():
	if title_logo.animation == "scatter":
		title_logo.play("wind")
		
func _on_play_button_pressed():
	main_buttons.visible = false
	mode_buttons.visible = true

func _on_back_button_pressed():
	mode_buttons.visible = false
	main_buttons.visible = true
	
func _on_quit_button_pressed():
	get_tree().quit()
	
func _on_quick_button_pressed():
	GameData.game_mode = "quick"
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_standard_button_pressed():
	GameData.game_mode = "standard"
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_endless_button_pressed():
	GameData.game_mode = "endless"
	get_tree().change_scene_to_file("res://scenes/main.tscn")
