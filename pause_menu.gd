extends CanvasLayer

var main = null
var player = null

func _ready():
	visible = false
	main = get_parent()
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if main != null and main.has_survived:
			return
		if player != null and player.is_dead:
			return
		toggle_pause()
		
func toggle_pause():
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused

func _on_resume_button_pressed():
	get_tree().paused = false
	visible = false
	
func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
