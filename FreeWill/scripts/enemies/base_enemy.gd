class_name BaseEnemy extends CharacterBody3D

#replace with model
@export var model: Node3D
@export var health: float = 50

signal died

func damage(amount: float) -> void:
	health -= amount
	if (health <= 0.0):
		kill()


func kill() -> void:
	IFFTracker.stop_tracking_entity(self)
	DeathExplosionParticles.spawn_at(get_tree(), self)
	died.emit()
	queue_free.call_deferred()


func apply_knockback(dir: Vector3, strength: float = 255.0) -> void:
	velocity += dir * strength
