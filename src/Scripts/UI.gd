extends Control

var poweroff_ratio: float = 0.0:
	set(val):
		poweroff_ratio = val
		end_game_curtains_down(1.0 - poweroff_ratio)
var poweron_ratio: float = 0.0:
	set(val):
		poweron_ratio = val
		end_game_curtains_up(poweron_ratio)
var tween: Tween

var input_amount: Dictionary[int, Vector2] = {}

var input_walk_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		$Jump.show()
		$LeftHand.show()
		$RightHand.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func end_game() -> void:
	if $TextureRect.material is ShaderMaterial:
		$TextureRect.show()
		tween = create_tween()
		tween.tween_property(self, "poweroff_ratio", 1.0, 1.0)
		await get_tree().create_timer(1.0).timeout
		$TextureRect2.show()
		if $TextureRect2.material is ShaderMaterial:
			$TextureRect.hide()
			tween = create_tween()
			tween.tween_property(self, "poweron_ratio", 1.0, 1.0)
			await get_tree().create_timer(1.0).timeout
			$Completed.show()

func end_game_curtains_down(value: float) -> void:
	$TextureRect.material.set_shader_parameter("progress", value)

func end_game_curtains_up(value: float) -> void:
	$TextureRect2.material.set_shader_parameter("intensity", value)

func _on_jump_pressed() -> void:
	Input.action_press("move_jump")
	Input.action_release("move_jump")

func input_walk(event: InputEvent) -> void:
	# BEGIN https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/gesture_area.gd
# Copyright (c) 2014-present Godot Engine contributors.
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
# Licensed under MIT license
	var finger_count := input_amount.size()

	if finger_count == 0:
		# No fingers => Accept press.
		if event is InputEventScreenTouch:
			if event.pressed:
				# A finger started touching.
# END https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/gesture_area.gd
				Input.action_press("move_forward")
# BEGIN https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/gesture_area.gd
# Copyright (c) 2014-present Godot Engine contributors.
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
# Licensed under MIT license
				input_amount[event.index] = event.position

	elif finger_count == 1:
		# One finger => For rotating around X and Y.
		# Accept one more press, unpress or drag.
		if event is InputEventScreenTouch:
			if input_amount.has(event.index):
				# Only touching finger released.
# END https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/gesture_area.gd
				Input.action_release("move_forward")
# BEGIN https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/gesture_area.gd
# Copyright (c) 2014-present Godot Engine contributors.
# Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.
# Licensed under MIT license
				
				input_amount.clear()
# END https://github.com/godotengine/godot-demo-projects/blob/master/mobile/multitouch_cubes/gesture_area.gd

func _on_left_hand_gui_input(event: InputEvent) -> void:
	input_walk(event)


func _on_right_hand_gui_input(event: InputEvent) -> void:
	input_walk(event)
