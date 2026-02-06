extends CharacterBody2D

@export var tiles: TileMapLayer
@export var move_time := 0.2
@export var floor_move_time := 0.15
@export var ice_move_time := 0.1
@export var push_mode := false

var curr_pos: Vector2i
var is_moving := false
var is_sliding := false
var slide_dir := Vector2i.ZERO
var input_dir := Vector2i.ZERO
var consumed_dir := Vector2i.ZERO
var push_cooldown := false
var facing_dir := Vector2i.DOWN
var current_surface := "floor"


func _ready():
	curr_pos = tiles.local_to_map(global_position)
	global_position = tiles.map_to_local(curr_pos)



func _physics_process(_delta) -> void:
	if is_moving:
		return

	update_input_dir()

	if is_sliding:
		continue_slide()
		return

	if input_dir == Vector2i.ZERO:
		return

	if input_dir == consumed_dir:
		return

	if push_mode:
		push_all_rocks(input_dir)
		
		consumed_dir = input_dir
	else:
		try_move(input_dir)


func update_input_dir():
	var new_dir := Vector2i.ZERO

	if Input.is_action_pressed("left"):
		new_dir = Vector2i.LEFT
	elif Input.is_action_pressed("right"):
		new_dir = Vector2i.RIGHT
	elif Input.is_action_pressed("up"):
		new_dir = Vector2i.UP
	elif Input.is_action_pressed("down"):
		new_dir = Vector2i.DOWN

	if new_dir != Vector2i.ZERO:
		facing_dir = new_dir

	if new_dir != input_dir:
		consumed_dir = Vector2i.ZERO

	input_dir = new_dir

func set_push_mode(mode : bool) -> void:
	push_mode = mode


func dir_to_name(dir: Vector2i) -> String:
	if dir == Vector2i.DOWN:
		return "down"
	if dir == Vector2i.UP:
		return "up"
	if dir == Vector2i.LEFT:
		return "left"
	if dir == Vector2i.RIGHT:
		return "right"
	return "down"


func play_walk():
	var anim := dir_to_name(facing_dir) + "walk"
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)
	else:
		if !$AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play()

func force_idle():
	var anim := dir_to_name(facing_dir) + "walk"
	$AnimatedSprite2D.play(anim)
	$AnimatedSprite2D.frame = $AnimatedSprite2D.sprite_frames.get_frame_count(anim) - 1
	$AnimatedSprite2D.stop()

func try_move(dir: Vector2i):
	var next_tile := curr_pos + dir

	var rock = get_rock_at(next_tile)
	if rock:
		play_push_animation(dir)
		if rock.push(dir, push_mode):
			var pusher = get_tree().get_first_node_in_group("Pusher")
			if pusher:
				if !pusher.is_playing():
					pusher.play()
			consumed_dir = dir
		else:
			get_parent().get_node("Camera2D").camera_shake()
			var blocked = get_tree().get_first_node_in_group("blocked")
			if blocked:
				if !blocked.is_playing():
					blocked.play()
		return

	if is_blocked(next_tile):
		return
	
	move_to_tile(next_tile)
	
	if get_tile_type(next_tile) == "ice":
		start_slide(dir)


func push_all_rocks(dir: Vector2i):
	if push_cooldown:
		return

	get_parent().get_node("Camera2D").nudge_camera(dir)

	push_cooldown = true
	await get_tree().create_timer(0.15).timeout
	push_cooldown = false
	get_parent().get_node("Camera2D").reset_camera()

	var rocks = get_tree().get_nodes_in_group("rocks")

	rocks.sort_custom(func(a, b):
		return distance_along_dir(b.tile_pos, dir) < distance_along_dir(a.tile_pos, dir)
	)

	var pushed_any := false

	for rock in rocks:
		if rock.push(dir, push_mode):
			pushed_any = true

	if pushed_any:
		var pusher = get_tree().get_first_node_in_group("Pusher")
		if pusher:
			if !pusher.is_playing():
				pusher.play()
		play_push_animation(dir)



func distance_along_dir(pos: Vector2i, dir: Vector2i) -> int:
	if dir.x != 0:
		return pos.x * dir.x
	else:
		return pos.y * dir.y

func default_facing() -> void:
	var anim = dir_to_name(facing_dir)
	$AnimatedSprite2D.play(anim)

func play_push_animation(dir: Vector2i):
	facing_dir = dir
	var anim := dir_to_name(dir) + "push"
	$AnimatedSprite2D.play(anim)

func start_slide(dir: Vector2i):
	is_sliding = true
	slide_dir = dir
	facing_dir = dir
	play_walk()

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
	
	if current_surface == "floor":
		var snow = get_tree().get_first_node_in_group("snowwalk")
		if snow:
			if !snow.is_playing():
				snow.play()
		play_walk()

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
