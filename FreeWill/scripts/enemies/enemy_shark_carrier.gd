class_name EnemySharkCarrier extends BaseEnemy
const SHARK = preload("res://scenes/entities/combat/shark.tscn")

var player : PlayerTank
var rotation_speed: float = 5.0
@export var base: MeshInstance3D
@export var shark_spawn_location: Node3D
@export var attack_timer: Timer

func _physics_process(delta: float) -> void:
	if player:
		
		var base_pos :Vector3 = base.global_position
		var flat_target : Vector3= player.global_position
		flat_target.y = base_pos.y  
		base.look_at(flat_target, Vector3.UP)
		base.rotation.y = lerp_angle(base.rotation.y, base.rotation.y, rotation_speed * delta)

func _on_line_of_sight_body_entered(body: Node3D) -> void:
	if body is PlayerTank:
		player = body
		attack_timer.start()




func _on_line_of_sight_body_exited(body: Node3D) -> void:
	if body is PlayerTank:
		if body == player:
			player = null
			attack_timer.stop()


func _on_attack_timer_timeout() -> void:
	if player:
		var particles: Node3D = \
		preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()
	
		shark_spawn_location.add_child.call_deferred(particles)
		var new_missile :HomingMissile = SHARK.instantiate()
		
		new_missile.target_node = player
		EventBus.spawn_weaponry.emit(new_missile)
		new_missile.global_position =shark_spawn_location.global_position
