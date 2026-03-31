class_name LoadingShit extends Node3D

signal finished

func _ready() -> void:
	var tree := get_tree()
	RailgunParticles.compile_particles(self)
	CannonParticles.compile_particles(self)
	ExplosionParticles.compile_particles(self)
	DeathExplosionParticles.compile_particles(self)
	RailCannonParticles.compile_particles(self)
	AerialSmokeParticles.compile_particles(self)
	StationarySmokeParticles.compile_particles(self)
	ParryParticles.compile_particles(self)

	await tree.process_frame
	await tree.process_frame
	await tree.process_frame

	finished.emit()
