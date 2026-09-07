extends Control

var poweroff_ratio: float = 0.0:
	set(val):
		poweroff_ratio = val
		end_game_curtains_down(1.0 - poweroff_ratio)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func end_game() -> void:
	if $TextureRect.material is ShaderMaterial:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "poweroff_ratio", 1.0, 1.0)

func end_game_curtains_down(value: float) -> void:
	$TextureRect.material.set_shader_parameter("progress", value)
