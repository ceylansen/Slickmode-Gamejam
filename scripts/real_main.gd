extends Node2D

@onready var Levels = $Levels

const moves = preload("res://scenes/moves.tscn")

var levels := [
	"res://scenes/levels/1.tscn",
	"res://scenes/levels/2.tscn",
	"res://scenes/levels/3.tscn"
]

var current_level_index := 0
var current_level: Node = null
var movestates : Node = null

func load_level(index: int):
	if current_level:
		current_level.queue_free()
	
	current_level_index = index
	current_level = load(levels[index]).instantiate()
	Levels.add_child(current_level)
	movestates = moves.instantiate()
	Levels.add_child(movestates)

func on_level_completed():
	movestates.queue_free()
	load_level(current_level_index + 1)
	
	

func reset_level():
	movestates.queue_free()
	load_level(current_level_index)
