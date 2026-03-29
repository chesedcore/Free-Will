class_name RailCannonParticles extends Node3D

@export var cannon_particles: GPUParticles3D


func _ready() -> void:
	cannon_particles.restart()

	cannon_particles.finished.connect(queue_free)

static func attach_to(node: Node) -> void:
	var particles := Registry.create_railcannonfire()
	node.add_child(particles)

static func compile_particles(tree : SceneTree) -> void:
	var particles := Registry.create_railcannonfire()
	tree.current_scene.add_child(particles)
