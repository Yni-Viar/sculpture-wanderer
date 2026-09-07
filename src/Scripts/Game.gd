extends Node3D

var data: int = 0b00000001:
	set(val):
		data = val
		save_to_file(data)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data = load_from_file()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_to_file(content: int):
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_64(content)

func load_from_file() -> int:
	if !FileAccess.file_exists("user://save_game.dat"):
		save_to_file(0)
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_64()
	return content

func end_game() -> void:
	$UI/AnimationPlayer.play("finish")
	$AudioStreamPlayer.stop()
	$Player.health_manage(-16777216, 0, "Simulation stopped")
