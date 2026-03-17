extends Node3D

@export var fire_particles: GPUParticles3D
@export var smoke_particles: GPUParticles3D
@export var cannon_particles: GPUParticles3D


func _ready() -> void:
	fire_particles.restart()
	smoke_particles.restart()
	cannon_particles.restart()

	smoke_particles.finished.connect(queue_free)
	var renderer : String = RenderingServer.get_current_rendering_method()
	var mat : StandardMaterial3D = cannon_particles.draw_pass_1.surface_get_material(0)
	if renderer == "forward_plus":
		mat.albedo_color = Color(1.0, 0.337, 0.0)
	else:
		mat.albedo_color = Color(1.0, 0.005, 0.0)
