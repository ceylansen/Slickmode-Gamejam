extends Node2D
@export var maxpositive := 500


func _ready():
	for i in range(100):
		var star := Sprite2D.new()
		star.texture = preload("res://sprites/star.png")
		star.position = Vector2(
			randf_range(-200, maxpositive),
			randf_range(-200, maxpositive)
		)
		star.modulate.a = randf_range(0.3, 0.8)
		add_child(star)
		animate_star(star)

func animate_star(star):
	var t = create_tween().set_loops()
	t.tween_property(star, "modulate:a", 0.1, randf_range(1.5, 3.0))
	t.tween_property(star, "modulate:a", 0.8, randf_range(1.5, 3.0))
