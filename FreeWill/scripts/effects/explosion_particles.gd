class_name DeathExplosionParticles extends Node3D

@export var fire_particles : GPUParticles3D
@export var smoke_particles : GPUParticles3D

func _ready() -> void:
	fire_particles.restart()
	smoke_particles.restart()
	
	smoke_particles.finished.connect(queue_free)

static func spawn_at(scene_tree :SceneTree, node : Node3D) -> void:
	var particles := Registry.create_explosion()
	scene_tree.root.add_child(particles)
	particles.global_position = node.global_position
