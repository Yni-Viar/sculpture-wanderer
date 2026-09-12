extends Node3D
class_name TerrainChunk


@onready var terrain_manager: InfiniteTerrainGenerator = get_parent()

@export var chunk_size: Vector2i = Vector2i(64, 64)

var has_lake: bool = false

var underwater_monument: Vector2i = Vector2i.ZERO

var terrain_mesh: ArrayMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func generate(offset: Vector2, immediate: bool) -> void:
	if terrain_mesh == null:
		await terrain_generator(offset, immediate)
	
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = terrain_mesh
	mi.mesh.surface_set_material(0, preload("res://Shaders/chunk.tres"))
	mi.create_trimesh_collision()
	call_deferred("add_child", mi)
	
	var water_level: MeshInstance3D = MeshInstance3D.new()
	water_level.mesh = PlaneMesh.new()
	water_level.mesh.size = Vector2(64, 64)
	water_level.mesh.center_offset = Vector3(32, -1, 32)
	water_level.mesh.surface_set_material(0, preload("res://Shaders/water.tres"))
	call_deferred("add_child", water_level)
	biome_generator(terrain_manager.biomes, offset)

## Generates terrain
func terrain_generator(offset: Vector2i, immediate: bool) -> void:
	var noise_offset: Vector2 = Vector2(offset.x * chunk_size.x, offset.y * chunk_size.y)
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color(1, 1, 1))
	var uv: Vector2
	for z in range(int(chunk_size.y + 1)):
		for x in range(int(chunk_size.x + 1)):
			var height: float = terrain_manager.biomes.get_noise_2d(noise_offset.x + x, noise_offset.y + z)
			height *= biome_height_generator(noise_offset, x, z, terrain_manager.biomes, true)
			
			# BEGIN THIRDPARTY CONTENT
			# USED FROM https://github.com/bsubard/Godot-3D-Procedural-Infinite-Terrain
			# MADE BY bsubard
			# Licensed under MIT License
			uv = Vector2(x / float(chunk_size.x), z / float(chunk_size.y))
			st.set_uv(uv)
			# END THIRDPARTY CONTENT
			
			st.add_vertex(Vector3(x, height, z))
		if !immediate:
			await get_tree().process_frame
	# BEGIN THIRDPARTY CONTENT
	# USED FROM https://github.com/bsubard/Godot-3D-Procedural-Infinite-Terrain
	# MADE BY bsubard
	# Licensed under MIT License
	for z in range(int(chunk_size.y)):
		for x in range(int(chunk_size.x)):
			var i00 = z * (chunk_size.x + 1) + x
			var i10 = i00 + 1
			var i01 = (z + 1) * (chunk_size.x + 1) + x
			var i11 = i01 + 1
			st.add_index(i00); st.add_index(i10); st.add_index(i01)
			st.add_index(i10); st.add_index(i11); st.add_index(i01)
		if !immediate:
			await get_tree().process_frame
	# END THIRDPARTY CONTENT
	st.generate_normals()
	if !immediate:
		await get_tree().process_frame
	st.generate_tangents()
	if !immediate:
		await get_tree().process_frame
	terrain_mesh = st.commit()

func biome_height_generator(noise_offset: Vector2i, x: int, y: int, noise_value: FastNoiseLite, generate_lake_monument: bool) -> float:
	if noise_offset.x + x < noise_offset.x + 30 && noise_offset.y + y < noise_offset.y + 30 && noise_offset.x + x > noise_offset.x + 3 && noise_offset.y + y > noise_offset.y + 3:
		if noise_value.get_noise_2d(noise_offset.x + x, noise_offset.y + y) > 0.85 && terrain_manager.enable_mountains:
			return 32.0
		elif noise_value.get_noise_2d(noise_offset.x + x, noise_offset.y + y) < -0.1:
			has_lake = true
			if noise_value.get_noise_2d(noise_offset.x + x - 1, noise_offset.y + y - 1) < -0.1 && \
			   noise_value.get_noise_2d(noise_offset.x + x - 1, noise_offset.y + y) < -0.1 && \
			   noise_value.get_noise_2d(noise_offset.x + x - 1, noise_offset.y + y + 1) < -0.1 && \
			   noise_value.get_noise_2d(noise_offset.x + x + 1, noise_offset.y + y - 1) < -0.1 && \
			   noise_value.get_noise_2d(noise_offset.x + x + 1, noise_offset.y + y) < -0.1 && \
			   noise_value.get_noise_2d(noise_offset.x + x + 1, noise_offset.y + y + 1) < -0.1 && \
			   generate_lake_monument:
				underwater_monument = Vector2i(noise_offset.x + x, noise_offset.y + y)
			return 32.0
		elif noise_value.get_noise_2d(noise_offset.x + x, noise_offset.y + y) < -0.01:
			has_lake = true
			return 2.0
		elif noise_value.get_noise_2d(noise_offset.x + x, noise_offset.y + y) < 0.625 && noise_value.get_noise_2d(x, y) > 0.375:
			return 2.0
		else:
			return 1.0
	else:
		return 1.0

