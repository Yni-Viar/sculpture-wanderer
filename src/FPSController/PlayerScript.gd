extends CharacterBody3D
## Made by Yni, licensed under CC0
class_name PlayerScript

const SPEED = 1.5
const JUMP_VELOCITY = 1.25

## Max health
@export var health: Array[float] = [100]
## Current health
@export var current_health: Array[float] = [100]
## Sprint toggle
@export var sprint_enabled: bool = false
## Move sounds toggle
@export var move_sounds_enabled: bool = false
## Walk sounds
@export var footstep_sounds: Array[String]
## Sprint sounds
@export var sprint_sounds: Array[String]
## Inventory toggle
#@export var enable_inventory: bool = false
## Movement toggle (camera can be still moved through, even if this property is disabled)
@export var can_move: bool = true

var can_move_camera: bool = true

@onready var ray = $PlayerHead/PlayerRecoil/RayCast3D
@onready var walk_sounds = $WalkSounds
@onready var interact_sound = $InteractSound

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var is_sprinting: bool = false
var is_swimming: bool = false:
	set(val):
		if !is_swimming && val:
			splash()
		is_swimming = val
var is_walking: bool = false
## Enables or disables ALL motion (including camera rotate)
var motion_enabled = true
var mouse_sensitivity: float = 0.05

func _ready() -> void:
	ray.add_exception(self)
	if !OS.is_debug_build():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Mouse rotation
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && motion_enabled && can_move_camera:
		rotate_y(-event.relative.x * mouse_sensitivity * 0.05)
		$PlayerHead.rotate_x(-event.relative.y * mouse_sensitivity * 0.05)
		
		var player_rotation = $PlayerHead.rotation_degrees
		player_rotation.x = clamp($PlayerHead.rotation_degrees.x, -85, 85)
		$PlayerHead.rotation_degrees = player_rotation

func _physics_process(delta: float) -> void:
	is_swimming = global_position.y < 0.1
	
	# Add the gravity.
	if !is_on_floor():
		if is_swimming:
			velocity += get_gravity() * 0.01 * delta
		else:
			velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") && (is_on_floor() || is_swimming):
		if global_position.y > -0.1875 && global_position.y < -0.0625:
			velocity.y = JUMP_VELOCITY * 4
		else:
			velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("camera_switch"):
		$PlayerHead/PlayerRecoil/PlayerCamera.current = false
		$StaticPlayer/Head/Camera3D.current = true
	else:
		$PlayerHead/PlayerRecoil/PlayerCamera.current = true
		$StaticPlayer/Head/Camera3D.current = false
	
	if $PlayerHead/PlayerRecoil/RayCast3D.is_colliding() && Input.is_action_just_pressed("interact"):
		var collider: Node3D = $PlayerHead/PlayerRecoil/RayCast3D.get_collider()
		if collider is InteractableStatic:
			collider.interact(self)
		elif collider is InteractableRigid:
			collider.interact(self)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && can_move && motion_enabled:
		if Input.is_action_pressed("move_sprint") && sprint_enabled:
			velocity.x = direction.x * SPEED * 3
			velocity.z = direction.z * SPEED * 3
			$PlayerModel/VitruvianGame.set_state("walk_scale", "scale", 1.5)
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			$PlayerModel/VitruvianGame.set_state("walk_scale", "scale", 1.0)
		$PlayerModel/VitruvianGame.set_state("state_machine", "blend_amount", lerp($PlayerModel/VitruvianGame/AnimationTree.get("parameters/state_machine/blend_amount"), 1.0, SPEED * delta))
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		$PlayerModel/VitruvianGame.set_state("state_machine", "blend_amount", lerp($PlayerModel/VitruvianGame/AnimationTree.get("parameters/state_machine/blend_amount"), 0.0, SPEED * delta))

	move_and_slide()

## Animation-based footstep system.
func footstep_animate():
	if move_sounds_enabled:
		if is_walking:
			call("play_footstep_sound", false)
		if is_sprinting:
			call("play_footstep_sound", true)

func splash():
	$InteractSound.stream = load("res://Sounds/Character/Splash/9508__petenice__splash.ogg")
	$InteractSound.play()

## Make footstep sounds audible to all.
func play_footstep_sound(sprinting: bool):
	if sprinting:
		walk_sounds.stream = load(sprint_sounds[rng.randi_range(0, sprint_sounds.size() - 1)])
		walk_sounds.play()
	else:
		walk_sounds.stream = load(footstep_sounds[rng.randi_range(0, footstep_sounds.size() - 1)])
		walk_sounds.play()

## Health manager.
func health_manage(amount: float, type_of_health: int, deplete_reason: String = ""):
	if type_of_health >= current_health.size():
		return
	if current_health[type_of_health] + amount <= health[type_of_health]:
		current_health[type_of_health] += amount
	else:
		current_health[type_of_health] == health[type_of_health]
	if current_health[type_of_health] <= 0:
		can_move_camera = false
		can_move = false
		set_physics_process(false)
		pass
