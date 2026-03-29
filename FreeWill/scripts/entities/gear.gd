extends Node3D

@export var large_gear: MeshInstance3D
@export var small_gear: MeshInstance3D

@export var rotate_large_gear: bool = true
@export var rotate_small_gear: bool = true

@export var gear_speed: float = 0.1
@export var speed_randomization: float = 0.1


func _ready() -> void:
	gear_speed += randf_range(-speed_randomization, speed_randomization)


func _process(delta: float) -> void:
	if (rotate_large_gear):
		large_gear.rotation.x += (gear_speed * 0.25) * delta

	if (rotate_small_gear):
		small_gear.rotation.x += (gear_speed * 0.25) * 10.0 * delta
