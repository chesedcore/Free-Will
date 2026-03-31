class_name LoadingShit extends Node3D

signal finished

@export var charge_particles : GPUParticles3D
@export var charge_spark_particles : GPUParticles3D

func _ready() -> void:
	var tree := get_tree()
	charge_particles.restart()
	charge_spark_particles.restart()
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
