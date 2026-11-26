extends Node2D

const BAT_SCENE := preload("res://scenes/bat.tscn")
const REAPER_SCENE := preload("res://scenes/reaper.tscn")

const GRASS_SOURCE_ID := 0
const STONE_SOURCE_ID := 1
const PROPS_SOURCE_ID := 2
const PLANT_SOURCE_ID := 3

const GRASS_TILES: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(4, 0),
	Vector2i(5, 0), Vector2i(4, 1)
]
const COBBLE_TILES: Array[Vector2i] = [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4)]
const STONE_TILES: Array[Vector2i] = [Vector2i(1, 1), Vector2i(4, 1)]
const TREE_TILES: Array[Vector2i] = [Vector2i(0, 0), Vector2i(5, 0), Vector2i(10, 0)]
const PROP_TILES: Array[Vector2i] = [
	Vector2i(7, 0), Vector2i(7, 2), Vector2i(7, 5), Vector2i(7, 7),
	Vector2i(7, 9), Vector2i(9, 5), Vector2i(11, 5), Vector2i(13, 6)
]

@export var generate_radius: int = 24
@export var cleanup_radius: int = 32
@export var safe_spawn_radius: int = 8
@export var min_obstacle_spacing: int = 8
@export var max_enemies: int = 100

var last_player_cell := Vector2i(999999, 999999)
var generated_cells: Dictionary = {}
var placed_obstacles: Array[Vector2i] = []

var elapsed_seconds: int = 0
var remaining_seconds: int = 600
var reaper_wave_counter: int = 0
var has_survived: bool = false

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var props_layer: TileMapLayer = $PropsLayer
@onready var player: CharacterBody2D = $Player
@onready var spawn_timer: Timer = $SpawnTimer
@onready var game_timer: Timer = $GameTimer
@onready var game_over_screen: CanvasLayer = $GameOver
@onready var victory_screen: CanvasLayer = $Victory

func _ready() -> void:
	ground_layer.clear()
	props_layer.clear()
	remaining_seconds = GameData.get_target_duration()
	update_infinite_map()
	
func _process(_delta: float) -> void:
	if player != null and not player.is_dead:
		update_infinite_map()
		
func update_infinite_map() -> void:
	var player_cell := ground_layer.local_to_map(player.global_position)
	if player_cell == last_player_cell:
		return
	last_player_cell = player_cell
	for offset_x in range(-generate_radius, generate_radius + 1):
		for offset_y in range(-generate_radius, generate_radius + 1):
			var cell_pos := Vector2i(player_cell.x + offset_x, player_cell.y + offset_y)
			if generated_cells.has(cell_pos):
				continue
			generated_cells[cell_pos] = true
			generate_cell(cell_pos)
	cleanup_distant_cells(player_cell)
	
func generate_cell(cell_pos: Vector2i) -> void:
	var ground_roll := randf()
	if ground_roll < 0.08:
		ground_layer.set_cell(cell_pos, STONE_SOURCE_ID, STONE_TILES.pick_random())
	elif ground_roll < 0.18:
		ground_layer.set_cell(cell_pos, GRASS_SOURCE_ID, COBBLE_TILES.pick_random())
	else:
		ground_layer.set_cell(cell_pos, GRASS_SOURCE_ID, GRASS_TILES.pick_random())
		
		if Vector2(cell_pos).length() < safe_spawn_radius:
			return
			
		var obstacle_roll := randf()
		if obstacle_roll < 0.035 and is_space_clear(cell_pos):
			if obstacle_roll < 0.015:
				props_layer.set_cell(cell_pos, PLANT_SOURCE_ID, TREE_TILES.pick_random())
			else:
				props_layer.set_cell(cell_pos, PROPS_SOURCE_ID, PROP_TILES.pick_random())
			placed_obstacles.append(cell_pos)
			
func cleanup_distant_cells(player_cell: Vector2i) -> void:
	var cells_to_erase: Array[Vector2i] = []
	for cell_pos: Vector2i in generated_cells.keys():
		if abs(cell_pos.x - player_cell.x) > cleanup_radius or abs(cell_pos.y - player_cell.y) > cleanup_radius:
			ground_layer.erase_cell(cell_pos)
			props_layer.erase_cell(cell_pos)
			cells_to_erase.append(cell_pos)
	for cell_pos in cells_to_erase:
		generated_cells.erase(cell_pos)
		placed_obstacles.erase(cell_pos)
		
func is_space_clear(pos: Vector2i) -> bool:
	for other_pos in placed_obstacles:
		if Vector2(pos).distance_to(Vector2(other_pos)) < min_obstacle_spacing:
			return false
	return true
	
func get_offscreen_spawn_position() -> Vector2:
	var random_angle := randf() * TAU
	var spawn_distance := randf_range(620.0, 750.0)
	return player.global_position + Vector2.from_angle(random_angle) * spawn_distance
	
func _on_spawn_timer_timeout() -> void:
	if has_survived or player == null or player.is_dead:
		return
	if get_tree().get_node_count_in_group("enemies") >= max_enemies:
		return
	spawn_bat_wave()
	if elapsed_seconds >= 120:
		spawn_reaper_wave()
		
func spawn_bat_wave() -> void:
	var bats_to_spawn := 1
	if elapsed_seconds >= 180:
		bats_to_spawn = 3
	elif elapsed_seconds >= 60:
		bats_to_spawn = 2
	for i in range(bats_to_spawn):
		var bat := BAT_SCENE.instantiate()
		if elapsed_seconds >= 240:
			bat.max_hp = 2.0
			bat.speed = 200.0
			bat.xp_reward = 1.5
		bat.global_position = get_offscreen_spawn_position()
		add_child(bat)
		
func spawn_reaper_wave() -> void:
	reaper_wave_counter += 1
	if reaper_wave_counter < 4:
		return
	reaper_wave_counter = 0
	
	var reapers_to_spawn := 2 if elapsed_seconds >= 300 else 1
	for i in range(reapers_to_spawn):
		var reaper := REAPER_SCENE.instantiate()
		if elapsed_seconds >= 360:
			reaper.max_hp = 5.0
			reaper.xp_reward = 4.0
		elif elapsed_seconds >= 240:
			reaper.max_hp = 4.0
			reaper.xp_reward = 3.0
		elif elapsed_seconds >= 180:
			reaper.max_hp = 3.0
			reaper.xp_reward = 2.5
		reaper.global_position = get_offscreen_spawn_position()
		add_child(reaper)
		
func _on_game_timer_timeout() -> void:
	if has_survived or player == null or player.is_dead:
		return
	elapsed_seconds += 1
	if elapsed_seconds >= 60 and elapsed_seconds % 45 == 0:
		spawn_timer.wait_time = max(0.65, spawn_timer.wait_time - 0.10)
	if GameData.is_timed_mode():
		remaining_seconds -= 1
		if remaining_seconds <= 0:
			win_run()
			
func win_run() -> void:
	has_survived = true
	spawn_timer.stop()
	game_timer.stop()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
		
	var current_level: int = player.level if player != null else 1
	victory_screen.show_screen(elapsed_seconds, GameData.game_mode, current_level)
	
func show_game_over() -> void:
	spawn_timer.stop()
	game_timer.stop()
	
	var current_level: int = player.level if player != null else 1
	game_over_screen.show_screen(elapsed_seconds, GameData.game_mode, current_level)
