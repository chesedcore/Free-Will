extends Node3D

func _ready() -> void:
	$GPUParticles3D.restart()
	
	$GPUParticles3D.finished.connect(queue_free)
