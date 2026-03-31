extends Node3D

@export var rings : Array[MeshInstance3D]

var t := 0.

func _process(delta: float) -> void:
	var i : int = 0
	while i < len(rings):
		var value : float = sin(t - i/PI)
		rings[i].scale = Vector3(value, value, value)
		i += 1
	t += delta
