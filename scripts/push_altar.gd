extends Area2D

@export var tiles: TileMapLayer
@export var player : CharacterBody2D
var tile_pos: Vector2i

var inrange := false
var activated := false
var shown := false


func _ready() -> void:

	$Interact.hide()
	tile_pos = tiles.local_to_map(global_position)
	global_position = tiles.map_to_local(tile_pos)




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if inrange:
			if !activated:
				player.set_push_mode(true)
				$Interact.hide()
				activated = true
			else:
				player.set_push_mode(false)
				#$Interact.show()
				activated = false
				


func _on_body_entered(_body: Node2D) -> void:
	inrange = true
	if !shown:
		$Interact.show()
		shown = true


func _on_body_exited(_body: Node2D) -> void:
	$Interact.hide()
	inrange = false
