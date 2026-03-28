class_name EnemySharkCarrier extends BaseEnemy
const SHARK = preload("res://scenes/entities/combat/shark.tscn")
const ENEMY_SHIP_BULLET = preload("res://scenes/entities/combat/enemy_ship_bullet.tscn")

var player : PlayerTank
var rotation_speed: float = 5.0
@export var base: MeshInstance3D
@export var shark_spawn_location: Node3D
@export var attack_timer: Timer

@export var canon_aims : Array[RayCast3D]
@export var cannon_bases : Array[Node3D]
@export var cannon_barrels : Array[Node3D]

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

func shoot(cannon_index: float)->void:
	var particles: Node3D = \
		preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()
	particles.rotation_degrees.y -= 90
	canon_aims[cannon_index].add_child.call_deferred(particles)
	
	var new_bullet: Enemy_bullet = ENEMY_SHIP_BULLET.instantiate()
	new_bullet.position =  canon_aims[cannon_index].global_position

	new_bullet.target = player

	# Monarch: Usually I'd make a dedicated `Bullets` Node3D that 'holds' this node as an array,
	# then trigger a signal that makes the World handler add the bullet to the Bullets node.
	# But for now (in the spirit of this jam), this will do just fine.
	EventBus.spawn_weaponry.emit(new_bullet)

func _on_attack_timer_timeout() -> void:
	if player:
		var particles: Node3D = \
		preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()
	
		shark_spawn_location.add_child.call_deferred(particles)
		var new_missile :HomingMissile = SHARK.instantiate()
		
		new_missile.target_node = player
		EventBus.spawn_weaponry.emit(new_missile)
		new_missile.global_position =shark_spawn_location.global_position
