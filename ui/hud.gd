extends CanvasLayer

var heart_texture = preload("res://assets/UI/heart.png")
var mini_card_font = preload("res://assets/fonts/MiniCard.ttf")
var mini_serif_font = preload("res://assets/fonts/MiniSerif.ttf")

@onready var hearts_container = $HeartsContainer
@onready var timer_label = $TimerLabel
@onready var ammo_label = $AmmoLabel
@onready var xp_bar = $XPBar
@onready var level_label = $XPBar/LevelLabel

var player = null
var main = null
var last_max_hp = 0

func _ready():
	main = get_parent()
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		setup_hearts()
		
func _process(_delta):
	if player == null or main == null:
		return
	if player.max_hp != last_max_hp:
		setup_hearts()
		
	update_hearts()
	update_timer()
	update_ammo()
	update_xp()
	
func setup_hearts():
	last_max_hp = player.max_hp
	for child in hearts_container.get_children():
		child.queue_free()
	
	for i in range(player.max_hp):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.custom_minimum_size = Vector2(32, 32)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart)
		
func update_hearts():
	var hearts = hearts_container.get_children()
	for i in range(hearts.size()):
		hearts[i].visible = i < player.hp

func update_timer():
	var display_seconds = 0
	if GameData.game_mode == "quick" or GameData.game_mode == "standard":
		display_seconds = main.remaining_seconds
	else:
		display_seconds = main.elapsed_seconds
		
	var minutes = int(display_seconds) / 60
	var seconds = int(display_seconds) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
func update_ammo():
	if player.is_charging:
		ammo_label.add_theme_font_override("font", mini_serif_font)
		ammo_label.text = "Recharging..."
	else:
		ammo_label.add_theme_font_override("font", mini_card_font)
		ammo_label.text = str(player.currect_charges) + " / " + str(player.max_charges)

func update_xp():
	xp_bar.max_value = player.xp_to_next_level
	xp_bar.value = player.current_xp
	level_label.text = "LEVEL " + str(player.level)
