@tool
class_name RailgunParticles extends Node3D

@export_tool_button("Fire Railgun") var fire_function : Callable = fire_beam

@export var destroy_self : bool = false:
	set(value):
		destroy_self = value
@export var beam : GPUParticles3D
@export var swirly : GPUParticles3D
@export var shockwaves : GPUParticles3D
@export var lifetime : float = 3.
@export var speed_scale : float = 5.

const ZERO_POINT_THREE_THREE_FIVE: float = 0.335
const SIX_HUNDRED_EIGHTY_FIVE : float = 685.
const TWELVE : float = 12.

var length : float = 750.
var growth : float = 0.
var firing : bool = false
var shockwave : int = 1
var shockwave_count : int = 6

var beam_process_mat : ParticleProcessMaterial
var swirly_process_mat : ParticleProcessMaterial

func _ready() -> void:
	beam_process_mat = beam.process_material
	swirly_process_mat = swirly.process_material
	var mesh : CapsuleMesh = beam.draw_pass_1
	var magic_velocity : float = ZERO_POINT_THREE_THREE_FIVE * length + (SIX_HUNDRED_EIGHTY_FIVE/TWELVE)
	mesh.height = length
	beam_process_mat.initial_velocity_min = magic_velocity
	beam_process_mat.initial_velocity_max = magic_velocity
	fire_beam()

func fire_beam() -> void:
	growth = 12.
	swirly_process_mat.emission_ring_height = growth
	swirly_process_mat.emission_shape_offset.y = growth / 2.
	beam.restart()
	swirly.restart()
	shockwaves.restart()
	firing = true
	shockwave = 1
	shockwaves.position = Vector3.ZERO
	if destroy_self:
		swirly.finished.connect(queue_free)

func _process(delta: float) -> void:
	if firing and growth < length:
		var rate_per_second : float = length / ((lifetime / 2.) / speed_scale)
		var rate_per_delta : float = rate_per_second * delta
		growth += rate_per_delta
		swirly_process_mat.emission_ring_height = growth
		swirly_process_mat.emission_shape_offset.y = growth / 2.
		if length / shockwave_count * shockwave - 100. <= growth:
			shockwaves.position.y = growth
			shockwave += 1
	else:
		swirly.emitting = false
		shockwaves.emitting = false
		firing = false
		#fire_beam()

static func spawn_particles(railgun_range:float, pos:Vector3, camera_gimbal:CameraGimbal, viewport:Viewport, tree:SceneTree,  destroy:=true) -> void:
	var particles := Registry.create_railgun()
	var camera : Camera3D = camera_gimbal.camera
	var screen_center := viewport.get_visible_rect().size/2
	var direction: Vector3 = camera.project_ray_normal(screen_center).normalized()
	var look_basis := Basis.looking_at(direction, Vector3.UP)
	var capsule_basis := look_basis * Basis(Vector3.RIGHT, deg_to_rad(-90.0))
	particles.length = railgun_range
	particles.destroy_self = destroy
	tree.current_scene.add_child(particles)
	particles.basis = capsule_basis
	particles.global_position = pos
