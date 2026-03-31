class_name ParryParticles extends Node3D

@export var sparks : GPUParticles3D

func _ready() -> void:
	sparks.restart()
	
	sparks.finished.connect(queue_free)

@warning_ignore("shadowed_variable_base_class")
static func attach_to(tree : SceneTree, basis : Basis, pos : Vector3) -> void:
	var particles := Registry.create_parry_particles()
	tree.root.add_child(particles)
	particles.basis = basis
	particles.position = pos

static func compile_particles(node : Node3D) -> void:
	var particles := Registry.create_parry_particles()
	node.add_child(particles)
