class_name StationarySmokeParticles extends Node3D

static func attach_to(node : Node3D) -> void:
	var particles := Registry.create_stationary_smoke()
	node.add_child(particles)

static func compile_particles(tree : SceneTree) -> void:
	var particles := Registry.create_stationary_smoke()
	tree.current_scene.add_child(particles)
