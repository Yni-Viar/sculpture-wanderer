extends Node3D

var data: int = 0b00000000:
	set(val):
		data = val
		save_to_file(data)

var mouse_released: bool = false
var loaded: bool = false
var path_timer: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match OS.get_name():
		"Web", "Android":
			$WorldEnvironment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			$WorldEnvironment.environment.ambient_light_color = Color.GRAY
			$WorldEnvironment.environment.ssao_enabled = false
			$WorldEnvironment.environment.glow_enabled = false
			$DirectionalLight3D.hide()
	data = load_from_file()
	loaded = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.get_name() == "Web":
			if !OS.is_debug_build():
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mouse_released else Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().quit()
	elif Input.is_action_just_pressed("help"):
		$UI/Help.visible = !$UI/Help.visible
		$ThePath.visible = !$ThePath.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$ThePath.add_point(Time.get_ticks_msec(), $Player.global_position)

func save_to_file(content: int):
	if OS.get_name() != "Web":
		var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
		file.store_64(content)

func load_from_file() -> int:
	if !FileAccess.file_exists("user://save_game.dat") || OS.get_name() == "Web":
		save_to_file(0)
		return 0
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	var content = file.get_64()
	return content

func end_game() -> void:
	$UI/AnimationPlayer.play("finish")
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.stream = preload("res://Sounds/Generic/49090__gyzhor__spoon_drop1_CC0.ogg")
	$AudioStreamPlayer.play()
	$Player.health_manage(-16777216, 0, "Simulation stopped")
	save_to_file(0)
	$UI.end_game()
	await get_tree().create_timer(5.0).timeout
	if OS.get_name() != "Web":
		get_tree().quit()
