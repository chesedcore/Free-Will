class_name BaseEnemy extends CharacterBody3D


@export var health: float = 100.0


func damage(amount: float) -> void:
	health -= amount
	if (health <= 0.0):
		kill()


func kill() -> void:
	IFFTracker.stop_tracking_entity(self)
	queue_free()
