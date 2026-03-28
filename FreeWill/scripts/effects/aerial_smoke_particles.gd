class_name AerialSmokeParticles extends Node3D

static func attach_to(node : Node3D) -> void:
	var particles := Registry.create_aerial_smoke()
	node.add_child(particles)
