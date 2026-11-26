extends Control

const MAIN_SCENE_PATH := "res://scenes/main.tscn"

@onready var title_logo: AnimatedSprite2D = $TitleLogo
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var mode_buttons: VBoxContainer = $ModeButtons

func _ready() -> void:
	main_buttons.visible = true
	mode_buttons.visible = false
	title_logo.play("scatter")
	
func start_game_with_mode(mode:String) -> void:
	GameData.game_mode = mode
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_title_logo_animation_finished() -> void:
	if title_logo.animation == "scatter":
		title_logo.play("wind")
		
func _on_play_button_pressed() -> void:
	main_buttons.visible = false
	mode_buttons.visible = true

func _on_back_button_pressed() -> void:
	mode_buttons.visible = false
	main_buttons.visible = true
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_quick_button_pressed() -> void:
	start_game_with_mode("quick")
	
func _on_standard_button_pressed() -> void:
	start_game_with_mode("standard")
	
func _on_endless_button_pressed() -> void:
	start_game_with_mode("endless")
