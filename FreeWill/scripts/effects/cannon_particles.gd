extends Node3D

@export var fire_particles: GPUParticles3D
@export var smoke_particles: GPUParticles3D


func _ready() -> void:
	fire_particles.restart()
	smoke_particles.restart()

	smoke_particles.finished.connect(queue_free)
