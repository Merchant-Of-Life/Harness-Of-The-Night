extends CanvasLayer

const ALL_SKILLS: Array[Dictionary] = [
	{
		"id": "wick_and_flint",
		"name": "Wick and Flint",
		"branch": "Pyromancy",
		"desc": "+1 Power\n(More Damage per fireball)"
	},
	{
		"id": "murmur",
		"name": "Murmur",
		"branch": "Grimoire Mastery",
		"desc": "+20% Cast Speed\n(Faster firing)"
	},
	{
		"id": "quire",
		"name": "Quire",
		"branch": "Deep Tome",
		"desc": "+2 Max Charges\n& refills your book"
	},
	{
		"id": "guideness_of_light",
		"name": "Guideness Of Light",
		"branch": "Lantern & Soul",
		"desc": "+35% Light Radius\n(See farther in the darkness)"
	},
	{
		"id": "swift",
		"name": "Swift",
		"branch": "Shadow Step",
		"desc": "+30 Movement Speed\n(Faster walking)"
	},
	{
		"id": "grit_of_blood",
		"name": "Grit Of Blood",
		"branch": "Blood & Vitality",
		"desc": "+1 Max HP &\nheals 1 HP immediately"
	},
	{
		"id": "krakens_gamble",
		"name": "Kraken's Gamble",
		"branch": "Abyssal Pact",
		"desc": "60% chance for 1.50x dmg,\n40% chance for 0.90x dmg"
	}
]

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
	var pool := ALL_SKILLS.duplicate()
	pool.shuffle()
	current_choices = [pool[0], pool[1], pool[2]]
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
	apply_upgrade(current_choices[card_index]["id"])
	visible = false
	get_tree().paused = false
	if player != null:
		player.check_pending_level_ups()
		
func apply_upgrade(skill_id: String) -> void:
	if player == null:
		return
		
	match skill_id:
		"wick_and_flint":
			player.power += 1
		"murmur":
			var attack_timer: Timer = player.get_node("AttackCooldownTimer")
			attack_timer.wait_time = max(0.08, attack_timer.wait_time * 0.80)
		"quire":
			player.refill_and_increase_max_charges(2)
		"guideness_of_light":
			player.get_node("PointLight2D").texture_scale += 0.35
		"swift":
			player.speed += 30.0
		"grit_of_blood":
			player.heal_and_increase_max_hp(1)
		"krakens_gamble":
			player.krakens_stack += 1
