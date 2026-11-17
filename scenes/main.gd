extends Node2D

@onready var ground_layer = $GroundLayer
@onready var props_layer = $PropsLayer

var arena_radius = 60
var safe_spawn_radius = 8

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
	Vector2i(9, 0)
]

var prop_tiles = [
	Vector2i(7, 0),
	Vector2i(7, 2),
	Vector2i(7, 5),
	Vector2i(7, 7),
	Vector2i(7, 9),
	Vector2i(11, 5),
	Vector2i(13, 6)
]

func _ready():
	generate_arena()
	
func generate_arena():
	ground_layer.clear()
	props_layer.clear()
	
	for tile_x in range(-arena_radius, arena_radius + 1):
		for tile_y in range (-arena_radius, arena_radius +1):
			var cell_pos = Vector2i(tile_x, tile_y)
			
			var ground_roll = randf()
			if ground_roll < 0.08:
				ground_layer.set_cell(cell_pos, STONE_SOURCE_ID, stone_tiles.pick_random())
			elif ground_roll <0.18:
				ground_layer.set_cell(cell_pos, GRASS_SOURCE_ID, cobble_tiles.pick_random())
			else:
				ground_layer.set_cell(cell_pos, GRASS_SOURCE_ID, grass_tiles.pick_random())
			if abs(tile_x) == arena_radius or abs(tile_y) == arena_radius:
				props_layer.set_cell(cell_pos, PROPS_SOURCE_ID, Vector2i(11, 5))
				continue
				
			var distance_from_center = Vector2(tile_x, tile_y).length()
			if distance_from_center < safe_spawn_radius:
				continue
				
			var obstacle_roll = randf()
			if obstacle_roll <0.02:
				props_layer.set_cell(cell_pos, PLANT_SOURCE_ID, tree_tiles.pick_random())
			elif obstacle_roll <0.045:
				props_layer.set_cell(cell_pos, PROPS_SOURCE_ID, prop_tiles.pick_random())
			
