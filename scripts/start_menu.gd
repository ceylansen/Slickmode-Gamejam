extends Control

@onready var musicbus = AudioServer.get_bus_volume_linear(1)
@onready var sfxbus = AudioServer.get_bus_volume_linear(2)


func _ready() -> void:
	%Musicslider.value = musicbus
	%SFXslider.value = sfxbus




func _on_sf_xslider_drag_ended(value_changed: bool) -> void:
		if value_changed:
			AudioServer.set_bus_volume_linear(2, %SFXslider.value)


func _on_musicslider_drag_ended(value_changed: bool) -> void:
		if value_changed:
			AudioServer.set_bus_volume_linear(1, %Musicslider.value)


func _on_label_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/real_main.tscn")
