@tool
extends Node3D

@export_tool_button("Fire Railgun") var fire_function : Callable = fire_beam

@export var destroy_self : bool = false:
	set(value):
		destroy_self = value
@export var beam : GPUParticles3D
@export var swirly : GPUParticles3D
@export var lifetime : float = 3.
@export var speed_scale : float = 5.

const ZERO_POINT_ONE_SIX_EIGHT: float = 0.168
const FOUR : float = 4.
const THREE : float = 3.

var length : float = 750.
var growth : float = 0.
var firing : bool = false

var beam_process_mat : ParticleProcessMaterial
var swirly_process_mat : ParticleProcessMaterial

func _ready() -> void:
	beam_process_mat = beam.process_material
	swirly_process_mat = swirly.process_material
	var mesh : CapsuleMesh = beam.draw_pass_1
	var magic_velocity : float = ZERO_POINT_ONE_SIX_EIGHT * length - (FOUR/THREE)
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
	firing = true
	if destroy_self:
		swirly.finished.connect(queue_free)

func _process(delta: float) -> void:
	if firing and growth < length:
		var rate_per_second : float = length / (lifetime / speed_scale)
		var rate_per_delta : float = rate_per_second * delta
		growth += rate_per_delta
		swirly_process_mat.emission_ring_height = growth
		swirly_process_mat.emission_shape_offset.y = growth / 2.
	else:
		swirly.emitting = false
		firing = false
	
