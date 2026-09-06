extends Node3D
## Static player
## Made by Yni, licensed under MIT License.
class_name StaticPlayer

enum CameraMode {ALL, UPPERLOOK, THIRD_PERSON, SIZE}

var mouse_sensitivity = 0.03125

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$Head/Camera3D.current = true
	# OpenGL Compatibility renderer supports SSAO since Godot 4.6
	# As for May 2026, we stay on 4.5 just because it is the most stable\
	# Godot release.
	#if Settings.setting_res.ssao && (RenderingServer.get_current_rendering_method() == "mobile" || \
	 #(RenderingServer.get_current_rendering_method() == "gl_compatibility" && \
	  #Engine.get_version_info()["minor"] < 6)):
		## No longer used, since we updated to Godot 4.7
		#$Head/Camera3D/Overlays/OverlayCompositor.apply_shader(1)

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#if Input.is_action_pressed("look"):
			#rotate_player(event)
	#if event is InputEventScreenDrag:
		#rotate_player(event)
	#if event.is_action_pressed("scroll_up"):
		#scroll_factor += 0.125
		#scroll_factor = clamp(scroll_factor, 1.0, 8.0)
		#$Head/Camera3D.fov = 75.0 / scroll_factor
	#if event.is_action_pressed("scroll_down"):
		#scroll_factor -= 0.125
		#scroll_factor = clamp(scroll_factor, 1.0, 8.0)
		#$Head/Camera3D.fov = 75.0 / scroll_factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate_player_by_key(Vector2i(int(Input.is_action_just_pressed("camera_rotate_right")) - int(Input.is_action_just_pressed("camera_rotate_left")), 0))

func rotate_player_by_key(direction: Vector2i):
	var x_dir: float
	var y_dir: float
	match direction:
		Vector2i.UP:
			y_dir = 15
		Vector2i.DOWN:
			y_dir = -15
		Vector2i.LEFT:
			x_dir = -45
		Vector2i.RIGHT:
			x_dir = 45
	# Yni: Necessary to fix annoying bug on Android, when if you rotate screen, player began to move.
	# https://kidscancode.org/godot_recipes/3.x/3d/camera_gimbal/index.html
	rotate_object_local(Vector3.UP, deg_to_rad(x_dir))
	var y_rotation = clamp(y_dir, -30, 30)
	$Head.rotate_object_local(Vector3.RIGHT, deg_to_rad(y_rotation))
	$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x, -90, 0)
