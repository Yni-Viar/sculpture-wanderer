extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rotation_degrees.y > 360.0:
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	rotate_y(delta)
