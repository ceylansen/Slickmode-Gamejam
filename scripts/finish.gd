extends Node2D

@export var tiles : TileMapLayer
@export var value : int = 1
var tile_pos: Vector2i

signal finished

func _ready() -> void:
	tile_pos = tiles.local_to_map(global_position)
	global_position = tiles.map_to_local(tile_pos)
	add_to_group("finish")
	$AnimatedSprite2D.frame = value - 1

func check_finish(val) -> void:
	if val == value:
		finished.emit()
