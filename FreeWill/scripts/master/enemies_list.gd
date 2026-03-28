class_name EnemiesList extends Node3D

@export var airborne_enemies: Node3D
@export var seaborne_enemies: Node3D

func get_enemies() -> Array[Node]:
	
	var enemies :Array[Node] = airborne_enemies.get_children() + seaborne_enemies.get_children()
	return enemies
