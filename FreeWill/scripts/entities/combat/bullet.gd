class_name Bullet extends RigidBody3D

@export_group("Bullet Data")
@export var speed: float = 150.0
@export var damage: int = 1
@export var despawn_time: float = 5.0
@export var homing_value: float = 500.0 ## Higher equals more accurate homing capabilities.
@export var homing_time_seconds: float = 3.0

var target: Node3D
var homing_time_left: float = 0.0


func _ready() -> void:
	apply_bullet_force()
	homing_time_left = homing_time_seconds
	get_tree().create_timer(despawn_time).timeout.connect(queue_free)


func _process(delta: float) -> void:
	homing_time_left -= delta


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if (homing_time_left < 0.0):
		return

	if (!target):
		return

	state.linear_velocity += \
		global_position.direction_to(target.global_position) * \
			homing_value * get_physics_process_delta_time()


func apply_bullet_force() -> void:
	linear_velocity += -transform.basis.z * speed
