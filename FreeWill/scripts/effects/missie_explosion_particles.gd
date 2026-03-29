class_name ExplosionParticles extends Node3D

@export var fire_particles: GPUParticles3D
@export var smoke_particles: GPUParticles3D


func _ready() -> void:
	fire_particles.restart()
	smoke_particles.restart()

	smoke_particles.finished.connect(queue_free)

static func attach_to(node: Node) -> void:
	var particles := Registry.create_missile_explosion()
	node.add_child(particles)

static func compile_particles(tree : SceneTree) -> void:
	var particles := Registry.create_missile_explosion()
	tree.current_scene.add_child(particles)
