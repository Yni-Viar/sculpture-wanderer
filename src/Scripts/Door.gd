extends InteractableStatic

func _physics_process(delta: float) -> void:
	if get_tree().root.get_node("Game").data == 63:
		var mat: StandardMaterial3D = load("res://Assets/OriginalAssets/Door/door.tres")
		mat.emission_enabled = true
		mat.emission = Color.WHITE
		mat.emission_energy_multiplier = 2.0
		$Cube_001.set_surface_override_material(0, mat)
		$Cube_002.set_surface_override_material(0, mat)
		set_physics_process(false)

func interact(player: Node3D):
	if get_tree().root.get_node("Game").data == 63:
		get_tree().root.get_node("Game").end_game()
