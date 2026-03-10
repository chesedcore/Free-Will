class_name EnemyPlane extends BaseEnemy

@export var lock_on_timer: Timer
@export var mesh_instance_3d: MeshInstance3D

@export var missle_spawner: Node3D


func _physics_process(_delta: float) -> void:
	move_and_slide()
