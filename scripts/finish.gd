extends Node2D

@onready var tiles : TileMapLayer
@export var value : int = 1
var tile_pos: Vector2i
@onready var game



func _ready() -> void:
	tiles = get_tree().get_first_node_in_group("tiles")
	tile_pos = tiles.local_to_map(global_position)
	global_position = tiles.map_to_local(tile_pos)
	add_to_group("finish")
	$AnimatedSprite2D.frame = value - 1
	#game = get_tree().get_nodes_in_group("main")[0]

func check_finish(val) -> void:
	if val == value:
		game.on_level_completed()
