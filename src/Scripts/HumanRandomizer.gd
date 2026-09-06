extends Node3D


const TOGGLE_ON_BLENDSHAPES: Array[String] = [
	"L2__Ears_LobeAttached"
]

const FLOAT_BLENDSHAPES_0_TO_1: Array[String] = [
	"L2__Age_Old",
	"L2__Chin_PosZ",
	"L2__Ears_Height",
	"L2__Ears_Tragus_Protrusion",
	"L2__Ears_Lobe_Bulbous",
	"L2__Face_FrontalBone",
	"L2__Face_FrontalBone_BrowRidge",
	"L2__Face_Zygomatic_Bone",
	"L2__Nose_BridgeProminence",
	"L2__Nose_NasalAngle",
	"L2__Nose_Flatness",
	"L2__Nose_Width",
	"L2__Nose_Protrusion",
	"L2__Nose_Tip_Protrusion",
	"L2__Chest_RibWidth"
]

const FLOAT_BLENDSHAPES_MINUS_1_TO_1: Array[String] = [
	"L2__Arms_Armpit_Loc_Z",
	"L2__Eyes_Distance",
	"L2__Nose_NoseHeight"
]

const MUSCLE_DEFINITIONS: Array[String] = [
	"L2__Arms_BicepSize",
	"L2__Arms_Forearm_Girth",
	"L2__Arms_TricepSize"
]

@export_range(0.0, 1.0, 0.01) var max_random_value: float = 0.25

@export var female: bool = false

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	
	female = true if randi_range(0, 1) == 1 else false
	
	var iris: ShaderMaterial = $Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.get_surface_override_material(5)
	iris.set_shader_parameter("iris", Color(rng.randf_range(0.5, 1.0), rng.randf_range(0.5, 1.0), rng.randf_range(0.5, 1.0)))
	$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_surface_override_material(5, iris)
	if female:
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index("L2__Gender_Female"), 1.0)
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index("L2__Waist_Hips_Width"), 1.0)
	else:
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index("L2__Gender_Male"), 1.0)
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index("L2__Neck_AdamsApple"), 1.0)
	
	for bs in TOGGLE_ON_BLENDSHAPES:
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index(bs), 1.0 if rng.randi_range(0, 1) == 1 else 0.0)
	
	for bs in FLOAT_BLENDSHAPES_0_TO_1:
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index(bs), rng.randf_range(0.0, max_random_value))
	
	for bs in FLOAT_BLENDSHAPES_MINUS_1_TO_1:
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index(bs), rng.randf_range(-max_random_value, max_random_value))
	
	var muscle_random: float = rng.randf_range(0.0, max_random_value)
	
	for bs in MUSCLE_DEFINITIONS:
		$Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.set_blend_shape_value(blend_shape_index(bs), muscle_random)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func blend_shape_index(bs_name: String) -> int:
	return $Scene/mixamo_vitruvian001/Skeleton3D/cm_vitruvian002.find_blend_shape_by_name(bs_name)


## Set animation to an entity via Animation Tree.
func set_state(animation_name: String, action_name: String, amount):
	get_node("AnimationTree").set("parameters/" + animation_name + "/" + action_name, amount)
