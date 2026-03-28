class_name CannonParticles extends Node3D

@export var fire_particles: GPUParticles3D
@export var smoke_particles: GPUParticles3D
@export var cannon_particles: GPUParticles3D

func _ready() -> void:
	fire_particles.restart()
	smoke_particles.restart()
	cannon_particles.restart()

	smoke_particles.finished.connect(queue_free)

static func attach_to(node: Node) -> void:
	var particles := Registry.create_cannonfire()
	node.add_child(particles)
