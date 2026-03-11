class_name EnemiesList extends Node3D

@export var airborne_enemies: Node3D

func get_enemies() -> Array[Node]:
	return airborne_enemies.get_children()
