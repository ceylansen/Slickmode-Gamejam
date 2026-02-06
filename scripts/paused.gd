extends Control

@onready var musicbus = AudioServer.get_bus_volume_linear(1)
@onready var sfxbus = AudioServer.get_bus_volume_linear(2)

var is_paused := false

func _ready() -> void:
	%Musicslider.value = musicbus
	%SFXslider.value = sfxbus

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause()


func pause() -> void:
	%Continue.grab_focus()
	get_tree().paused = !get_tree().paused
	self.visible = !self.visible

func _on_sf_xslider_drag_ended(value_changed: bool) -> void:
		if value_changed:
			AudioServer.set_bus_volume_linear(2, %SFXslider.value)


func _on_musicslider_drag_ended(value_changed: bool) -> void:
		if value_changed:
			AudioServer.set_bus_volume_linear(1, %Musicslider.value)


func _on_continue_pressed() -> void:
	pause()
