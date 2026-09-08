extends Node3D

var data: int = 0b00000000:
	set(val):
		data = val
		save_to_file(data)

var mouse_released: bool = false
var loaded: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data = load_from_file()
	loaded = true

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		if OS.get_name() == "Web":
			if !OS.is_debug_build():
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_released else Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

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