func biome_generator(noise_value: FastNoiseLite, offset: Vector2i):
	if !terrain_manager.enable_biome:
		return
	var noise_offset: Vector2 = Vector2(offset.x * chunk_size.x, offset.y * chunk_size.y)
	var static_body: StaticBody3D = StaticBody3D.new()
	add_child(static_body)
	## Forest and lake generation
	for i in range(terrain_manager.trees_for_forest.size()):
		# Create the multimesh.
		var multimesh: MultiMesh = MultiMesh.new()
		# Set the format first.
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		# Set the mesh that will be duplicated.
		multimesh.mesh = terrain_manager.trees_for_forest[i]
		# Then resize (otherwise, changing the format is not allowed).
		multimesh.instance_count = terrain_manager.trees_count_per_chunk
		# Maybe not all of them should be visible at first.
		multimesh.visible_instance_count = terrain_manager.trees_count_per_chunk
		
		# Set the transform of the instances.
		for j in multimesh.visible_instance_count:
			var failed: bool = false
			var tree_random_coords: Vector2 = Vector2(terrain_manager.rng.randi_range(noise_offset.x, noise_offset.x + chunk_size.x), terrain_manager.rng.randi_range(noise_offset.y, noise_offset.y + chunk_size.y))
			for k in range(128):
				if noise_value.get_noise_2dv(tree_random_coords) > 0.375 && noise_value.get_noise_2dv(tree_random_coords) < 0.675:
					break
				elif k < 127:
					tree_random_coords = Vector2(terrain_manager.rng.randi_range(noise_offset.x, noise_offset.x + chunk_size.x), terrain_manager.rng.randi_range(noise_offset.y, noise_offset.y + chunk_size.y))
				else:
					failed = true
					break
			if failed:
				break
			
			var height: float = noise_value.get_noise_2dv(tree_random_coords)
			if height < -0.01: 
				break
			
			# Fix floating tree bug
			var random_position: Vector3 = Vector3(tree_random_coords.x - noise_offset.x, height - 1, tree_random_coords.y - noise_offset.y)
			multimesh.set_instance_transform(j, Transform3D(Basis(), random_position))
			var collider: CollisionShape3D = CollisionShape3D.new()
			collider.shape = CylinderShape3D.new()
			collider.shape.height = 32.0
			collider.shape.radius = 2.0
			static_body.add_child(collider)
			collider.position = Vector3(random_position.x, height - 1 + 16.0, random_position.z)
		var mmi: MultiMeshInstance3D = MultiMeshInstance3D.new()
		mmi.multimesh = multimesh
		if OS.get_name() == "Web" || OS.get_name() == "Android":
			mmi.visibility_range_end = 128.0
		add_child(mmi)
	
	## /!\ WARNING
	## If you want only forest generation - remove any code below
	
	var rng_value: int = terrain_manager.rng.randi_range(noise_offset.x, noise_offset.x + 32)
	
	if underwater_monument != Vector2i(0, 0):
		var d: Node3D = preload("res://Assets/OriginalAssets/D.tscn").instantiate()
		add_child(d)
		d.global_position = Vector3(underwater_monument.x, noise_value.get_noise_2d(underwater_monument.x, underwater_monument.y) * 32 + 1.0, underwater_monument.y)
	
	if rng_value % 8 == 1:
		rng_value = terrain_manager.rng.randi_range(noise_offset.x + rng_value, noise_offset.x + rng_value + 7)
	
	rng_value = abs(rng_value % 8)
	
	var random_coords: Vector2 = Vector2(terrain_manager.rng.randf_range(noise_offset.x, noise_offset.x + chunk_size.x), terrain_manager.rng.randf_range(noise_offset.y, noise_offset.y + chunk_size.y))
	var height: float = noise_value.get_noise_2dv(random_coords)
	match rng_value:
		1: #Exit door
			if height < -0.01: 
				return
			var door: Node3D = preload("res://Assets/OriginalAssets/Door.tscn").instantiate()
			add_child(door)
			door.global_position = Vector3(random_coords.x, noise_value.get_noise_2dv(random_coords), random_coords.y)
		2: #Sculpture
			if height < -0.01: 
				return
			var c: Node3D = preload("res://Assets/OriginalAssets/C.tscn").instantiate()
			add_child(c)
			c.global_position = Vector3(random_coords.x, noise_value.get_noise_2dv(random_coords), random_coords.y)
		3: #Sculpture
			if height < -0.01:
				return
			var l: Node3D = preload("res://Assets/OriginalAssets/L.tscn").instantiate()
			add_child(l)
			l.global_position = Vector3(random_coords.x, noise_value.get_noise_2dv(random_coords), random_coords.y)
		4: #Sculpture
			if height < -0.01:
				return
			var t: Node3D = preload("res://Assets/OriginalAssets/T.tscn").instantiate()
			add_child(t)
			t.global_position = Vector3(random_coords.x, noise_value.get_noise_2dv(random_coords), random_coords.y)
		5: #Chair
			if height < -0.01:
				return
			var chair: Node3D = preload("res://Assets/OriginalAssets/chair.tscn").instantiate()
			add_child(chair)
			chair.global_position = Vector3(random_coords.x, noise_value.get_noise_2dv(random_coords), random_coords.y)
		6: #Sculpture
			if height < -0.01:
				return
			var oi: Node3D = preload("res://Assets/OriginalAssets/01.tscn").instantiate()
			add_child(oi)
			oi.global_position = Vector3(random_coords.x, noise_value.get_noise_2dv(random_coords), random_coords.y)
		7: #Sculpture
			if height < -0.01:
				return
			var r: Node3D = preload("res://Assets/OriginalAssets/R.tscn").instantiate()
			add_child(r)
			r.global_position = Vector3(random_coords.x, noise_value.get_noise_2dv(random_coords), random_coords.y)
