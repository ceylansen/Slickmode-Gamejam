extends Camera2D


func camera_shake(intensity := 0.2, time := 0.01):
	var t = create_tween()
	for i in range(4):
		t.tween_property(
			self,
			"offset",
			Vector2(
				randf_range(-intensity, intensity),
				randf_range(-intensity, intensity)
			),
			time / 4
		)
	t.tween_property(self, "offset", Vector2.ZERO, 0.05)

func nudge_camera(dir: Vector2i):
	var shift_offset := Vector2(dir) * 4
	var t := create_tween()
	t.tween_property(self, "offset", shift_offset, 0.1)

func reset_camera():
	var t := create_tween()
	t.tween_property(self, "offset", Vector2.ZERO, 0.15)
