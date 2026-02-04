extends Node2D

@onready var Levels = $Levels


var levels := [
	"res://scenes/levels/1.tscn",
	"res://scenes/levels/2.tscn",
	"res://scenes/levels/3.tscn"
]

var current_level_index := 0
var current_level: Node = null
var movestates : Node = null

func load_level(index: int):
	Gamestate.clear_undo()
	if current_level:
		current_level.queue_free()
	
	current_level_index = index
	current_level = load(levels[index]).instantiate()
	Levels.add_child(current_level)

func on_level_completed():
	load_level(current_level_index + 1)
	
	

func reset_level():
	load_level(current_level_index)
