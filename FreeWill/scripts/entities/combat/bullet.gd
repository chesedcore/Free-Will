class_name Bullet extends RigidBody3D

@export_group("Bullet Data")
@export var speed: float = 150.0
@export var damage: int = 1
@export var despawn_time: float = 2.0


func _ready() -> void:
	apply_bullet_force()
	get_tree().create_timer(despawn_time).timeout.connect(queue_free)


func apply_bullet_force() -> void:
	linear_velocity += -transform.basis.z * speed
