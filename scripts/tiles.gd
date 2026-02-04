extends TileMapLayer

@export var is_important = false

func _ready():
	if is_important:
		add_to_group("tiles")
