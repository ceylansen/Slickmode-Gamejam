extends Node2D

@export var tiles: TileMapLayer
@export var slide_on_ice := false
@export var move_time := 0.1

var tile_pos: Vector2i
var is_moving := false

func _ready():
	tile_pos = tiles.local_to_map(global_position)
	global_position = tiles.map_to_local(tile_pos)
	add_to_group("rocks")


func can_move(dir: Vector2i) -> bool:
	var next_tile := tile_pos + dir
	var surface := get_tile_type(next_tile)
	for rock in get_tree().get_nodes_in_group("rocks"):
		if rock.tile_pos == next_tile:
			surface = "rock"
	return surface != "rock" and surface != "void" and surface != "wall"


func push(dir: Vector2i):
	if is_moving:
		return false

	if not can_move(dir):
		return false

	move_to_tile(tile_pos + dir)

	if slide_on_ice and get_tile_type(tile_pos) == "ice":
		slide(dir)

	return true

func slide(dir: Vector2i):
	await get_tree().create_timer(move_time).timeout

	var next_tile := tile_pos + dir
	var surface := get_tile_type(next_tile)

	if surface == "ice":
		if not can_move(dir):
			return
		move_to_tile(next_tile)
		slide(dir)



func move_to_tile(tile: Vector2i):
	is_moving = true
	tile_pos = tile

	var target_pos := tiles.map_to_local(tile)
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_pos, move_time)
	tween.tween_callback(func():
		is_moving = false
	)

func get_tile_type(tile: Vector2i) -> String:
	var tile_data := tiles.get_cell_tile_data(tile)
	if tile_data == null:
		return "void"
	return tile_data.get_custom_data("type")
