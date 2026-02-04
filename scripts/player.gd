extends CharacterBody2D

@export var tiles: TileMapLayer
@export var move_time := 0.2
@export var floor_move_time := 0.15
@export var ice_move_time := 0.1

var curr_pos: Vector2i
var is_moving := false
var is_sliding := false
var slide_dir := Vector2i.ZERO
var input_dir := Vector2i.ZERO

var current_surface := "floor"


func _ready():
	curr_pos = tiles.local_to_map(global_position)
	global_position = tiles.map_to_local(curr_pos)

func _physics_process(_delta):
	if is_moving:
		return

	update_input_dir()

	if is_sliding:
		continue_slide()
		return

	if input_dir != Vector2i.ZERO:
		try_move(input_dir)

func update_input_dir():
	input_dir = Vector2i.ZERO

	if Input.is_action_pressed("left"):
		input_dir = Vector2i.LEFT
	elif Input.is_action_pressed("right"):
		input_dir = Vector2i.RIGHT
	elif Input.is_action_pressed("up"):
		input_dir = Vector2i.UP
	elif Input.is_action_pressed("down"):
		input_dir = Vector2i.DOWN

func try_move(dir: Vector2i):
	var next_tile := curr_pos + dir

	var rock = get_rock_at(next_tile)
	if rock:
		if rock.push(dir):
			move_to_tile(next_tile)
		return

	if is_blocked(next_tile):
		return

	move_to_tile(next_tile)

	if get_tile_type(next_tile) == "ice":
		start_slide(dir)



func start_slide(dir: Vector2i):
	is_sliding = true
	slide_dir = dir

func continue_slide():
	var next_tile := curr_pos + slide_dir

	if is_blocked(next_tile):
		stop_slide()
		return

	move_to_tile(next_tile)

	if get_tile_type(next_tile) != "ice":
		stop_slide()


func stop_slide():
	is_sliding = false
	slide_dir = Vector2i.ZERO

func move_to_tile(tile: Vector2i):
	is_moving = true
	curr_pos = tile

	current_surface = get_tile_type(tile)

	var target_pos := tiles.map_to_local(tile)

	var move_speed := floor_move_time
	if current_surface == "ice":
		move_speed = ice_move_time

	var tween := create_tween()
	tween.tween_property(self, "global_position", target_pos, move_speed)
	tween.tween_callback(func():
		is_moving = false
	)

func get_rock_at(tile: Vector2i):
	for rock in get_tree().get_nodes_in_group("rocks"):
		if rock.tile_pos == tile:
			return rock
	return null


func is_blocked(tile: Vector2i) -> bool:
	var surface := get_tile_type(tile)
	if surface == "wall" or surface == "void" or surface == "rock":
		return true

	if get_rock_at(tile) != null:
		return true

	return false


func get_tile_type(tile_pos: Vector2i) -> String:
	var tile_data := tiles.get_cell_tile_data(tile_pos)
	if tile_data == null:
		return "void"
	return tile_data.get_custom_data("type")
