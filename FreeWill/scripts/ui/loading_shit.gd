extends Node3D

signal finished

func _ready() -> void:
	var tree := get_tree()
	RailgunParticles.compile_particles(tree)
	CannonParticles.compile_particles(tree)
	ExplosionParticles.compile_particles(tree)
	DeathExplosionParticles.compile_particles(tree)
	RailCannonParticles.compile_particles(tree)
	AerialSmokeParticles.compile_particles(tree)
	StationarySmokeParticles.compile_particles(tree)
	ParryParticles.compile_particles(tree)
	
	await tree.process_frame
	await tree.process_frame
	
	finished.emit()
