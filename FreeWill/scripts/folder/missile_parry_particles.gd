class_name ParryParticles extends Node3D

@export var sparks : GPUParticles3D

func _ready() -> void:
	sparks.restart()
	
	sparks.finished.connect(queue_free)

static func attach_to(tree : SceneTree, basis : Basis, pos : Vector3) -> void:
	var particles := Registry.create_parry_particles()
	tree.root.add_child(particles)
	particles.basis = basis
	particles.position = pos

static func compile_particles(tree : SceneTree) -> void:
	var particles := Registry.create_parry_particles()
	tree.current_scene.add_child(particles)
