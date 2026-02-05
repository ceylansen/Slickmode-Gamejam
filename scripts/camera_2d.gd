extends Camera2D

@export var float_radius := 4.0
@export var float_speed := 0.4
@export var push_offset := 8.0
@export var push_return_speed := 6.0
@export var float_quant := 0.25

var t := 0.0

var push_target := Vector2.ZERO
var push_current := Vector2.ZERO

var shake_offset := Vector2.ZERO

func _process(delta):
	t = fmod(t + delta * float_speed, TAU)

	var float_offset := Vector2(
		cos(t),
		sin(t * 1.3)
	) * float_radius

	float_offset.x = snapped(float_offset.x, float_quant)
	float_offset.y = snapped(float_offset.y, float_quant)

	push_current = push_current.lerp(
		push_target,
		delta * push_return_speed
	)

	offset = float_offset + push_current + shake_offset




func nudge_camera(dir: Vector2i):
	push_target = Vector2(dir) * push_offset

func reset_camera():
	push_target = Vector2.ZERO


func camera_shake(intensity := 0.2, time := 0.2):
	var tw := create_tween()
	for i in range(4):
		tw.tween_property(
			self,
			"shake_offset",
			Vector2(
				randf_range(-intensity, intensity),
				randf_range(-intensity, intensity)
			),
			time / 4
		)

	tw.tween_property(self, "shake_offset", Vector2.ZERO, 0.05)


#func nudge_camera(dir: Vector2i):
	#var shift_offset := Vector2(dir) * 4
	#var t := create_tween()
	#t.tween_property(self, "offset", shift_offset, 0.1)
#
#func reset_camera():
	#var t := create_tween()
	#t.tween_property(self, "offset", Vector2.ZERO, 0.15)
