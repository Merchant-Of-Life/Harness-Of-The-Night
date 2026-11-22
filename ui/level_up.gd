extends CanvasLayer

@onready var card_buttons = [
	$CenterContainer/MainVBox/CardsHBox/Card1,
	$CenterContainer/MainVBox/CardsHBox/Card2,
	$CenterContainer/MainVBox/CardsHBox/Card3
]
@onready var delay_timer = $InputDelayTimer

var player = null
var current_choices = []

var all_skills = [
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
		"desc": "+20 Cast Speed\n(Faster firing)"
	},
	{
		"id": "quire",
		"name": "Quire",
		"branch": "Deep Tome",
		"desc": "+2 Max Charges\n& refills your book"
	},
	{
		"id": "guideness_of_light",
		"name": "Guidenes Of Light",
		"branch": "Lantern & Soul",
		"desc": "+35% Light Radius\n(See farther in the darkness)"
	},
	{
		"id": "swift",
		"name": "Swift",
		"branch": "Shadow Step",
		"desc": "+30 Movement Speed\n(faster walking)"
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

func _ready():
	visible = false
	player = get_tree().get_first_node_in_group("player")
	
	card_buttons[0].pressed.connect(_on_card_pressed.bind(0))
	card_buttons[1].pressed.connect(_on_card_pressed.bind(1))
	card_buttons[2].pressed.connect(_on_card_pressed.bind(2))
	delay_timer.timeout.connect(_on_delay_timer_timeout)
	
func open_level_up():
	var pool = all_skills.duplicate()
	pool.shuffle()
	current_choices = [pool[0], pool[1], pool[2]]
	
	for i in range(3):
		var skill = current_choices[i]
		var button = card_buttons[i]
		button.get_node("VBoxContainer/BranchLabel").text = skill["branch"]
		button.get_node("VBoxContainer/TitleLabel").text = skill["name"]
		button.get_node("VBoxContainer/DescLabel").text = skill["desc"]
		button.disabled = true
		
	visible = true
	get_tree().paused = true
	delay_timer.start()
		
func _on_delay_timer_timeout():
	for button in card_buttons:
		button.disabled = false
	
func _on_card_pressed(card_index):
	var chosen_skill = current_choices[card_index]
	apply_upgrade(chosen_skill["id"])
	
	visible = false
	get_tree().paused = false
	
	if player != null and player.has_method("check_pending_level_up"):
		player.check_pending_level_ups()
		
func apply_upgrade(skill_id):
	if player == null:
		return
	if skill_id == "wick_and_flint":
		player.power += 1
	elif skill_id == "murmur":
		var attack_timer = player.get_node("AttackCooldownTimer")
		attack_timer.wait_time = max(0.08, attack_timer.wait_time * 0.80)
	elif skill_id == "quire":
		player.max_charges += 2
		player.currect_charges = player.max_charges
		player.is_charging = false
		player.get_node("RechargeTimer").stop()
		player.book_sprite.play("open")
	elif skill_id == "guideness_of_light":
		player.get_node("PointLight2D").texture_scale += 0.35
	elif skill_id == "swift":
		player.speed += 30
	elif skill_id == "grit_of_blood":
		player.max_hp += 1
		player.hp += 1
	elif skill_id == "krakens_gamble":
		player.krakens_stack += 1
	
	
	
	
	
	
	
	
