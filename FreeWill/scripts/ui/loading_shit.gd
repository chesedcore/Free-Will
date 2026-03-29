extends Node3D

signal finished

func _ready() -> void:
	var tree := get_tree()
	RailgunParticles.compile_particles(tree)
	
	await tree.process_frame
	await tree.process_frame
	
	finished.emit()
