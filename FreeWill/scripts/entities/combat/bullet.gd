class_name Bullet extends RigidBody3D

@export_group("Bullet Data")
@export var speed: float = 150.0
@export var damage: float = 25.0
@export var despawn_time: float = 5.0
@export var homing_value: float = 500.0 ## Higher equals more accurate homing capabilities.
@export var homing_time_seconds: float = 3.0
@export var bullet_model: Node3D

var target: PhysicsBody3D
var homing_time_left: float = 0.0

static func fire_bullet_from_tank(tank: PlayerTank) -> void:
	var new_bullet := Registry.create_bullet()
	new_bullet.transform = tank.bullet_spawn_position_marker.global_transform
	new_bullet.transform.origin += tank.linear_velocity * 0.01
	new_bullet.linear_velocity = tank.linear_velocity
	
	var attack_target := IFFTracker.get_lock_this_frame().unwrap_unchecked() as PhysicsBody3D
	new_bullet.target = attack_target
	tank.get_tree().root.add_child.call_deferred(new_bullet)

func _ready() -> void:
	apply_bullet_force()
	homing_time_left = homing_time_seconds
	get_tree().create_timer(despawn_time).timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if (target):
		bullet_model.look_at(linear_velocity + global_position)

	homing_time_left -= delta


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if (homing_time_left < 0.0):
		return

	if (!target):
		return

	var target_position: Vector3 = target.global_position

	if (target is BaseEnemy):
		target_position += target.get_real_velocity() * 0.25

	state.linear_velocity += \
		global_position.direction_to(target_position) * \
			homing_value * get_physics_process_delta_time()


func apply_bullet_force() -> void:
	var bullet_speed: float = speed
	if (target):
		var distance_to_target: float = global_position.distance_to(target.global_position)
		bullet_speed *= clampf(distance_to_target, 0.1, 2.0)

	linear_velocity += -transform.basis.z * bullet_speed


func _on_body_entered(body: Node3D) -> void:
	if body is not BaseEnemy: return
	body.damage(damage)
	print("DAMAGED")
	queue_free()
