extends CanvasLayer

const HEART_TEXTURE := preload("res://assets/UI/heart.png")
const MINI_CARD_FONT := preload("res://assets/fonts/MiniCard.ttf")
const MINI_SERIF_FONT := preload("res://assets/fonts/MiniSerif.ttf")
const HP_PER_HEART := 10

var main: Node2D = null
var player: CharacterBody2D = null
var last_heart_count: int = 0
var last_charging_state: bool = false

@onready var hearts_container: HBoxContainer = $HeartsContainer
@onready var timer_label: Label = $TimerLabel
@onready var ammo_label: Label = $AmmoLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var level_label: Label = $XPBar/LevelLabel


func _ready() -> void:
	main = get_parent()
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
		
	player.hp_changed.connect(_on_player_hp_changed)
	player.ammo_changed.connect(_on_player_ammo_changed)
	player.xp_changed.connect(_on_player_xp_changed)
	_on_player_hp_changed(player.hp, player.max_hp)
	_on_player_ammo_changed(player.current_charges, player.max_charges, player.is_charging)
	_on_player_xp_changed(player.current_xp, player.xp_to_next_level, player.level)


func _process(_delta: float) -> void:
	if main != null:
		update_timer()


func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	var total_hearts := ceili(float(max_hp) / HP_PER_HEART)
	if total_hearts != last_heart_count:
		rebuild_hearts(total_hearts)
		
	var visible_hearts := ceili(float(current_hp) / HP_PER_HEART)
	var hearts := hearts_container.get_children()
	for i in range(hearts.size()):
		hearts[i].visible = i < visible_hearts


func rebuild_hearts(total_hearts: int) -> void:
	last_heart_count = total_hearts
	for child in hearts_container.get_children():
		hearts_container.remove_child(child)
		child.queue_free()
	for i in range(total_hearts):
		var heart := TextureRect.new()
		heart.texture = HEART_TEXTURE
		heart.custom_minimum_size = Vector2(32, 32)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart)


func _on_player_ammo_changed(current_charges: int, max_charges: int, is_charging: bool) -> void:
	if is_charging != last_charging_state:
		last_charging_state = is_charging
		var active_font := MINI_SERIF_FONT if is_charging else MINI_CARD_FONT
		ammo_label.add_theme_font_override("font", active_font)
	if is_charging:
		ammo_label.text = "Recharging..."
	else:
		ammo_label.text = "%d / %d" % [current_charges, max_charges]


func _on_player_xp_changed(current_xp: float, xp_to_next: float, level: int) -> void:
	xp_bar.max_value = xp_to_next
	xp_bar.value = current_xp
	level_label.text = "LEVEL %d" % level


func update_timer() -> void:
	var display_seconds: int = main.remaining_seconds if GameData.is_timed_mode() else main.elapsed_seconds
	@warning_ignore("integer_division")
	var minutes := display_seconds / 60
	var seconds := display_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
