extends CanvasLayer

var player: CharacterBody2D = null
var current_choices: Array[Dictionary] = []

@onready var card_buttons: Array[Button] = [
	$CenterContainer/MainVBox/CardsHBox/Card1,
	$CenterContainer/MainVBox/CardsHBox/Card2,
	$CenterContainer/MainVBox/CardsHBox/Card3
]
@onready var delay_timer: Timer = $InputDelayTimer

func _ready() -> void:
	visible = false
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.leveled_up.connect(open_level_up)
	for i in range(card_buttons.size()):
		card_buttons[i].pressed.connect(_on_card_pressed.bind(i))
	delay_timer.timeout.connect(_on_delay_timer_timeout)
	
func open_level_up() -> void:
	current_choices = SkillData.get_random_skills(3)
	for i in range(3):
		var skill := current_choices[i]
		var button := card_buttons[i]
		button.get_node("VBoxContainer/BranchLabel").text = skill["branch"]
		button.get_node("VBoxContainer/TitleLabel").text = skill["name"]
		button.get_node("VBoxContainer/DescLabel").text = skill["desc"]
		button.disabled = true
	visible = true
	get_tree().paused = true
	delay_timer.start()
	
func _on_delay_timer_timeout() -> void:
	for button in card_buttons:
		button.disabled = false
		
func _on_card_pressed(card_index: int) -> void:
	if not visible:
		return
	if player != null:
		player.apply_skill(current_choices[card_index]["id"])
	visible = false
	get_tree().paused = false
	if player != null:
		player.check_pending_level_ups()
