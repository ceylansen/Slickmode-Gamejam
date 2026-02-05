extends Node2D

@export var tiles: TileMapLayer
@export var slide_on_ice := false
@export var move_time := 0.1
@export var value := 1
var active := true



var tile_pos: Vector2i
var is_moving := false

func _ready():
	tile_pos = tiles.local_to_map(global_position)
	global_position = tiles.map_to_local(tile_pos)
	add_to_group("rocks")





func can_move(dir: Vector2i) -> bool:
	if !active:
		return false
	var next_tile := tile_pos + dir
	var surface := get_tile_type(next_tile)
	for rock in get_tree().get_nodes_in_group("rocks"):
		if rock.tile_pos == next_tile:
			surface = "rock"
	return surface != "rock" and surface != "void" and surface != "wall"


func update_sprite():
	$Sprite2D.frame = value - 1


func push(dir: Vector2i, mode: bool):
	if is_moving:
		return false

	var next_tile := tile_pos + dir
	var other = get_rock_at(next_tile)
	var finish = get_finish_at(next_tile)
	if mode:
		move_time = 0.05
	else:
		move_time = 0.1

	if other:
		move_to_tile(next_tile)
		merge_with(other)
		return true

	if finish:
		move_to_tile(next_tile)
		finish.check_finish(value)

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
	var other = get_rock_at(next_tile)
	var finish = get_finish_at(next_tile)
	if other:
		move_to_tile(next_tile)
		merge_with(other)
		return
	
	if finish:
		move_to_tile(next_tile)
		finish.check_finish(value)
		
	if surface == "ice":
		if not can_move(dir):
			return
		move_to_tile(next_tile)
		slide(dir)
	elif surface == "floor":
		move_to_tile(next_tile)

func merge_with(other):
	value = min(value + other.value, 9)
	other.merged(value)
	active = false

	hide()
	tile_pos = Vector2i(-1000, -1000)
	global_position = Vector2(-1000, -1000)
	
	update_sprite()


func merged(val):
	value = val
	update_sprite()
	

func get_rock_at(tile: Vector2i):
	for rock in get_tree().get_nodes_in_group("rocks"):
		if rock.active and rock.tile_pos == tile:
			return rock
	return null

func get_finish_at(tile: Vector2i):
	for finish in get_tree().get_nodes_in_group("finish"):
		if finish.tile_pos == tile:
			finish.check_finish(value)
	return null

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
