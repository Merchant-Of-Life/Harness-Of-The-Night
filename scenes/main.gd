extends Node2D

@onready var ground_layer = $GroundLayer
@onready var props_layer = $PropsLayer
@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var game_timer = $GameTimer

var bat_scene = preload("res://scenes/bat.tscn")

var generate_radius = 24
var cleanup_radius = 32
var safe_spawn_radius = 8
var min_obstacle_spacing = 8

var last_player_cell = Vector2i(999999, 999999)
var generated_cells = {}
var placed_obstacles = []

var elapsed_seconds = 0
var remaining_seconds = 600
var max_enemies = 100
var has_survived = false

var GRASS_SOURCE_ID = 0
var STONE_SOURCE_ID = 1
var PROPS_SOURCE_ID = 2
var PLANT_SOURCE_ID = 3

var grass_tiles = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(4, 0),
	Vector2i(5, 0),
	Vector2i(4, 1)
]

var cobble_tiles = [
	Vector2i(0, 4),
	Vector2i(1, 4),
	Vector2i(2, 4)
]

var stone_tiles = [
	Vector2i(1, 1),
	Vector2i(4, 1)
]

var tree_tiles = [
	Vector2i(0, 0),
	Vector2i(5, 0),
	Vector2i(10, 0)
]

var prop_tiles = [
	Vector2i(7, 0),
	Vector2i(7, 2),
	Vector2i(7, 5),
	Vector2i(7, 7),
	Vector2i(7, 9),
	Vector2i(9, 5),
	Vector2i(11, 5),
	Vector2i(13, 6)
]

func _ready():
	ground_layer.clear()
	props_layer.clear()
	setup_game_mode()
	update_infinite_map()
	
func _process(delta):
	if player != null and not player.is_dead:
		update_infinite_map()
		
func setup_game_mode():
	if GameData.game_mode == "quick":
		remaining_seconds = 600
	elif GameData.game_mode == "standard":
		remaining_seconds = 1200
	else:
		remaining_seconds = 0
	print("started Mode: ", GameData.game_mode)
	
func update_infinite_map():
	var player_cell = ground_layer.local_to_map(player.global_position)
	if player_cell == last_player_cell:
		return
	last_player_cell = player_cell
	
	for offset_x in range(-generate_radius, generate_radius + 1):
		for offset_y in range(-generate_radius, generate_radius + 1):
			var cell_pos = Vector2i(player_cell.x + offset_x, player_cell.y + offset_y)
			if generated_cells.has(cell_pos):
				continue
				
			generated_cells[cell_pos] = true
			
			var ground_roll = randf()
			if ground_roll < 0.08:
				ground_layer.set_cell(cell_pos, STONE_SOURCE_ID, stone_tiles.pick_random())
			elif ground_roll < 0.18:
				ground_layer.set_cell(cell_pos, GRASS_SOURCE_ID, cobble_tiles.pick_random())
			else:
				ground_layer.set_cell(cell_pos, GRASS_SOURCE_ID, grass_tiles.pick_random())
				
				if Vector2(cell_pos).length() < safe_spawn_radius:
					continue
				var obstacle_roll = randf()
				if obstacle_roll < 0.035 and is_space_clear(cell_pos):
					if obstacle_roll < 0.015:
						props_layer.set_cell(cell_pos, PLANT_SOURCE_ID, tree_tiles.pick_random())
					else:
						props_layer.set_cell(cell_pos,PROPS_SOURCE_ID, prop_tiles.pick_random())
					placed_obstacles.append(cell_pos)
						
	var cells_to_erase = []
	for  cell_pos in generated_cells.keys():
		if abs(cell_pos.x - player_cell.x) > cleanup_radius or abs(cell_pos.y - player_cell.y) > cleanup_radius:
			ground_layer.erase_cell(cell_pos)
			props_layer.erase_cell(cell_pos)
			cells_to_erase.append(cell_pos)
			
	for cell_pos in cells_to_erase:
		generated_cells.erase(cell_pos)
		placed_obstacles.erase(cell_pos)
		
		
func is_space_clear(pos):
	for other_pos in placed_obstacles:
		if Vector2(pos).distance_to(Vector2(other_pos)) < min_obstacle_spacing:
			return false
	return true
	
func _on_spawn_timer_timeout():
	if has_survived or player == null or player.is_dead:
		return
	var active_enemies = get_tree().get_nodes_in_group("enemies")
	if active_enemies.size() >= max_enemies:
		return
	var bats_to_spawn = 2
	if elapsed_seconds >=60:
		bats_to_spawn = 3
	if elapsed_seconds >= 180:
		bats_to_spawn = 4

	for i in range(bats_to_spawn):
		var bat = bat_scene.instantiate()
	
		if elapsed_seconds >= 240:
			bat.max_hp = 2
			bat.speed = 225
			
		var random_angle = randf() * TAU
		var spawn_distance = randf_range(620, 750)
		var spawn_offset = Vector2.from_angle(random_angle) * spawn_distance
		bat.global_position = player.global_position + spawn_offset
		
		add_child(bat)
		
	
func _on_game_timer_timeout():
	if has_survived or player == null or player.is_dead:
		return
		
	elapsed_seconds += 1
	
	if elapsed_seconds >= 60 and elapsed_seconds % 30 == 0:
		spawn_timer.wait_time -= 0.20
		if spawn_timer.wait_time < 0.25:
			spawn_timer.wait_time = 0.25
		print("Spawn Interval Decresed to: ", spawn_timer.wait_time)
		
	if GameData.game_mode == "quick" or GameData.game_mode == "standard":
		remaining_seconds -= 1
		if remaining_seconds <= 0:
			win_run()
			
func win_run():
	has_survived = true
	spawn_timer.stop()
	game_timer.stop()
	
	var active_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in active_enemies:
		enemy.queue_free()
		
	print("You Survived the night")
