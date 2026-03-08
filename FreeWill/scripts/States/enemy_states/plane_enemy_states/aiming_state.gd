class_name AimingState extends EnemyState


@export var move_speed : float = 10.0
@export var turn_speed : float = 2.5
@export var aim: RayCast3D
@export var attack_range :float = 300
@export var retreat_range: float = 25

var heading : Vector3 = Vector3.FORWARD
var player_direction : Vector3

@export var lock_on_timer: Timer


func enter()->void:
	
	player = get_tree().get_first_node_in_group("player")
	
func update(_delta : float)->void:
	pass
	
func physics_update(_delta :float)->void:
	if enemy and player:
		
		player_direction = Vector3(player.global_position - enemy.global_position ).normalized()
		heading = heading.slerp(player_direction,turn_speed * _delta)
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = heading * move_speed
		if enemy.global_position.distance_to(player.global_position) <= attack_range:
			if aim.get_collider():
				start_lock_on()
			else:
				stop_lock_on()
		if enemy.global_position.distance_to(player.global_position) <= retreat_range:
			Transitioned.emit(self,"retreatstate")


func start_lock_on()->void:
	if  lock_on_timer.is_stopped():
		print("locking on")
		lock_on_timer.start()


func stop_lock_on()->void:
	
	lock_on_timer.stop()


func _on_lock_on_timer_timeout() -> void:
	print("fire")
	Transitioned.emit(self,"retreatstate")
