extends Node2D

@onready var Levels = $Levels
@onready var Music = $Music
@onready var FinishSound = $FinishLevel


var levels := [
	"res://scenes/levels/1.tscn",
	"res://scenes/levels/2.tscn",
	"res://scenes/levels/3.tscn",
	"res://scenes/levels/4.tscn",
	"res://scenes/levels/5.tscn",
	"res://scenes/levels/6.tscn",
	"res://scenes/levels/7.tscn",
	"res://scenes/levels/8.tscn",
	"res://scenes/levels/9.tscn",
	"res://scenes/levels/10.tscn",
]

var current_level_index := 0
var current_level: Node = null
var movestates : Node = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		reset_level()

func _ready() -> void:
	load_level(current_level_index)
	Music.play()
	

func load_level(index: int):
	Gamestate.clear_undo()
	if current_level:
		current_level.queue_free()
	
	current_level_index = index
	current_level = load(levels[index]).instantiate()
	Levels.add_child(current_level)

func on_level_completed():
	FinishSound.play()
	await FinishSound.finished
	load_level(current_level_index + 1)
	
	

func reset_level():
	load_level(current_level_index)
