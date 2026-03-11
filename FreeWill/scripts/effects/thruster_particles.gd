extends Node3D


@onready var thrust_effect: GPUParticles3D = $thrust_effect


func _ready() -> void:
	thrust_effect.emitting = true
	thrust_effect.restart()
