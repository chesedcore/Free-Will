class_name StationarySmokeParticles extends Node3D

static func attach_to(node : Node3D) -> void:
	var particles := Registry.create_stationary_smoke()
	node.add_child(particles)

static func compile_particles(node : Node3D) -> void:
	var particles := Registry.create_stationary_smoke()
	node.add_child(particles)
